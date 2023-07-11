#! format: off
requires_initialization(::PSI.AbstractHydroFormulation) = false
requires_initialization(::PSI.AbstractHydroUnitCommitment) = true

get_variable_multiplier(_, ::Type{<:PSY.HydroGen}, ::PSI.AbstractHydroFormulation) = 1.0
get_expression_type_for_reserve(::PSI.ActivePowerReserveVariable, ::Type{<:PSY.HydroGen}, ::Type{<:PSY.Reserve{PSY.ReserveUp}}) = ActivePowerRangeExpressionUB
get_expression_type_for_reserve(::PSI.ActivePowerReserveVariable, ::Type{<:PSY.HydroGen}, ::Type{<:PSY.Reserve{PSY.ReserveDown}}) = ActivePowerRangeExpressionLB
get_expression_type_for_reserve(::PSI.ActivePowerReserveVariable, ::Type{<:PSY.HydroPumpedStorage}, ::Type{<:PSY.Reserve{PSY.ReserveUp}}) = ReserveRangeExpressionUB
get_expression_type_for_reserve(::PSI.ActivePowerReserveVariable, ::Type{<:PSY.HydroPumpedStorage}, ::Type{<:PSY.Reserve{PSY.ReserveDown}}) = ReserveRangeExpressionLB

