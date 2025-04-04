###################################################################
################ Hydro Medium Term Decision Model  ################
###################################################################

function PSI.build_impl!(decision_model::PSI.DecisionModel{MediumTermHydroPlanning})
    container = PSI.get_optimization_container(decision_model)
    sys = PSI.get_system(decision_model)
    base_power = PSY.get_base_power(sys)
    resolution = first(PSY.get_time_series_resolutions(sys))

    # Initialize Container #
    network_model = PSI.get_network_model(PSI.get_template(decision_model))
    PSI.init_optimization_container!(container, network_model, sys)
    PSI.init_model_store_params!(decision_model)

    ###############################
    ######## Variables ############
    ###############################

    # Thermals
    thermals = PSY.get_components(get_available, PSY.ThermalStandard, sys)
    thermal_model = PSI.get_model(PSI.get_template(decision_model), PSY.ThermalStandard)
    thermal_formulation = PSI.get_formulation(thermal_model)
    PSI.add_variables(container, PSI.ActivePowerVariable, thermals, thermal_formulation)

    # Renewables
    renewables = PSY.get_components(get_available, PSY.RenewableDispatch, sys)
    renewable_model = PSI.get_model(PSI.get_template(decision_model), PSY.RenewableDispatch)
    renewable_formulation = PSI.get_formulation(renewable_model)
    PSI.add_variables(container, PSI.ActivePowerVariable, renewables, renewable_formulation)

    # Turbines
    turbines = PSY.get_components(get_available, PSY.HydroTurbine, sys)
    turbine_model = PSI.get_model(PSI.get_template(decision_model), PSY.HydroTurbine)
    turbine_formulation = PSI.get_formulation(turbine_model)
    PSI.add_variables(container, PSI.ActivePowerVariable, turbines, turbine_formulation)

    # Reservoirs
    reservoirs = PSY.get_components(get_available, PSY.HydroReservoir, sys)
    reservoir_model = PSI.get_model(PSI.get_template(decision_model), PSY.HydroReservoir)
    reservoir_formulation = PSI.get_formulation(reservoir_model)
    PSI.add_variables!(
        container,
        HydroReservoirHeadVariable,
        reservoirs,
        reservoir_formulation,
    )
    PSI.add_variables!(
        container,
        HydroReservoirVolumeVariable,
        reservoirs,
        reservoir_formulation,
    )
    PSI.add_variables!(container, WaterSpillageVariable, reservoirs, reservoir_formulation)

    # Joint Variables
    PSI.add_variables(
        container,
        HydroTurbineFlowRateVariable,
        turbines,
        reservoirs,
        turbine_formulation,
    )

    ###############################
    ######## Parameters ###########
    ###############################

    # Loads
    loads = PSI.get_components(get_available, PSY.PowerLoad, sys)
    load_model = PSI.get_model(PSI.get_template(decision_model), PSY.PowerLoad)
    PSI.add_parameters!(container, PSI.ActivePowerTimeSeriesParameter, loads, load_model)

    # Renewable
    PSI.add_parameters!(
        container,
        PSI.ActivePowerTimeSeriesParameter,
        renewables,
        renewable_model,
    )

    # Reservoirs
    PSI.add_parameters!(container, InflowTimeSeriesParameter, reservoirs, reservoir_model)

    ###############################
    ######## Expressions ##########
    ###############################

    ref_num =
        PSY.get_number.(
            get_components(x -> PSY.get_bustype(x) == PSY.ACBusTypes.REF, PSY.ACBus, sys)
        )
    PSI.add_expression_container(
        container,
        PSI.ActivePowerBalance,
        PSY.System,
        ref_num,
        time_steps,
    )

    PSI.add_expressions!(
        container,
        TotalHydroFlowRateReservoirOut,
        reservoirs,
        reservoir_model,
    )
    PSI.add_expressions!(container, TotalHydroFlowRateTurbineOut, turbines, turbine_model)

    # Thermal
    add_to_balance_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        thermals,
        thermal_model,
        network_model,
    )
    # Renewable
    add_to_balance_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        renewables,
        renewable_model,
        network_model,
    )
    # Hydro
    add_to_balance_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        turbines,
        turbine_model,
        network_model,
    )
    # Load
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        loads,
        load_model,
        network_model,
    )

    ###############################
    ######## Constraints ##########
    ###############################

    # Balance Constraint
    PSI.add_constraints!(
        container,
        PSI.CopperPlateBalanceConstraint,
        sys,
        network_model,
    )

    # Renewable Limits
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerVariable,
        renewables,
        renewable_model,
        network_model,
    )

    # Reservoir Constraints
    PSI.add_constraints!(
        container,
        ReservoirLevelLimitConstraint,
        reservoirs,
        reservoir_model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        ReservoirInventoryConstraint,
        HydroReservoirVolumeVariable,
        reservoirs,
        reservoir_model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        ReservoirFinalInventoryConstraint,
        reservoirs,
        reservoir_model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        ReservoirHeadToVolumeConstraint,
        reservoirs,
        reservoir_model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        ReservoirInventoryConstraint,
        HydroReservoirVolumeVariable,
        reservoirs,
        reservoir_model,
        network_model,
    )

    # Turbine Constraints
    PSI.add_constraints!(
        container,
        TurbineFlowLimitConstraint,
        HydroTurbineFlowRateVariable,
        turbines,
        turbine_model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        TurbineFlowLimitConstraint,
        turbines,
        turbine_model,
        network_model,
    )

    ###############################
    ##### Objective Function ######
    ###############################

    # Add thermal cost
    for th in thermals
        name = PSY.get_name(th)
        device_base_power = PSY.get_base_power(th)
        op_cost = PSY.get_operation_cost(th)
        variable_cost = PSY.get_variable(op_cost)

        if isa(variable_cost, PSY.CostCurve{PSY.LinearCurve})
            power_units = PSY.get_power_units(variable_cost)
            _prop_term = PSY.get_proportional_term(PSY.get_value_curve(variable_cost))
            prop_term = PSI.get_proportional_cost_per_system_unit(
                _prop_term,
                power_units,
                base_power,
                device_base_power,
            )
        else
            error(
                "Variable Cost of type $(typeof(variable_cost)) is not supported for medium term planning.",
            )
        end
        variable =
            PSI.get_variable(container, PSI.ActivePowerVariable(), PSY.ThermalStandard)
        for t in time_steps
            lin_cost = prop_term * variable[name, t]
            PSI.add_to_objective_invariant_expression!(container, lin_cost)
        end
    end

    # Consolidate Model
    PSI.add_feedforward_arguments!(container, reservoir_model, reservoirs)
    PSI.add_feedforward_constraints!(container, reservoir_model, reservoirs)
    PSI.update_objective_function!(container)
    PSI.serialize_metadata!(container, PSI.get_output_dir(decision_model))
end
