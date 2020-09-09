struct HydroDispatchReservoirCascade <: PSI.AbstractHydroReservoirFormulation end

function energy_balance_external_input_param_cascade(
    psi_container::PSI.PSIContainer,
    initial_conditions::Vector{PSI.InitialCondition},
    inflow_data::Vector{PSI.DeviceTimeSeriesConstraintInfo},
    upstream::Vector{Vector{HydroEnergyCascade}},
    cons_name::Symbol,
    var_names::Tuple{Symbol, Symbol, Symbol},
    param_reference::PSI.UpdateRef,
)
    time_steps = PSI.model_time_steps(psi_container)
    resolution = PSI.model_resolution(psi_container)
    fraction_of_hour = Dates.value(Dates.Second(resolution)) / 60
    name_index = [PSI.get_component_name(d) for d in inflow_data]

    varspill = PSI.get_variable(psi_container, var_names[1])
    varout = PSI.get_variable(psi_container, var_names[2])
    varenergy = PSI.get_variable(psi_container, var_names[3])
    container = PSI.add_param_container!(psi_container, param_reference, name_index, time_steps)
    paraminflow = PSI.get_parameter_array(container)
    multiplier = PSI.get_multiplier_array(container)
    constraint = PSI.add_cons_container!(psi_container, cons_name, name_index, time_steps)

    for (ix, d) in enumerate(inflow_data)
        name = PSI.get_component_name(d)
        upstream_devices = upstream[ix]
        multiplier[name, 1] = d.multiplier
        paraminflow[name, 1] = PJ.add_parameter(psi_container.JuMPmodel, d.timeseries[1])
        exp =
            initial_conditions[ix].value +
            (
                multiplier[name, 1] * paraminflow[name, 1] - varspill[name, 1] -
                varout[name, 1]
            ) * fraction_of_hour

        if !isempty(upstream_devices)
            for j in upstream_devices
                JuMP.add_to_expression!(exp, varspill[IS.get_name(j), 1], fraction_of_hour)
                JuMP.add_to_expression!(exp, varout[IS.get_name(j), 1], fraction_of_hour)
            end
        end

        constraint[name, 1] =
            JuMP.@constraint(psi_container.JuMPmodel, varenergy[name, 1] == exp)

        for t in time_steps[2:end]
            paraminflow[name, t] =
                PJ.add_parameter(psi_container.JuMPmodel, d.timeseries[t])
            exp =
                varenergy[name, t - 1] +
                (
                    d.multiplier * paraminflow[name, t] - varspill[name, t] -
                    varout[name, t]
                ) * fraction_of_hour

            if !isempty(upstream_devices)
                for j in upstream_devices
                    JuMP.add_to_expression!(exp, varspill[IS.get_name(j), t], fraction_of_hour)
                    JuMP.add_to_expression!(exp, varout[IS.get_name(j), t], fraction_of_hour)
                end
            end

            constraint[name, t] =
                JuMP.@constraint(psi_container.JuMPmodel, varenergy[name, t] == exp)
        end
    end
    return
end