########################### PSI.ActivePowerVariable, HydroGen #################################
get_variable_binary(::PSI.ActivePowerVariable, ::Type{<:PSY.HydroGen}, ::PSI.AbstractHydroFormulation) = false
get_variable_warm_start_value(::PSI.ActivePowerVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_active_power(d)
get_variable_lower_bound(::PSI.ActivePowerVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_active_power_limits(d).min
get_variable_lower_bound(::PSI.ActivePowerVariable, d::PSY.HydroGen, ::PSI.AbstractHydroUnitCommitment) = 0.0
get_variable_upper_bound(::PSI.ActivePowerVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_active_power_limits(d).max

############## PSI.ActivePowerVariable, HydroDispatchRunOfRiver ####################
get_variable_lower_bound(::PSI.ActivePowerVariable, d::PSY.HydroGen, ::HydroDispatchRunOfRiver) = 0.0

############## PSI.ReactivePowerVariable, HydroGen ####################
get_variable_binary(::PSI.ReactivePowerVariable, ::Type{<:PSY.HydroGen}, ::PSI.AbstractHydroFormulation) = false
get_variable_warm_start_value(::PSI.ReactivePowerVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_active_power(d)
get_variable_lower_bound(::PSI.ReactivePowerVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_active_power_limits(d).min
get_variable_upper_bound(::PSI.ReactivePowerVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_active_power_limits(d).max

############## PSI.EnergyVariable, HydroGen ####################
get_variable_binary(::PSI.EnergyVariable, ::Type{<:PSY.HydroGen}, ::PSI.AbstractHydroFormulation) = false
get_variable_warm_start_value(pv::PSI.EnergyVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_initial_storage(d)
get_variable_lower_bound(::PSI.EnergyVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = 0.0
get_variable_upper_bound(::PSI.EnergyVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_storage_capacity(d)

########################### EnergyVariableUp, HydroGen #################################
get_variable_binary(::EnergyVariableUp, ::Type{<:PSY.HydroGen}, ::PSI.AbstractHydroFormulation) = false
get_variable_warm_start_value(pv::EnergyVariableUp, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_initial_storage(d).up
get_variable_lower_bound(::EnergyVariableUp, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = 0.0
get_variable_upper_bound(::EnergyVariableUp, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_storage_capacity(d).up

########################### EnergyVariableDown, HydroGen #################################
get_variable_binary(::EnergyVariableDown, ::Type{<:PSY.HydroGen}, ::PSI.AbstractHydroFormulation) = false
get_variable_warm_start_value(::EnergyVariableDown, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_initial_storage(d).down
get_variable_lower_bound(::EnergyVariableDown, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = 0.0
get_variable_upper_bound(::EnergyVariableDown, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_storage_capacity(d).down

########################### PSI.ActivePowerInVariable, HydroGen #################################
get_variable_binary(::PSI.ActivePowerInVariable, ::Type{<:PSY.HydroGen}, ::PSI.AbstractHydroFormulation) = false
get_variable_lower_bound(::PSI.ActivePowerInVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = 0.0
get_variable_upper_bound(::PSI.ActivePowerInVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = nothing
get_variable_multiplier(::PSI.ActivePowerInVariable, d::Type{<:PSY.HydroGen}, ::PSI.AbstractHydroFormulation) = -1.0

########################### PSI.ActivePowerOutVariable, HydroGen #################################
get_variable_binary(::PSI.ActivePowerOutVariable, ::Type{<:PSY.HydroGen}, ::PSI.AbstractHydroFormulation) = false
get_variable_lower_bound(::PSI.ActivePowerOutVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = 0.0
get_variable_upper_bound(::PSI.ActivePowerOutVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = nothing
get_variable_multiplier(::PSI.ActivePowerOutVariable, d::Type{<:PSY.HydroGen}, ::PSI.AbstractHydroFormulation) = 1.0

############## OnVariable, HydroGen ####################
get_variable_binary(::OnVariable, ::Type{<:PSY.HydroGen}, ::PSI.AbstractHydroFormulation) = true
get_variable_warm_start_value(::OnVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_active_power(d) > 0 ? 1.0 : 0.0

############## WaterSpillageVariable, HydroGen ####################
get_variable_binary(::WaterSpillageVariable, ::Type{<:PSY.HydroGen}, ::PSI.AbstractHydroFormulation) = false
get_variable_lower_bound(::WaterSpillageVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = 0.0

############## ReservationVariable, HydroGen ####################
get_variable_binary(::ReservationVariable, ::Type{<:PSY.HydroGen}, ::PSI.AbstractHydroFormulation) = true
get_variable_binary(::ReservationVariable, ::Type{<:PSY.HydroPumpedStorage}, ::PSI.AbstractHydroFormulation) = true

############## EnergyShortageVariable, HydroGen ####################
get_variable_binary(::EnergyShortageVariable, ::Type{<:PSY.HydroGen}, ::PSI.AbstractHydroFormulation) = false
get_variable_lower_bound(::EnergyShortageVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = 0.0
get_variable_upper_bound(::EnergyShortageVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_storage_capacity(d)
get_variable_upper_bound(::EnergyShortageVariable, d::PSY.HydroPumpedStorage, ::PSI.AbstractHydroFormulation) = PSY.get_storage_capacity(d).up
############## EnergySurplusVariable, HydroGen ####################
get_variable_binary(::EnergySurplusVariable, ::Type{<:PSY.HydroGen}, ::PSI.AbstractHydroFormulation) = false
get_variable_upper_bound(::EnergySurplusVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = 0.0
get_variable_lower_bound(::EnergySurplusVariable, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = - PSY.get_storage_capacity(d)
get_variable_lower_bound(::EnergySurplusVariable, d::PSY.HydroPumpedStorage, ::PSI.AbstractHydroFormulation) = - PSY.get_storage_capacity(d).up
########################### Parameter related set functions ################################
get_multiplier_value(::EnergyBudgetTimeSeriesParameter, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_max_active_power(d)
get_multiplier_value(::EnergyBudgetTimeSeriesParameter, d::PSY.HydroEnergyReservoir, ::PSI.AbstractHydroFormulation) = PSY.get_storage_capacity(d)
get_multiplier_value(::EnergyTargetTimeSeriesParameter, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_storage_capacity(d)
get_multiplier_value(::InflowTimeSeriesParameter, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_inflow(d) * PSY.get_conversion_factor(d)
get_multiplier_value(::OutflowTimeSeriesParameter, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_outflow(d) * PSY.get_conversion_factor(d)
get_multiplier_value(::TimeSeriesParameter, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_max_active_power(d)
get_multiplier_value(::TimeSeriesParameter, d::PSY.HydroGen, ::FixedOutput) = PSY.get_max_active_power(d)

get_parameter_multiplier(::VariableValueParameter, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = 1.0
get_initial_parameter_value(::VariableValueParameter, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = 1.0
get_expression_multiplier(::OnStatusParameter, ::ActivePowerRangeExpressionUB, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_active_power_limits(d).max
get_expression_multiplier(::OnStatusParameter, ::ActivePowerRangeExpressionLB, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_active_power_limits(d).min

#################### Initial Conditions for models ###############
initial_condition_default(::DeviceStatus, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_status(d)
initial_condition_variable(::DeviceStatus, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = OnVariable()
initial_condition_default(::DevicePower, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_active_power(d)
initial_condition_variable(::DevicePower, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSI.ActivePowerVariable()
initial_condition_default(::InitialEnergyLevel, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_initial_storage(d)
initial_condition_variable(::InitialEnergyLevel, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSI.EnergyVariable()
initial_condition_default(::InitialEnergyLevelUp, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_initial_storage(d).up
initial_condition_variable(::InitialEnergyLevelUp, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = EnergyVariableUp()
initial_condition_default(::InitialEnergyLevelDown, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_initial_storage(d).down
initial_condition_variable(::InitialEnergyLevelDown, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = EnergyVariableDown()
initial_condition_default(::InitialTimeDurationOn, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_status(d) ? PSY.get_time_at_status(d) :  0.0
initial_condition_variable(::InitialTimeDurationOn, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = OnVariable()
initial_condition_default(::InitialTimeDurationOff, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = PSY.get_status(d) ? 0.0 : PSY.get_time_at_status(d)
initial_condition_variable(::InitialTimeDurationOff, d::PSY.HydroGen, ::PSI.AbstractHydroFormulation) = OnVariable()

########################Objective Function##################################################
proportional_cost(cost::Nothing, ::PSY.HydroGen, ::PSI.ActivePowerVariable, ::PSI.AbstractHydroFormulation)=0.0
proportional_cost(cost::PSY.OperationalCost, ::OnVariable, ::PSY.HydroGen, ::PSI.AbstractHydroFormulation)=PSY.get_fixed(cost)
proportional_cost(cost::PSY.StorageManagementCost, ::EnergySurplusVariable, ::PSY.HydroGen, ::PSI.AbstractHydroFormulation)=PSY.get_energy_surplus_cost(cost)
proportional_cost(cost::PSY.StorageManagementCost, ::EnergyShortageVariable, ::PSY.HydroGen, ::PSI.AbstractHydroFormulation)=PSY.get_energy_shortage_cost(cost)

objective_function_multiplier(::PSI.ActivePowerVariable, ::PSI.AbstractHydroFormulation)=OBJECTIVE_FUNCTION_POSITIVE
objective_function_multiplier(::PSI.ActivePowerOutVariable, ::PSI.AbstractHydroFormulation)=OBJECTIVE_FUNCTION_POSITIVE
objective_function_multiplier(::OnVariable, ::PSI.AbstractHydroFormulation)=OBJECTIVE_FUNCTION_POSITIVE
objective_function_multiplier(::EnergySurplusVariable, ::PSI.AbstractHydroFormulation)=OBJECTIVE_FUNCTION_NEGATIVE
objective_function_multiplier(::EnergyShortageVariable, ::PSI.AbstractHydroFormulation)=OBJECTIVE_FUNCTION_POSITIVE

sos_status(::PSY.HydroGen, ::PSI.AbstractHydroFormulation)=SOSStatusVariable.NO_VARIABLE
sos_status(::PSY.HydroGen, ::PSI.AbstractHydroUnitCommitment)=SOSStatusVariable.VARIABLE

variable_cost(::Nothing, ::PSI.ActivePowerVariable, ::PSY.HydroGen, ::PSI.AbstractHydroFormulation)=0.0
variable_cost(cost::PSY.OperationalCost, ::PSI.ActivePowerVariable, ::PSY.HydroGen, ::PSI.AbstractHydroFormulation)=PSY.get_variable(cost)
variable_cost(cost::PSY.OperationalCost, ::PSI.ActivePowerOutVariable, ::PSY.HydroGen, ::PSI.AbstractHydroFormulation)=PSY.get_variable(cost)

#! format: on

function get_initial_conditions_device_model(
    ::OperationModel,
    model::PSI.DeviceModel{T, <:PSI.AbstractHydroFormulation},
) where {T <: PSY.HydroEnergyReservoir}
    return model
end

function get_initial_conditions_device_model(
    ::OperationModel,
    ::PSI.DeviceModel{T, <:PSI.AbstractHydroFormulation},
) where {T <: PSY.HydroDispatch}
    return PSI.DeviceModel(PSY.HydroDispatch, HydroDispatchRunOfRiver)
end

function get_initial_conditions_device_model(
    ::OperationModel,
    ::PSI.DeviceModel{T, <:PSI.AbstractHydroFormulation},
) where {T <: PSY.HydroPumpedStorage}
    return PSI.DeviceModel(PSY.HydroPumpedStorage, HydroDispatchPumpedStorage)
end

function get_default_time_series_names(
    ::Type{<:PSY.HydroGen},
    ::Type{<:Union{FixedOutput, HydroDispatchRunOfRiver, HydroCommitmentRunOfRiver}},
)
    return Dict{Type{<:TimeSeriesParameter}, String}(
        ActivePowerTimeSeriesParameter => "max_active_power",
        ReactivePowerTimeSeriesParameter => "max_active_power",
    )
end

function get_default_time_series_names(
    ::Type{PSY.HydroEnergyReservoir},
    ::Type{<:Union{HydroCommitmentReservoirBudget, HydroDispatchReservoirBudget}},
)
    return Dict{Type{<:TimeSeriesParameter}, String}(
        EnergyBudgetTimeSeriesParameter => "hydro_budget",
    )
end

function get_default_time_series_names(
    ::Type{PSY.HydroEnergyReservoir},
    ::Type{<:Union{HydroDispatchReservoirStorage, HydroCommitmentReservoirStorage}},
)
    return Dict{Type{<:TimeSeriesParameter}, String}(
        EnergyTargetTimeSeriesParameter => "storage_target",
        InflowTimeSeriesParameter => "inflow",
    )
end

function get_default_time_series_names(
    ::Type{PSY.HydroPumpedStorage},
    ::Type{<:HydroDispatchPumpedStorage},
)
    return Dict{Type{<:TimeSeriesParameter}, String}(
        InflowTimeSeriesParameter => "inflow",
        OutflowTimeSeriesParameter => "outflow",
    )
end

function get_default_attributes(
    ::Type{T},
    ::Type{D},
) where {T <: PSY.HydroGen, D <: Union{FixedOutput, PSI.AbstractHydroFormulation}}
    return Dict{String, Any}("reservation" => false)
end

function get_default_attributes(
    ::Type{PSY.HydroPumpedStorage},
    ::Type{HydroDispatchPumpedStorage},
)
    return Dict{String, Any}("reservation" => true)
end

"""
Time series constraints
"""
function add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:Union{VariableType, ExpressionType}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::NetworkModel{X},
) where {V <: PSY.HydroGen, W <: HydroDispatchRunOfRiver, X <: PM.AbstractPowerModel}
    if !has_semicontinuous_feedforward(model, U)
        add_range_constraints!(container, T, U, devices, model, X)
    end
    add_parameterized_upper_bound_range_constraints(
        container,
        PSI.ActivePowerVariableTimeSeriesLimitsConstraint,
        U,
        ActivePowerTimeSeriesParameter,
        devices,
        model,
        X,
    )
    return
end

function add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:RangeConstraintLBExpressions},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::NetworkModel{X},
) where {V <: PSY.HydroGen, W <: HydroDispatchRunOfRiver, X <: PM.AbstractPowerModel}
    if !has_semicontinuous_feedforward(model, U)
        add_range_constraints!(container, T, U, devices, model, X)
    end
    return
end

"""
Add semicontinuous range constraints for Hydro Unit Commitment formulation
"""
function add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:Union{VariableType, <:RangeConstraintLBExpressions}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::NetworkModel{X},
) where {V <: PSY.HydroGen, W <: HydroCommitmentRunOfRiver, X <: PM.AbstractPowerModel}
    add_semicontinuous_range_constraints!(container, T, U, devices, model, X)
    return
end

function add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:Union{VariableType, ExpressionType}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::NetworkModel{X},
) where {V <: PSY.HydroGen, W <: HydroCommitmentRunOfRiver, X <: PM.AbstractPowerModel}
    add_semicontinuous_range_constraints!(container, T, U, devices, model, X)
    add_parameterized_upper_bound_range_constraints(
        container,
        PSI.ActivePowerVariableTimeSeriesLimitsConstraint,
        U,
        ActivePowerTimeSeriesParameter,
        devices,
        model,
        X,
    )
    return
end

"""
Min and max reactive Power Variable limits
"""
function get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.ReactivePowerVariableLimitsConstraint},
    ::Type{<:PSI.AbstractHydroFormulation},
)
    return PSY.get_reactive_power_limits(x)
end

"""
Min and max active Power Variable limits
"""
function get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.ActivePowerVariableLimitsConstraint},
    ::Type{<:PSI.AbstractHydroFormulation},
)
    return PSY.get_active_power_limits(x)
end

function get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.ActivePowerVariableLimitsConstraint},
    ::Type{HydroDispatchRunOfRiver},
)
    return (min=0.0, max=PSY.get_max_active_power(x))
end

"""
Add power variable limits constraints for hydro unit commitment formulation
"""
function add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{<:PowerVariableLimitsConstraint},
    U::Type{<:Union{VariableType, ExpressionType}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::NetworkModel{X},
) where {V <: PSY.HydroGen, W <: PSI.AbstractHydroUnitCommitment, X <: PM.AbstractPowerModel}
    add_semicontinuous_range_constraints!(container, T, U, devices, model, X)
    return
end

"""
Add power variable limits constraints for hydro dispatch formulation
"""
function add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{<:PowerVariableLimitsConstraint},
    U::Type{<:Union{VariableType, ExpressionType}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::NetworkModel{X},
) where {
    V <: PSY.HydroGen,
    W <: AbstractHydroDispatchFormulation,
    X <: PM.AbstractPowerModel,
}
    if !has_semicontinuous_feedforward(model, U)
        add_range_constraints!(container, T, U, devices, model, X)
    end
    return
end

"""
Add input power variable limits constraints for hydro dispatch formulation
"""
function add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{InputPSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:Union{VariableType, ExpressionType}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::NetworkModel{X},
) where {
    V <: PSY.HydroPumpedStorage,
    W <: AbstractHydroReservoirFormulation,
    X <: PM.AbstractPowerModel,
}
    if get_attribute(model, "reservation")
        add_reserve_range_constraints!(container, T, U, devices, model, X)
    else
        if !has_semicontinuous_feedforward(model, U)
            add_range_constraints!(container, T, U, devices, model, X)
        end
    end
    return
end

"""
Add output power variable limits constraints for hydro dispatch formulation
"""
function add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{<:PowerVariableLimitsConstraint},
    U::Type{<:Union{VariableType, ExpressionType}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::NetworkModel{X},
) where {
    V <: PSY.HydroPumpedStorage,
    W <: AbstractHydroReservoirFormulation,
    X <: PM.AbstractPowerModel,
}
    if get_attribute(model, "reservation")
        add_reserve_range_constraints!(container, T, U, devices, model, X)
    else
        if !has_semicontinuous_feedforward(model, U)
            add_range_constraints!(container, T, U, devices, model, X)
        end
    end
    return
end

"""
Min and max output active power variable limits for hydro dispatch pumped storage
"""
function get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:OutputPSI.ActivePowerVariableLimitsConstraint},
    ::Type{HydroDispatchPumpedStorage},
)
    return PSY.get_active_power_limits(x)
end

"""
Min and max input active power variable limits for hydro dispatch pumped storage
"""
function get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:InputPSI.ActivePowerVariableLimitsConstraint},
    ::Type{HydroDispatchPumpedStorage},
)
    return PSY.get_active_power_limits_pump(x)
end

######################## Energy balance constraints ############################

"""
This function defines the constraints for the water level (or state of charge)
for the Hydro Reservoir.
"""
function add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{EnergyBalanceConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::NetworkModel{X},
) where {
    V <: PSY.HydroEnergyReservoir,
    W <: PSI.AbstractHydroFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = get_time_steps(container)
    resolution = get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / MINUTES_IN_HOUR
    names = [PSY.get_name(x) for x in devices]
    initial_conditions = get_initial_condition(container, InitialEnergyLevel(), V)
    energy_var = get_variable(container, PSI.EnergyVariable(), V)
    power_var = get_variable(container, PSI.ActivePowerVariable(), V)
    spillage_var = get_variable(container, WaterSpillageVariable(), V)

    constraint = add_constraints_container!(
        container,
        EnergyBalanceConstraint(),
        V,
        names,
        time_steps,
    )
    param_container = get_parameter(container, InflowTimeSeriesParameter(), V)
    multiplier = get_parameter_multiplier_array(container, InflowTimeSeriesParameter(), V)

    for ic in initial_conditions
        device = get_component(ic)
        name = PSY.get_name(device)
        param = get_parameter_column_values(param_container, name)
        constraint[name, 1] = JuMP.@constraint(
            container.JuMPmodel,
            energy_var[name, 1] ==
            get_value(ic) - power_var[name, 1] * fraction_of_hour -
            spillage_var[name, 1] * fraction_of_hour + param[1] * multiplier[name, 1]
        )

        for t in time_steps[2:end]
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                energy_var[name, t] ==
                energy_var[name, t - 1] + param[t] * multiplier[name, t] -
                power_var[name, t] * fraction_of_hour -
                spillage_var[name, t] * fraction_of_hour
            )
        end
    end
    return
end

"""
This function defines the constraints for the water level (or state of charge)
for the HydroPumpedStorage.
"""
function add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{EnergyCapacityUpConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::NetworkModel{X},
) where {
    V <: PSY.HydroPumpedStorage,
    W <: PSI.AbstractHydroFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = get_time_steps(container)
    resolution = get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / MINUTES_IN_HOUR
    names = [PSY.get_name(x) for x in devices]
    initial_conditions = get_initial_condition(container, InitialEnergyLevelUp(), V)

    energy_var = get_variable(container, EnergyVariableUp(), V)
    powerin_var = get_variable(container, PSI.ActivePowerInVariable(), V)
    powerout_var = get_variable(container, PSI.ActivePowerOutVariable(), V)
    spillage_var = get_variable(container, WaterSpillageVariable(), V)

    constraint = add_constraints_container!(
        container,
        EnergyCapacityUpConstraint(),
        V,
        names,
        time_steps,
    )
    param_container = get_parameter(container, InflowTimeSeriesParameter(), V)
    multiplier = get_multiplier_array(param_container)

    for ic in initial_conditions
        device = get_component(ic)
        efficiency = PSY.get_pump_efficiency(device)
        name = PSY.get_name(device)
        constraint[name, 1] = JuMP.@constraint(
            container.JuMPmodel,
            energy_var[name, 1] ==
            get_value(ic) +
            (
                powerin_var[name, 1] -
                (spillage_var[name, 1] + powerout_var[name, 1]) / efficiency
            ) * fraction_of_hour +
            get_parameter_column_refs(param_container, name)[1] * multiplier[name, 1]
        )

        for t in time_steps[2:end]
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                energy_var[name, t] ==
                energy_var[name, t - 1] +
                get_parameter_column_refs(param_container, name)[t] * multiplier[name, t] +
                (
                    powerin_var[name, 1] -
                    (powerout_var[name, t] + spillage_var[name, t]) / efficiency
                ) * fraction_of_hour
            )
        end
    end
    return
end

"""
Add energy capacity down constraints for hydro pumped storage
"""
function add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{EnergyCapacityDownConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::NetworkModel{X},
) where {
    V <: PSY.HydroPumpedStorage,
    W <: PSI.AbstractHydroFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = get_time_steps(container)
    resolution = get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / MINUTES_IN_HOUR
    names = [PSY.get_name(x) for x in devices]
    initial_conditions = get_initial_condition(container, InitialEnergyLevelDown(), V)

    energy_var = get_variable(container, EnergyVariableDown(), V)
    powerin_var = get_variable(container, PSI.ActivePowerInVariable(), V)
    powerout_var = get_variable(container, PSI.ActivePowerOutVariable(), V)
    spillage_var = get_variable(container, WaterSpillageVariable(), V)

    constraint = add_constraints_container!(
        container,
        EnergyCapacityDownConstraint(),
        V,
        names,
        time_steps,
    )

    param_container = get_parameter(container, OutflowTimeSeriesParameter(), V)
    multiplier = get_multiplier_array(param_container)

    for ic in initial_conditions
        device = get_component(ic)
        efficiency = PSY.get_pump_efficiency(device)
        name = PSY.get_name(device)
        param = get_parameter_column_refs(param_container, name)
        constraint[name, 1] = JuMP.@constraint(
            container.JuMPmodel,
            energy_var[name, 1] ==
            get_value(ic) -
            (
                spillage_var[name, 1] + powerout_var[name, 1] -
                powerin_var[name, 1] / efficiency
            ) * fraction_of_hour - param[1] * multiplier[name, 1]
        )

        for t in time_steps[2:end]
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                energy_var[name, t] ==
                energy_var[name, t - 1] - param[t] * multiplier[name, t] +
                (
                    powerout_var[name, t] - powerin_var[name, t] / efficiency +
                    spillage_var[name, t]
                ) * fraction_of_hour
            )
        end
    end
    return
end

"""
Add energy target constraints for hydro gen
"""
function add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{EnergyTargetConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::NetworkModel{X},
) where {V <: PSY.HydroGen, W <: PSI.AbstractHydroFormulation, X <: PM.AbstractPowerModel}
    time_steps = get_time_steps(container)
    set_name = [PSY.get_name(d) for d in devices]
    constraint = add_constraints_container!(
        container,
        EnergyTargetConstraint(),
        V,
        set_name,
        time_steps,
    )

    e_var = get_variable(container, PSI.EnergyVariable(), V)
    shortage_var = get_variable(container, EnergyShortageVariable(), V)
    surplus_var = get_variable(container, EnergySurplusVariable(), V)
    param_container = get_parameter(container, EnergyTargetTimeSeriesParameter(), V)
    multiplier =
        get_parameter_multiplier_array(container, EnergyTargetTimeSeriesParameter(), V)

    for d in devices
        name = PSY.get_name(d)
        cost_data = PSY.get_operation_cost(d)
        if isa(cost_data, PSY.StorageManagementCost)
            shortage_cost = PSY.get_energy_shortage_cost(cost_data)
        else
            @debug "Data for device $name doesn't contain shortage costs"
            shortage_cost = 0.0
        end

        if shortage_cost == 0.0
            @warn(
                "Device $name has energy shortage cost set to 0.0, as a result the model will turnoff the EnergyShortageVariable to avoid infeasible/unbounded problem."
            )
            JuMP.delete_upper_bound.(shortage_var[name, :])
            JuMP.set_upper_bound.(shortage_var[name, :], 0.0)
        end
        param = get_parameter_column_values(param_container, name)
        for t in time_steps
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                e_var[name, t] + shortage_var[name, t] + surplus_var[name, t] ==
                multiplier[name, t] * param[t]
            )
        end
    end
    return
end

##################################### Water/Energy Budget Constraint ############################
"""
This function define the budget constraint for the
active power budget formulation.

`` sum(P[t]) <= Budget ``
"""

function add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{EnergyBudgetConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::NetworkModel{X},
) where {V <: PSY.HydroGen, W <: PSI.AbstractHydroFormulation, X <: PM.AbstractPowerModel}
    time_steps = get_time_steps(container)
    set_name = [PSY.get_name(d) for d in devices]
    constraint =
        add_constraints_container!(container, EnergyBudgetConstraint(), V, set_name)

    variable_out = get_variable(container, PSI.ActivePowerVariable(), V)
    param_container = get_parameter(container, EnergyBudgetTimeSeriesParameter(), V)
    multiplier = get_multiplier_array(param_container)

    for d in devices
        name = PSY.get_name(d)
        param = get_parameter_column_values(param_container, name)
        constraint[name] = JuMP.@constraint(
            container.JuMPmodel,
            sum([variable_out[name, t] for t in time_steps]) <= sum([multiplier[name, t] * param[t] for t in time_steps])
        )
    end
    return
end

##################################### Auxillary Variables ############################

function calculate_aux_variable_value!(
    container::PSI.OptimizationContainer,
    ::AuxVarKey{EnergyOutput, T},
    system::PSY.System,
) where {T <: PSY.HydroGen}
    devices = get_available_components(T, system)
    time_steps = get_time_steps(container)
    resolution = get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / MINUTES_IN_HOUR
    p_variable_results = get_variable(container, PSI.ActivePowerVariable(), T)
    aux_variable_container = get_aux_variable(container, EnergyOutput(), T)
    for d in devices, t in time_steps
        name = PSY.get_name(d)
        aux_variable_container[name, t] =
            jump_value(p_variable_results[name, t]) * fraction_of_hour
    end

    return
end

function calculate_aux_variable_value!(
    container::PSI.OptimizationContainer,
    ::AuxVarKey{EnergyOutput, T},
    system::PSY.System,
) where {T <: PSY.HydroPumpedStorage}
    devices = get_available_components(T, system)
    time_steps = get_time_steps(container)
    resolution = get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / MINUTES_IN_HOUR
    p_variable_results = get_variable(container, PSI.ActivePowerOutVariable(), T)
    aux_variable_container = get_aux_variable(container, EnergyOutput(), T)
    for d in devices, t in time_steps
        name = PSY.get_name(d)
        aux_variable_container[name, t] =
            jump_value(p_variable_results[name, t]) * fraction_of_hour
    end

    return
end

##################################### Hydro generation cost ############################
function objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{T},
    ::PSI.DeviceModel{T, U},
    ::Type{<:PM.AbstractPowerModel},
) where {T <: PSY.HydroGen, U <: PSI.AbstractHydroUnitCommitment}
    add_variable_cost!(container, PSI.ActivePowerVariable(), devices, U())
    add_proportional_cost!(container, OnVariable(), devices, U())
    return
end

function objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{PSY.HydroPumpedStorage},
    ::PSI.DeviceModel{PSY.HydroPumpedStorage, T},
    ::Type{<:PM.AbstractPowerModel},
) where {T <: HydroDispatchPumpedStorage}
    add_variable_cost!(container, PSI.ActivePowerOutVariable(), devices, T())
    return
end

function objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{T},
    ::PSI.DeviceModel{T, U},
    ::Type{<:PM.AbstractPowerModel},
) where {T <: PSY.HydroGen, U <: AbstractHydroDispatchFormulation}
    add_variable_cost!(container, PSI.ActivePowerVariable(), devices, U())
    return
end

function objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{T},
    ::PSI.DeviceModel{T, U},
    ::Type{<:PM.AbstractPowerModel},
) where {
    T <: PSY.HydroPumpedStorage,
    U <: Union{HydroDispatchReservoirStorage, HydroDispatchReservoirBudget},
}
    add_variable_cost!(container, PSI.ActivePowerOutVariable(), devices, U())
    add_proportional_cost!(container, EnergySurplusVariable(), devices, U())
    add_proportional_cost!(container, EnergyShortageVariable(), devices, U())
    return
end

function objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{T},
    ::PSI.DeviceModel{T, U},
    ::Type{<:PM.AbstractPowerModel},
) where {T <: PSY.HydroEnergyReservoir, U <: HydroDispatchReservoirStorage}
    add_variable_cost!(container, PSI.ActivePowerVariable(), devices, U())
    add_proportional_cost!(container, EnergySurplusVariable(), devices, U())
    add_proportional_cost!(container, EnergyShortageVariable(), devices, U())
    return
end

function objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{T},
    ::PSI.DeviceModel{T, U},
    ::Type{<:PM.AbstractPowerModel},
) where {T <: PSY.HydroEnergyReservoir, U <: HydroCommitmentReservoirStorage}
    add_variable_cost!(container, PSI.ActivePowerVariable(), devices, U())
    add_proportional_cost!(container, EnergySurplusVariable(), devices, U())
    add_proportional_cost!(container, EnergyShortageVariable(), devices, U())
    return
end
