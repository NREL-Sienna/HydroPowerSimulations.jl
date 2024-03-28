#! format: off
# These methods are defined in PowerSimulations
PSI.requires_initialization(::AbstractHydroReservoirFormulation) = false
PSI.requires_initialization(::AbstractHydroUnitCommitment) = true

PSI.get_variable_multiplier(_, ::Type{<:PSY.HydroGen}, ::AbstractHydroFormulation) = 1.0
PSI.get_expression_type_for_reserve(::PSI.ActivePowerReserveVariable, ::Type{<:PSY.HydroGen}, ::Type{<:PSY.Reserve{PSY.ReserveUp}}) = PSI.ActivePowerRangeExpressionUB
PSI.get_expression_type_for_reserve(::PSI.ActivePowerReserveVariable, ::Type{<:PSY.HydroGen}, ::Type{<:PSY.Reserve{PSY.ReserveDown}}) = PSI.ActivePowerRangeExpressionLB
PSI.get_expression_type_for_reserve(::PSI.ActivePowerReserveVariable, ::Type{PSY.HydroPumpedStorage}, ::Type{<:PSY.Reserve{PSY.ReserveUp}}) = PSI.ReserveRangeExpressionUB
PSI.get_expression_type_for_reserve(::PSI.ActivePowerReserveVariable, ::Type{PSY.HydroPumpedStorage}, ::Type{<:PSY.Reserve{PSY.ReserveDown}}) = PSI.ReserveRangeExpressionLB