function energy_balance_external_input_cascade(
    psi_container::PSI.PSIContainer,
    initial_conditions::Vector{PSI.InitialCondition},
    inflow_data::Vector{PSI.DeviceTimeSeriesConstraintInfo},
    upstream::Vector{Vector{HydroEnergyCascade}},
    cons_name::Symbol,
    var_names::Tuple{Symbol, Symbol, Symbol},
)
    time_steps = PSI.model_time_steps(psi_container)
    resolution = PSI.model_resolution(psi_container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / 60
    name_index = [PSI.get_component_name(d) for d in inflow_data]

    varspill = PSI.get_variable(psi_container, var_names[1])
    varout = PSI.get_variable(psi_container, var_names[2])
    varenergy = PSI.get_variable(psi_container, var_names[3])

    constraint = PSI.add_cons_container!(psi_container, cons_name, name_index, time_steps)

    for (ix, d) in enumerate(inflow_data)
        name = PSI.get_component_name(d)
        upstream_devices = upstream[ix]

        exp = initial_conditions[ix].value +
        (d.multiplier * d.timeseries[1] - varspill[name, 1] - varout[name, 1]) *
        fraction_of_hour

        if !isempty(upstream_devices)
            for j in upstream_devices
                JuMP.add_to_expression!(exp, varspill[IS.get_name(j), 1], fraction_of_hour)
                JuMP.add_to_expression!(exp, varout[IS.get_name(j), 1], fraction_of_hour)
            end
        end

        constraint[name, 1] = JuMP.@constraint(
            psi_container.JuMPmodel,
            varenergy[name, 1] == exp
        )

        for t in time_steps[2:end]

            exp = varenergy[name, t - 1] +
            (d.multiplier * d.timeseries[t] - varspill[name, t] - varout[name, t]) * fraction_of_hour

            if !isempty(upstream_devices)
                for j in upstream_devices
                    JuMP.add_to_expression!(exp, varspill[IS.get_name(j), t], fraction_of_hour)
                    JuMP.add_to_expression!(exp, varout[IS.get_name(j), t], fraction_of_hour)
                end
            end

            constraint[name, t] = JuMP.@constraint(
                psi_container.JuMPmodel,
                varenergy[name, t] == exp
            )

        end

    end

    return
end

function energy_balance_cascade_constraint!(
    psi_container::PSI.PSIContainer,
    devices::IS.FlattenIteratorWrapper{H},
    model::PSI.DeviceModel{H, HydroDispatchReservoirCascade},
    system_formulation::Type{<:PM.AbstractPowerModel},
    feedforward::Union{Nothing, PSI.AbstractAffectFeedForward},
) where {H <: HydroEnergyCascade}
    key = PSI.ICKey(PSI.EnergyLevel, H)
    parameters = PSI.model_has_parameters(psi_container)
    use_forecast_data = PSI.model_uses_forecasts(psi_container)

    if !PSI.has_initial_conditions(psi_container.initial_conditions, key)
        throw(IS.DataFormatError("Initial Conditions for $(H) Energy Constraints not in the model"))
    end

    forecast_label = "get_inflow"
    constraint_infos = Vector{PSI.DeviceTimeSeriesConstraintInfo}(undef, length(devices))
    upstream_data = Vector{Vector{HydroEnergyCascade}}(undef, length(devices))

    for (ix, d) in enumerate(devices)
        ts_vector = PSI.get_time_series(psi_container, d, forecast_label)
        constraint_info =
            PSI.DeviceTimeSeriesConstraintInfo(d, x -> PSY.get_inflow(x), ts_vector)
        PSI.add_device_services!(constraint_info.range, d, model)
        constraint_infos[ix] = constraint_info
        upstream_data[ix] = get_upstream(d)
    end

    if parameters
        energy_balance_external_input_param_cascade(
            psi_container,
            PSI.get_initial_conditions(psi_container, key),
            constraint_infos,
            upstream_data,
            PSI.make_constraint_name(PSI.ENERGY_CAPACITY, H),
            (
                PSI.make_variable_name(PSI.SPILLAGE, H),
                PSI.make_variable_name(PSI.ACTIVE_POWER, H),
                PSI.make_variable_name(PSI.ENERGY, H),
            ),
            PSI.UpdateRef{H}(PSI.INFLOW, forecast_label),
        )
    else
        energy_balance_external_input_cascade(
            psi_container,
            PSI.get_initial_conditions(psi_container, key),
            constraint_infos,
            upstream_data,
            PSI.make_constraint_name(PSI.ENERGY_CAPACITY, H),
            (
                PSI.make_variable_name(PSI.SPILLAGE, H),
                PSI.make_variable_name(PSI.ACTIVE_POWER, H),
                PSI.make_variable_name(PSI.ENERGY, H),
            ),
        )
    end
    return
end