########################### PSI.ActivePowerVariable, HydroGen #################################
# These methods are defined in PowerSimulations
PSI.get_variable_binary(::PSI.ActivePowerVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_binary(::PSI.ActivePowerVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroFormulation) = false
PSI.get_variable_warm_start_value(::PSI.ActivePowerVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_active_power(d)
PSI.get_variable_lower_bound(::PSI.ActivePowerVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_active_power_limits(d).min
PSI.get_variable_lower_bound(::PSI.ActivePowerVariable, d::PSY.HydroGen, ::AbstractHydroUnitCommitment) = 0.0
PSI.get_variable_upper_bound(::PSI.ActivePowerVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_active_power_limits(d).max

############## PSI.ReactivePowerVariable, HydroGen ####################
PSI.get_variable_binary(::PSI.ReactivePowerVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroDispatchFormulation) = false
PSI.get_variable_binary(::PSI.ReactivePowerVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_binary(::PSI.ReactivePowerVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroUnitCommitment) = false
PSI.get_variable_warm_start_value(::PSI.ReactivePowerVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_active_power(d)
PSI.get_variable_lower_bound(::PSI.ReactivePowerVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_active_power_limits(d).min
PSI.get_variable_upper_bound(::PSI.ReactivePowerVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_active_power_limits(d).max

############## PSI.EnergyVariable, HydroGen ####################
# These methods are defined in PowerSimulations
PSI.get_variable_binary(::PSI.EnergyVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_warm_start_value(::PSI.EnergyVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_initial_storage(d)
PSI.get_variable_lower_bound(::PSI.EnergyVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = 0.0
PSI.get_variable_upper_bound(::PSI.EnergyVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_storage_capacity(d)


########################### HydroEnergyVariableUp, HydroGen #################################
PSI.get_variable_binary(::HydroEnergyVariableUp, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_warm_start_value(::HydroEnergyVariableUp, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_initial_storage(d).up
PSI.get_variable_lower_bound(::HydroEnergyVariableUp, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = 0.0
PSI.get_variable_upper_bound(::HydroEnergyVariableUp, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_storage_capacity(d).up

########################### HydroEnergyVariableDown, HydroGen #################################
PSI.get_variable_binary(::HydroEnergyVariableDown, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_warm_start_value(::HydroEnergyVariableDown, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_initial_storage(d).down
PSI.get_variable_lower_bound(::HydroEnergyVariableDown, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = 0.0
PSI.get_variable_upper_bound(::HydroEnergyVariableDown, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_storage_capacity(d).down

########################### PSI.ActivePowerInVariable, HydroGen #################################
PSI.get_variable_binary(::PSI.ActivePowerInVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_lower_bound(::PSI.ActivePowerInVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = 0.0
PSI.get_variable_upper_bound(::PSI.ActivePowerInVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = nothing
PSI.get_variable_multiplier(::PSI.ActivePowerInVariable, d::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = -1.0

########################### PSI.ActivePowerOutVariable, HydroGen #################################
PSI.get_variable_binary(::PSI.ActivePowerOutVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_lower_bound(::PSI.ActivePowerOutVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = 0.0
PSI.get_variable_upper_bound(::PSI.ActivePowerOutVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = nothing
PSI.get_variable_multiplier(::PSI.ActivePowerOutVariable, d::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = 1.0

############## PSI.OnVariable, HydroGen ####################
# These methods are defined in PowerSimulations
PSI.get_variable_binary(::PSI.OnVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = true
PSI.get_variable_binary(::PSI.OnVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroUnitCommitment) = true
PSI.get_variable_warm_start_value(::PSI.OnVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_active_power(d) > 0 ? 1.0 : 0.0

############## WaterSpillageVariable, HydroGen ####################
PSI.get_variable_binary(::WaterSpillageVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_lower_bound(::WaterSpillageVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = 0.0

############## PSI.ReservationVariable, HydroGen ####################
PSI.get_variable_binary(::PSI.ReservationVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = true
PSI.get_variable_binary(::PSI.ReservationVariable, ::Type{<:PSY.HydroPumpedStorage}, ::AbstractHydroReservoirFormulation) = true

############## EnergyShortageVariable, HydroGen ####################
PSI.get_variable_binary(::HydroEnergyShortageVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_lower_bound(::HydroEnergyShortageVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = 0.0
PSI.get_variable_upper_bound(::HydroEnergyShortageVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_storage_capacity(d)
PSI.get_variable_upper_bound(::HydroEnergyShortageVariable, d::PSY.HydroPumpedStorage, ::AbstractHydroReservoirFormulation) = PSY.get_storage_capacity(d).up

############## HydroEnergySurplusVariable, HydroGen ####################
PSI.get_variable_binary(::HydroEnergySurplusVariable, ::Type{<:PSY.HydroGen}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_upper_bound(::HydroEnergySurplusVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = 0.0
PSI.get_variable_lower_bound(::HydroEnergySurplusVariable, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = - PSY.get_storage_capacity(d)
PSI.get_variable_lower_bound(::HydroEnergySurplusVariable, d::PSY.HydroPumpedStorage, ::AbstractHydroReservoirFormulation) = - PSY.get_storage_capacity(d).up
########################### Parameter related set functions ################################
PSI.get_multiplier_value(::EnergyBudgetTimeSeriesParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_max_active_power(d)
PSI.get_multiplier_value(::EnergyBudgetTimeSeriesParameter, d::PSY.HydroEnergyReservoir, ::AbstractHydroFormulation) = PSY.get_storage_capacity(d)
PSI.get_multiplier_value(::EnergyTargetTimeSeriesParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_storage_capacity(d)
PSI.get_multiplier_value(::InflowTimeSeriesParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_inflow(d) * PSY.get_conversion_factor(d)
PSI.get_multiplier_value(::OutflowTimeSeriesParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_outflow(d) * PSY.get_conversion_factor(d)
PSI.get_multiplier_value(::PSI.TimeSeriesParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_max_active_power(d)
PSI.get_multiplier_value(::PSI.TimeSeriesParameter, d::PSY.HydroGen, ::PSI.FixedOutput) = PSY.get_max_active_power(d)

PSI.get_parameter_multiplier(::PSI.VariableValueParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = 1.0
PSI.get_initial_parameter_value(::PSI.VariableValueParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = 1.0
PSI.get_expression_multiplier(::PSI.OnStatusParameter, ::PSI.ActivePowerRangeExpressionUB, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_active_power_limits(d).max
PSI.get_expression_multiplier(::PSI.OnStatusParameter, ::PSI.ActivePowerRangeExpressionLB, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_active_power_limits(d).min

#################### Initial Conditions for models ###############
PSI.initial_condition_default(::PSI.DeviceStatus, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_status(d)
PSI.initial_condition_variable(::PSI.DeviceStatus, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSI.OnVariable()
PSI.initial_condition_default(::PSI.DevicePower, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_active_power(d)
PSI.initial_condition_variable(::PSI.DevicePower, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSI.ActivePowerVariable()
PSI.initial_condition_default(::PSI.InitialEnergyLevel, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_initial_storage(d)
PSI.initial_condition_variable(::PSI.InitialEnergyLevel, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSI.EnergyVariable()
PSI.initial_condition_default(::InitialHydroEnergyLevelUp, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_initial_storage(d).up
PSI.initial_condition_variable(::InitialHydroEnergyLevelUp, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = HydroEnergyVariableUp()
PSI.initial_condition_default(::InitialHydroEnergyLevelDown, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_initial_storage(d).down
PSI.initial_condition_variable(::InitialHydroEnergyLevelDown, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = HydroEnergyVariableDown()
PSI.initial_condition_default(::PSI.InitialTimeDurationOn, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_status(d) ? PSY.get_time_at_status(d) :  0.0
PSI.initial_condition_variable(::PSI.InitialTimeDurationOn, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSI.OnVariable()
PSI.initial_condition_default(::PSI.InitialTimeDurationOff, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSY.get_status(d) ? 0.0 : PSY.get_time_at_status(d)
PSI.initial_condition_variable(::PSI.InitialTimeDurationOff, d::PSY.HydroGen, ::AbstractHydroReservoirFormulation) = PSI.OnVariable()

########################Objective Function##################################################
PSI.proportional_cost(cost::Nothing, ::PSY.HydroGen, ::PSI.ActivePowerVariable, ::AbstractHydroFormulation)=0.0
PSI.proportional_cost(cost::PSY.OperationalCost, ::PSI.OnVariable, ::PSY.HydroGen, ::AbstractHydroFormulation)=PSY.get_fixed(cost)
PSI.proportional_cost(cost::PSY.StorageManagementCost, ::HydroEnergySurplusVariable, ::PSY.HydroGen, ::AbstractHydroReservoirFormulation)=PSY.get_energy_surplus_cost(cost)
PSI.proportional_cost(cost::PSY.StorageManagementCost, ::HydroEnergyShortageVariable, ::PSY.HydroGen, ::AbstractHydroReservoirFormulation)=PSY.get_energy_shortage_cost(cost)

PSI.objective_function_multiplier(::PSI.ActivePowerVariable, ::AbstractHydroFormulation)=PSI.OBJECTIVE_FUNCTION_POSITIVE
PSI.objective_function_multiplier(::PSI.ActivePowerOutVariable, ::HydroDispatchPumpedStorage)=PSI.OBJECTIVE_FUNCTION_POSITIVE
PSI.objective_function_multiplier(::PSI.OnVariable, ::AbstractHydroFormulation)=PSI.OBJECTIVE_FUNCTION_POSITIVE
PSI.objective_function_multiplier(::HydroEnergySurplusVariable, ::AbstractHydroReservoirFormulation)=PSI.OBJECTIVE_FUNCTION_NEGATIVE
PSI.objective_function_multiplier(::HydroEnergyShortageVariable, ::AbstractHydroReservoirFormulation)=PSI.OBJECTIVE_FUNCTION_POSITIVE

PSI.sos_status(::PSY.HydroGen, ::AbstractHydroReservoirFormulation)=PSI.SOSStatusVariable.NO_VARIABLE
PSI.sos_status(::PSY.HydroGen, ::AbstractHydroUnitCommitment)=PSI.SOSStatusVariable.VARIABLE

PSI.variable_cost(::Nothing, ::PSI.ActivePowerVariable, ::PSY.HydroGen, ::AbstractHydroReservoirFormulation)=0.0
PSI.variable_cost(cost::PSY.OperationalCost, ::PSI.ActivePowerVariable, ::PSY.HydroGen, ::AbstractHydroFormulation)=PSY.get_variable(cost)
PSI.variable_cost(cost::PSY.OperationalCost, ::PSI.ActivePowerOutVariable, ::PSY.HydroPumpedStorage, ::HydroDispatchPumpedStorage)=PSY.get_variable(cost)

#! format: on

# These methods are defined in PowerSimulations
function PSI.get_initial_conditions_device_model(
    ::PSI.OperationModel,
    model::PSI.DeviceModel{T, <:AbstractHydroReservoirFormulation},
) where {T <: PSY.HydroEnergyReservoir}
    return model
end

# These methods are defined in PowerSimulations
function PSI.get_initial_conditions_device_model(
    ::PSI.OperationModel,
    model::PSI.DeviceModel{T, <:AbstractHydroDispatchFormulation},
) where {T <: PSY.HydroGen}
    return model
end

# TODO: This method is up for elimination
function PSI.get_initial_conditions_device_model(
    ::PSI.OperationModel,
    ::PSI.DeviceModel{T, <:AbstractHydroReservoirFormulation},
) where {T <: PSY.HydroDispatch}
    return PSI.DeviceModel(PSY.HydroDispatch, HydroDispatchRunOfRiver)
end

function PSI.get_initial_conditions_device_model(
    ::PSI.OperationModel,
    ::PSI.DeviceModel{T, <:AbstractHydroUnitCommitment},
) where {T <: PSY.HydroGen}
    return PSI.DeviceModel(T, HydroCommitmentRunOfRiver)
end

function PSI.get_initial_conditions_device_model(
    ::PSI.OperationModel,
    ::PSI.DeviceModel{PSY.HydroPumpedStorage, <:AbstractHydroReservoirFormulation},
)
    return PSI.DeviceModel(PSY.HydroPumpedStorage, HydroDispatchPumpedStorage)
end

function PSI.get_default_time_series_names(
    ::Type{<:PSY.HydroGen},
    ::Type{
        <:Union{
            PSI.FixedOutput,
            AbstractHydroDispatchFormulation,
            AbstractHydroUnitCommitment,
        },
    },
)
    return Dict{Type{<:PSI.TimeSeriesParameter}, String}(
        PSI.ActivePowerTimeSeriesParameter => "max_active_power",
        PSI.ReactivePowerTimeSeriesParameter => "max_active_power",
    )
end

function PSI.get_default_time_series_names(
    ::Type{PSY.HydroEnergyReservoir},
    ::Type{<:Union{HydroCommitmentReservoirBudget, HydroDispatchReservoirBudget}},
)
    return Dict{Type{<:PSI.TimeSeriesParameter}, String}(
        EnergyBudgetTimeSeriesParameter => "hydro_budget",
    )
end

function PSI.get_default_time_series_names(
    ::Type{PSY.HydroEnergyReservoir},
    ::Type{<:Union{HydroDispatchReservoirStorage, HydroCommitmentReservoirStorage}},
)
    return Dict{Type{<:PSI.TimeSeriesParameter}, String}(
        EnergyTargetTimeSeriesParameter => "storage_target",
        InflowTimeSeriesParameter => "inflow",
    )
end

function PSI.get_default_time_series_names(
    ::Type{PSY.HydroPumpedStorage},
    ::Type{<:HydroDispatchPumpedStorage},
)
    return Dict{Type{<:PSI.TimeSeriesParameter}, String}(
        InflowTimeSeriesParameter => "inflow",
        OutflowTimeSeriesParameter => "outflow",
    )
end

function PSI.get_default_attributes(
    ::Type{T},
    ::Type{D},
) where {T <: PSY.HydroGen, D <: Union{PSI.FixedOutput, AbstractHydroFormulation}}
    return Dict{String, Any}("reservation" => false)
end

function PSI.get_default_attributes(
    ::Type{T},
    ::Type{D},
) where {T <: PSY.HydroGen, D <: AbstractHydroUnitCommitment}
    return Dict{String, Any}("reservation" => false)
end

function PSI.get_default_attributes(
    ::Type{T},
    ::Type{D},
) where {T <: PSY.HydroGen, D <: AbstractHydroReservoirFormulation}
    return Dict{String, Any}("reservation" => false)
end

function PSI.get_default_attributes(
    ::Type{PSY.HydroPumpedStorage},
    ::Type{HydroDispatchPumpedStorage},
)
    return Dict{String, Any}("reservation" => true)
end

"""
Time series constraints
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:Union{PSI.VariableType, PSI.ExpressionType}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {V <: PSY.HydroGen, W <: HydroDispatchRunOfRiver, X <: PM.AbstractPowerModel}
    if !PSI.has_semicontinuous_feedforward(model, U)
        PSI.add_range_constraints!(container, T, U, devices, model, X)
    end
    PSI.add_parameterized_upper_bound_range_constraints(
        container,
        PSI.ActivePowerVariableTimeSeriesLimitsConstraint,
        U,
        PSI.ActivePowerTimeSeriesParameter,
        devices,
        model,
        X,
    )
    return
end

function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:PSI.RangeConstraintLBExpressions},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {V <: PSY.HydroGen, W <: HydroDispatchRunOfRiver, X <: PM.AbstractPowerModel}
    if !PSI.has_semicontinuous_feedforward(model, U)
        PSI.add_range_constraints!(container, T, U, devices, model, X)
    end
    return
end

"""
Add semicontinuous range constraints for Hydro Unit Commitment formulation
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:Union{PSI.VariableType, <:PSI.RangeConstraintLBExpressions}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {V <: PSY.HydroGen, W <: HydroCommitmentRunOfRiver, X <: PM.AbstractPowerModel}
    PSI.add_semicontinuous_range_constraints!(container, T, U, devices, model, X)
    return
end

function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.ActivePowerVariableLimitsConstraint},
    U::Type{<:Union{PSI.VariableType, PSI.ExpressionType}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {V <: PSY.HydroGen, W <: HydroCommitmentRunOfRiver, X <: PM.AbstractPowerModel}
    PSI.add_semicontinuous_range_constraints!(container, T, U, devices, model, X)
    PSI.add_parameterized_upper_bound_range_constraints(
        container,
        PSI.ActivePowerVariableTimeSeriesLimitsConstraint,
        U,
        PSI.ActivePowerTimeSeriesParameter,
        devices,
        model,
        X,
    )
    return
end

"""
Min and max reactive Power Variable limits
"""
function PSI.get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.ReactivePowerVariableLimitsConstraint},
    ::Type{<:AbstractHydroReservoirFormulation},
)
    return PSY.get_reactive_power_limits(x)
end

function PSI.get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.ReactivePowerVariableLimitsConstraint},
    ::Type{<:AbstractHydroDispatchFormulation},
)
    return PSY.get_reactive_power_limits(x)
end

function PSI.get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.ReactivePowerVariableLimitsConstraint},
    ::Type{<:AbstractHydroUnitCommitment},
)
    return PSY.get_reactive_power_limits(x)
end

"""
Min and max active Power Variable limits
"""
function PSI.get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.ActivePowerVariableLimitsConstraint},
    ::Type{<:AbstractHydroReservoirFormulation},
)
    return PSY.get_active_power_limits(x)
end

function PSI.get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.ActivePowerVariableLimitsConstraint},
    ::Type{<:HydroDispatchRunOfRiver},
)
    return (min=0.0, max=PSY.get_max_active_power(x))
end

"""
Min and max active Power Variable limits
"""
function PSI.get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.ActivePowerVariableLimitsConstraint},
    ::Type{<:AbstractHydroFormulation},
)
    return PSY.get_active_power_limits(x)
end

"""
Add power variable limits constraints for hydro unit commitment formulation
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{<:PSI.PowerVariableLimitsConstraint},
    U::Type{<:Union{PSI.VariableType, PSI.ExpressionType}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {V <: PSY.HydroGen, W <: AbstractHydroUnitCommitment, X <: PM.AbstractPowerModel}
    PSI.add_semicontinuous_range_constraints!(container, T, U, devices, model, X)
    return
end

"""
Add power variable limits constraints for hydro dispatch formulation
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{<:PSI.PowerVariableLimitsConstraint},
    U::Type{<:Union{PSI.VariableType, PSI.ExpressionType}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroGen,
    W <: AbstractHydroDispatchFormulation,
    X <: PM.AbstractPowerModel,
}
    if !PSI.has_semicontinuous_feedforward(model, U)
        PSI.add_range_constraints!(container, T, U, devices, model, X)
    end
    return
end

"""
Add input power variable limits constraints for hydro dispatch formulation
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{PSI.InputActivePowerVariableLimitsConstraint},
    U::Type{<:Union{PSI.VariableType, PSI.ExpressionType}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroPumpedStorage,
    W <: AbstractHydroReservoirFormulation,
    X <: PM.AbstractPowerModel,
}
    if PSI.get_attribute(model, "reservation")
        PSI.add_reserve_range_constraints!(container, T, U, devices, model, X)
    else
        if !PSI.has_semicontinuous_feedforward(model, U)
            PSI.add_range_constraints!(container, T, U, devices, model, X)
        end
    end
    return
end

"""
Add output power variable limits constraints for hydro dispatch formulation
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{<:PSI.PowerVariableLimitsConstraint},
    U::Type{<:Union{PSI.VariableType, PSI.ExpressionType}},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroPumpedStorage,
    W <: AbstractHydroReservoirFormulation,
    X <: PM.AbstractPowerModel,
}
    if PSI.get_attribute(model, "reservation")
        PSI.add_reserve_range_constraints!(container, T, U, devices, model, X)
    else
        if !PSI.has_semicontinuous_feedforward(model, U)
            PSI.add_range_constraints!(container, T, U, devices, model, X)
        end
    end
    return
end

"""
Min and max output active power variable limits for hydro dispatch pumped storage
"""
function PSI.get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.OutputActivePowerVariableLimitsConstraint},
    ::Type{HydroDispatchPumpedStorage},
)
    return PSY.get_active_power_limits(x)
end

"""
Min and max input active power variable limits for hydro dispatch pumped storage
"""
function PSI.get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.InputActivePowerVariableLimitsConstraint},
    ::Type{HydroDispatchPumpedStorage},
)
    return PSY.get_active_power_limits_pump(x)
end

######################## Energy balance constraints ############################

"""
This function defines the constraints for the water level (or state of charge)
for the Hydro Reservoir.
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{PSI.EnergyBalanceConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroEnergyReservoir,
    W <: AbstractHydroReservoirFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    resolution = PSI.get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    names = [PSY.get_name(x) for x in devices]
    initial_conditions = PSI.get_initial_condition(container, PSI.InitialEnergyLevel(), V)
    energy_var = PSI.get_variable(container, PSI.EnergyVariable(), V)
    power_var = PSI.get_variable(container, PSI.ActivePowerVariable(), V)
    spillage_var = PSI.get_variable(container, WaterSpillageVariable(), V)

    constraint = PSI.add_constraints_container!(
        container,
        PSI.EnergyBalanceConstraint(),
        V,
        names,
        time_steps,
    )
    param_container = PSI.get_parameter(container, InflowTimeSeriesParameter(), V)
    multiplier =
        PSI.get_parameter_multiplier_array(container, InflowTimeSeriesParameter(), V)

    for ic in initial_conditions
        device = PSI.get_component(ic)
        name = PSY.get_name(device)
        param = PSI.get_parameter_column_values(param_container, name)
        constraint[name, 1] = JuMP.@constraint(
            container.JuMPmodel,
            energy_var[name, 1] ==
            PSI.get_value(ic) - power_var[name, 1] * fraction_of_hour -
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
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{EnergyCapacityUpConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroPumpedStorage,
    W <: AbstractHydroReservoirFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    resolution = PSI.get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    names = [PSY.get_name(x) for x in devices]
    initial_conditions =
        PSI.get_initial_condition(container, InitialHydroEnergyLevelUp(), V)

    energy_var = PSI.get_variable(container, HydroEnergyVariableUp(), V)
    powerin_var = PSI.get_variable(container, PSI.ActivePowerInVariable(), V)
    powerout_var = PSI.get_variable(container, PSI.ActivePowerOutVariable(), V)
    spillage_var = PSI.get_variable(container, WaterSpillageVariable(), V)

    constraint = PSI.add_constraints_container!(
        container,
        EnergyCapacityUpConstraint(),
        V,
        names,
        time_steps,
    )
    param_container = PSI.get_parameter(container, InflowTimeSeriesParameter(), V)
    multiplier = PSI.get_multiplier_array(param_container)

    for ic in initial_conditions
        device = PSI.get_component(ic)
        efficiency = PSY.get_pump_efficiency(device)
        name = PSY.get_name(device)
        constraint[name, 1] = JuMP.@constraint(
            container.JuMPmodel,
            energy_var[name, 1] ==
            PSI.get_value(ic) +
            (
                powerin_var[name, 1] -
                (spillage_var[name, 1] + powerout_var[name, 1]) / efficiency
            ) * fraction_of_hour +
            PSI.get_parameter_column_refs(param_container, name)[1] * multiplier[name, 1]
            # Be consistent on this parameter definition
        )

        for t in time_steps[2:end]
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                energy_var[name, t] ==
                energy_var[name, t - 1] +
                PSI.get_parameter_column_refs(param_container, name)[t] *
                multiplier[name, t] +
                (
                    powerin_var[name, t] -
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
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{EnergyCapacityDownConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroPumpedStorage,
    W <: AbstractHydroReservoirFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    resolution = PSI.get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    names = [PSY.get_name(x) for x in devices]
    initial_conditions =
        PSI.get_initial_condition(container, InitialHydroEnergyLevelDown(), V)

    energy_var = PSI.get_variable(container, HydroEnergyVariableDown(), V)
    powerin_var = PSI.get_variable(container, PSI.ActivePowerInVariable(), V)
    powerout_var = PSI.get_variable(container, PSI.ActivePowerOutVariable(), V)
    spillage_var = PSI.get_variable(container, WaterSpillageVariable(), V)

    constraint = PSI.add_constraints_container!(
        container,
        EnergyCapacityDownConstraint(),
        V,
        names,
        time_steps,
    )

    param_container = PSI.get_parameter(container, OutflowTimeSeriesParameter(), V)
    multiplier = PSI.get_multiplier_array(param_container)

    for ic in initial_conditions
        device = PSI.get_component(ic)
        efficiency = PSY.get_pump_efficiency(device)
        name = PSY.get_name(device)
        param = PSI.get_parameter_column_refs(param_container, name)
        constraint[name, 1] = JuMP.@constraint(
            container.JuMPmodel,
            energy_var[name, 1] ==
            PSI.get_value(ic) -
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
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{EnergyTargetConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroGen,
    W <: AbstractHydroReservoirFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    set_name = [PSY.get_name(d) for d in devices]
    constraint = PSI.add_constraints_container!(
        container,
        EnergyTargetConstraint(),
        V,
        set_name,
        time_steps,
    )

    e_var = PSI.get_variable(container, PSI.EnergyVariable(), V)
    shortage_var = PSI.get_variable(container, HydroEnergyShortageVariable(), V)
    surplus_var = PSI.get_variable(container, HydroEnergySurplusVariable(), V)
    param_container = PSI.get_parameter(container, EnergyTargetTimeSeriesParameter(), V)
    multiplier =
        PSI.get_parameter_multiplier_array(container, EnergyTargetTimeSeriesParameter(), V)

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
        param = PSI.get_parameter_column_values(param_container, name)
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

function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{EnergyBudgetConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroGen,
    W <: AbstractHydroReservoirFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    set_name = [PSY.get_name(d) for d in devices]
    constraint =
        PSI.add_constraints_container!(container, EnergyBudgetConstraint(), V, set_name)

    variable_out = PSI.get_variable(container, PSI.ActivePowerVariable(), V)
    param_container = PSI.get_parameter(container, EnergyBudgetTimeSeriesParameter(), V)
    multiplier = PSI.get_multiplier_array(param_container)

    for d in devices
        name = PSY.get_name(d)
        param = PSI.get_parameter_column_values(param_container, name)
        constraint[name] = JuMP.@constraint(
            container.JuMPmodel,
            sum([variable_out[name, t] for t in time_steps]) <= sum([multiplier[name, t] * param[t] for t in time_steps])
        )
    end
    return
end

##################################### Auxillary Variables ############################
function PSI.calculate_aux_variable_value!(
    container::PSI.OptimizationContainer,
    ::PSI.AuxVarKey{HydroEnergyOutput, T},
    system::PSY.System,
) where {T <: PSY.HydroGen}
    devices = get_available_components(T, system)
    time_steps = PSI.get_time_steps(container)
    resolution = PSI.get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    p_variable_results = PSI.get_variable(container, PSI.ActivePowerVariable(), T)
    aux_variable_container = PSI.get_aux_variable(container, HydroEnergyOutput(), T)
    for d in devices, t in time_steps
        name = PSY.get_name(d)
        aux_variable_container[name, t] =
            PSI.jump_value(p_variable_results[name, t]) * fraction_of_hour
    end

    return
end

function PSI.calculate_aux_variable_value!(
    container::PSI.OptimizationContainer,
    ::PSI.AuxVarKey{HydroEnergyOutput, T},
    system::PSY.System,
) where {T <: PSY.HydroPumpedStorage}
    devices = get_available_components(T, system)
    time_steps = PSI.get_time_steps(container)
    resolution = PSI.get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    p_variable_results = PSI.get_variable(container, PSI.ActivePowerOutVariable(), T)
    aux_variable_container = PSI.get_aux_variable(container, HydroEnergyOutput(), T)
    for d in devices, t in time_steps
        name = PSY.get_name(d)
        aux_variable_container[name, t] =
            PSI.jump_value(p_variable_results[name, t]) * fraction_of_hour
    end

    return
end

function PSI.update_decision_state!(
    state::PSI.SimulationState,
    key::PSI.AuxVarKey{HydroEnergyOutput, T},
    store_data::PSI.DenseAxisArray{Float64, 2},
    simulation_time::Dates.DateTime,
    model_params::PSI.ModelStoreParams,
) where {T <: PSY.Component}
    state_data = PSI.get_decision_state_data(state, key)
    model_resolution = PSI.get_resolution(model_params)
    state_resolution = PSI.get_data_resolution(state_data)
    resolution_ratio = model_resolution ÷ state_resolution
    state_timestamps = state_data.timestamps
    IS.@assert_op resolution_ratio >= 1

    if simulation_time > PSI.get_end_of_step_timestamp(state_data)
        state_data_index = 1
        state_data.timestamps[:] .= range(
            simulation_time;
            step=state_resolution,
            length=PSI.get_num_rows(state_data),
        )
    else
        state_data_index = PSI.find_timestamp_index(state_timestamps, simulation_time)
    end

    offset = resolution_ratio - 1
    result_time_index = axes(store_data)[2]
    PSI.set_update_timestamp!(state_data, simulation_time)
    column_names = axes(state_data.values)[1]
    for t in result_time_index
        state_range = state_data_index:(state_data_index + offset)
        for name in column_names, i in state_range
            state_data.values[name, i] = store_data[name, t] / resolution_ratio
        end
        PSI.set_last_recorded_row!(state_data, state_range[end])
        state_data_index += resolution_ratio
    end

    return
end

##################################### Hydro generation cost ############################
function PSI.objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{T},
    ::PSI.DeviceModel{T, U},
    ::Type{<:PM.AbstractPowerModel},
) where {T <: PSY.HydroGen, U <: AbstractHydroUnitCommitment}
    PSI.add_variable_cost!(container, PSI.ActivePowerVariable(), devices, U())
    PSI.add_proportional_cost!(container, PSI.OnVariable(), devices, U())
    return
end

function PSI.objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{T},
    ::PSI.DeviceModel{T, U},
    ::Type{<:PM.AbstractPowerModel},
) where {T <: PSY.HydroGen, U <: AbstractHydroDispatchFormulation}
    PSI.add_variable_cost!(container, PSI.ActivePowerVariable(), devices, U())
    return
end

function PSI.objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{PSY.HydroPumpedStorage},
    ::PSI.DeviceModel{PSY.HydroPumpedStorage, T},
    ::Type{<:PM.AbstractPowerModel},
) where {T <: HydroDispatchPumpedStorage}
    PSI.add_variable_cost!(container, PSI.ActivePowerOutVariable(), devices, T())
    return
end

function PSI.objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{T},
    ::PSI.DeviceModel{T, U},
    ::Type{<:PM.AbstractPowerModel},
) where {
    T <: PSY.HydroPumpedStorage,
    U <: Union{HydroDispatchReservoirStorage, HydroDispatchReservoirBudget},
}
    PSI.add_variable_cost!(container, PSI.ActivePowerOutVariable(), devices, U())
    PSI.add_proportional_cost!(container, HydroEnergySurplusVariable(), devices, U())
    PSI.add_proportional_cost!(container, HydroEnergyShortageVariable(), devices, U())
    return
end

function PSI.objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{T},
    ::PSI.DeviceModel{T, U},
    ::Type{<:PM.AbstractPowerModel},
) where {T <: PSY.HydroEnergyReservoir, U <: HydroDispatchReservoirStorage}
    PSI.add_variable_cost!(container, PSI.ActivePowerVariable(), devices, U())
    PSI.add_proportional_cost!(container, HydroEnergySurplusVariable(), devices, U())
    PSI.add_proportional_cost!(container, HydroEnergyShortageVariable(), devices, U())
    return
end

function PSI.objective_function!(
    container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{T},
    ::PSI.DeviceModel{T, U},
    ::Type{<:PM.AbstractPowerModel},
) where {T <: PSY.HydroEnergyReservoir, U <: HydroCommitmentReservoirStorage}
    PSI.add_variable_cost!(container, PSI.ActivePowerVariable(), devices, U())
    PSI.add_proportional_cost!(container, HydroEnergySurplusVariable(), devices, U())
    PSI.add_proportional_cost!(container, HydroEnergyShortageVariable(), devices, U())
    return
end

function PSI.add_proportional_cost!(
    container::PSI.OptimizationContainer,
    ::U,
    devices::IS.FlattenIteratorWrapper{T},
    ::V,
) where {
    T <: PSY.Component,
    U <: Union{HydroEnergySurplusVariable, HydroEnergyShortageVariable},
    V <: PSI.AbstractDeviceFormulation,
}
    base_p = PSI.get_base_power(container)
    multiplier = PSI.objective_function_multiplier(U(), V())
    for d in devices
        op_cost_data = PSY.get_operation_cost(d)
        cost_term = PSI.proportional_cost(op_cost_data, U(), d, V())
        iszero(cost_term) && continue
        for t in PSI.get_time_steps(container)
            PSI._add_proportional_term!(
                container,
                U(),
                d,
                cost_term * multiplier * base_p,
                t,
            )
        end
    end
    return
end

function PSI.update_initial_conditions!(
    ics::Vector{T},
    store::PSI.EmulationModelStore,
    ::Dates.Millisecond,
) where {
    T <: PSI.InitialCondition{InitialHydroEnergyLevelUp, S},
} where {S <: Union{Float64, JuMP.VariableRef}}
    for ic in ics
        var_val = PSI.get_variable_value(
            store,
            HydroEnergyVariableUp(),
            PSI.get_component_type(ic),
        )
        PSI.set_ic_quantity!(
            ic,
            PSI.get_last_recorded_value(var_val)[PSI.get_component_name(ic)],
        )
    end
    return
end

function PSI.update_initial_conditions!(
    ics::Vector{T},
    store::PSI.EmulationModelStore,
    ::Dates.Millisecond,
) where {
    T <: PSI.InitialCondition{InitialHydroEnergyLevelDown, S},
} where {S <: Union{Float64, JuMP.VariableRef}}
    for ic in ics
        var_val = PSI.get_variable_value(
            store,
            HydroEnergyVariableDown(),
            PSI.get_component_type(ic),
        )
        PSI.set_ic_quantity!(
            ic,
            PSI.get_last_recorded_value(var_val)[PSI.get_component_name(ic)],
        )
    end
    return
end

function PSI.update_initial_conditions!(
    ics::Vector{T},
    state::PSI.SimulationState,
    ::Dates.Millisecond,
) where {
    T <: PSI.InitialCondition{InitialHydroEnergyLevelUp, S},
} where {S <: Union{Float64, JuMP.VariableRef}}
    for ic in ics
        var_val = PSI.get_system_state_value(
            state,
            HydroEnergyVariableUp(),
            PSI.get_component_type(ic),
        )
        PSI.set_ic_quantity!(ic, var_val[PSI.get_component_name(ic)])
    end
    return
end

function PSI.update_initial_conditions!(
    ics::Vector{T},
    state::PSI.SimulationState,
    ::Dates.Millisecond,
) where {
    T <: PSI.InitialCondition{InitialHydroEnergyLevelDown, S},
} where {S <: Union{Float64, JuMP.VariableRef}}
    for ic in ics
        var_val = PSI.get_system_state_value(
            state,
            HydroEnergyVariableDown(),
            PSI.get_component_type(ic),
        )
        PSI.set_ic_quantity!(ic, var_val[PSI.get_component_name(ic)])
    end
    return
end

function PSI._get_initial_conditions_value(
    ::Vector{T},
    component::W,
    ::U,
    ::V,
    container::PSI.OptimizationContainer,
) where {
    T <: PSI.InitialCondition{U, JuMP.VariableRef},
    V <: AbstractHydroReservoirFormulation,
    W <: PSY.Component,
} where {U <: Union{InitialHydroEnergyLevelUp, InitialHydroEnergyLevelDown}}
    var_type = PSI.initial_condition_variable(U(), component, V())
    val = PSI.initial_condition_default(U(), component, V())
    @debug "Device $(PSY.get_name(component)) initialized PSI.DeviceStatus as $var_type" _group =
        PSI.LOG_GROUP_BUILD_INITIAL_CONDITIONS
    return T(component, PSI.add_jump_parameter(PSI.get_jump_model(container), val))
end

function PSI._get_initial_conditions_value(
    ::Vector{T},
    component::W,
    ::U,
    ::V,
    container::PSI.OptimizationContainer,
) where {
    T <: PSI.InitialCondition{U, Float64},
    V <: AbstractHydroReservoirFormulation,
    W <: PSY.HydroGen,
} where {U <: Union{InitialHydroEnergyLevelUp, InitialHydroEnergyLevelDown}}
    var_type = PSI.initial_condition_variable(U(), component, V())
    val = PSI.initial_condition_default(U(), component, V())
    @debug "Device $(PSY.get_name(component)) initialized PSI.DeviceStatus as $var_type" _group =
        PSI.LOG_GROUP_BUILD_INITIAL_CONDITIONS
    return T(component, val)
end
