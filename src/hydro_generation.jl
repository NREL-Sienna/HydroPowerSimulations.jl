#! format: off
# These methods are defined in PowerSimulations
PSI.requires_initialization(::AbstractHydroReservoirFormulation) = false
PSI.requires_initialization(::AbstractHydroUnitCommitment) = true

PSI.get_variable_multiplier(_, ::Type{<:PSY.HydroGen}, ::AbstractHydroFormulation) = 1.0
PSI.get_expression_type_for_reserve(::PSI.ActivePowerReserveVariable, ::Type{<:PSY.HydroGen}, ::Type{<:PSY.Reserve{PSY.ReserveUp}}) = PSI.ActivePowerRangeExpressionUB
PSI.get_expression_type_for_reserve(::PSI.ActivePowerReserveVariable, ::Type{<:PSY.HydroGen}, ::Type{<:PSY.Reserve{PSY.ReserveDown}}) = PSI.ActivePowerRangeExpressionLB
PSI.get_expression_type_for_reserve(::PSI.ActivePowerReserveVariable, ::Type{PSY.HydroPumpedStorage}, ::Type{<:PSY.Reserve{PSY.ReserveUp}}) = ReserveRangeExpressionUB
PSI.get_expression_type_for_reserve(::PSI.ActivePowerReserveVariable, ::Type{PSY.HydroPumpedStorage}, ::Type{<:PSY.Reserve{PSY.ReserveDown}}) = ReserveRangeExpressionLB

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
PSI.get_variable_binary(::WaterSpillageVariable, ::Type{<:PSY.HydroReservoir}, ::AbstractHydroReservoirFormulation) = false
function PSI.get_variable_lower_bound(::WaterSpillageVariable, d::PSY.HydroReservoir, ::AbstractHydroReservoirFormulation)
   spillage_limits = PSY.get_spillage_limits(d)
   if typeof(spillage_limits) <: PSY.MinMax
       return PSY.get_spillage_limits(d).min
   end
   return 0.0  
end
function PSI.get_variable_upper_bound(::WaterSpillageVariable, d::PSY.HydroReservoir, ::AbstractHydroReservoirFormulation)
    spillage_limits = PSY.get_spillage_limits(d)
    if typeof(spillage_limits) <: PSY.MinMax
        return PSY.get_spillage_limits(d).max
    end
    return nothing
 end
    

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


############## HydroReservoir ####################
PSI.get_variable_binary(::WaterSpillageVariable, ::Type{<:PSY.HydroReservoir}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_binary(::HydroEnergyVariableUp, ::Type{<:PSY.HydroReservoir}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_lower_bound(::HydroEnergyVariableUp, d::PSY.HydroReservoir, ::AbstractHydroReservoirFormulation) = PSY.get_storage_level_limits(d).min
PSI.get_variable_upper_bound(::HydroEnergyVariableUp, d::PSY.HydroReservoir, ::AbstractHydroReservoirFormulation) = PSY.get_storage_level_limits(d).max
PSI.get_variable_lower_bound(::WaterSpillageVariable, d::PSY.HydroReservoir, ::AbstractHydroReservoirFormulation) = isnothing(PSY.get_spillage_limits(d)) ? 0.0 : PSY.get_spillage_limits(d).min
PSI.get_variable_upper_bound(::WaterSpillageVariable, d::PSY.HydroReservoir, ::AbstractHydroReservoirFormulation) = isnothing(PSY.get_spillage_limits(d)) ? nothing : PSY.get_spillage_limits(d).max

############## HydroTurbine ####################
PSI.get_variable_binary(::HydroTurbineFlowRateVariable, ::Type{<:PSY.HydroTurbine}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_binary(::PSI.ActivePowerVariable, ::Type{<:PSY.HydroTurbine}, ::AbstractHydroReservoirFormulation) = false
PSI.get_variable_lower_bound(::HydroTurbineFlowRateVariable, d::PSY.HydroTurbine, ::AbstractHydroReservoirFormulation) = isnothing(PSY.get_outflow_limits(d)) ? 0.0 : PSY.get_outflow_limits(d).min
PSI.get_variable_upper_bound(::HydroTurbineFlowRateVariable, d::PSY.HydroTurbine, ::AbstractHydroReservoirFormulation) = isnothing(PSY.get_outflow_limits(d)) ? nothing : PSY.get_outflow_limits(d).max

############## HydroReservoirHeadVariable, HydroReservoir ####################
PSI.get_variable_binary(::HydroReservoirHeadVariable, ::Type{PSY.HydroReservoir}, ::AbstractHydroFormulation) = false
function PSI.get_variable_upper_bound(::HydroReservoirHeadVariable, d::PSY.HydroReservoir, ::AbstractHydroFormulation)
    if PSY.get_level_data_type(d) == PSY.ReservoirDataType.HEAD
        head_limits = PSY.get_storage_level_limits(d)
        if typeof(head_limits) <: PSY.MinMax
            return PSY.get_storage_level_limits(d).max
        end
    end
    return nothing
end
function PSI.get_variable_lower_bound(::HydroReservoirHeadVariable, d::PSY.HydroReservoir, ::AbstractHydroFormulation)
    if PSY.get_level_data_type(d) == PSY.ReservoirDataType.HEAD
        head_limits = PSY.get_storage_level_limits(d)
        if typeof(head_limits) <: PSY.MinMax
            return PSY.get_storage_level_limits(d).min
        end
    end
    return 0.0
end
PSI.get_variable_lower_bound(::HydroTurbineFlowRateVariable, d::PSY.HydroTurbine, ::AbstractHydroReservoirFormulation) = isnothing(PSY.get_outflow_limits(d)) ? nothing : PSY.get_outflow_limits(d).max

############## HydroReservoirVolumeVariable, HydroReservoir ####################
PSI.get_variable_binary(::HydroReservoirVolumeVariable, ::Type{PSY.HydroReservoir}, ::AbstractHydroFormulation) = false
function PSI.get_variable_upper_bound(::HydroReservoirVolumeVariable, d::PSY.HydroReservoir, ::AbstractHydroFormulation)
    if PSY.get_level_data_type(d) == PSY.ReservoirDataType.VOLUME
        head_limits = PSY.get_storage_level_limits(d)
        if typeof(head_limits) <: PSY.MinMax
            return PSY.get_storage_level_limits(d).max
        end
    end
    return nothing
end
function PSI.get_variable_lower_bound(::HydroReservoirVolumeVariable, d::PSY.HydroReservoir, ::AbstractHydroFormulation)
    if PSY.get_level_data_type(d) == PSY.ReservoirDataType.VOLUME
        head_limits = PSY.get_storage_level_limits(d)
        if typeof(head_limits) <: PSY.MinMax
            return PSY.get_storage_level_limits(d).min
        end
    end
    return 0.0
end

########################### Parameter related set functions ################################
PSI.get_multiplier_value(::EnergyBudgetTimeSeriesParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_max_active_power(d)
PSI.get_multiplier_value(::EnergyBudgetTimeSeriesParameter, d::PSY.HydroEnergyReservoir, ::AbstractHydroFormulation) = PSY.get_storage_capacity(d)
PSI.get_multiplier_value(::EnergyTargetTimeSeriesParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_storage_capacity(d)
PSI.get_multiplier_value(::InflowTimeSeriesParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_inflow(d) * PSY.get_conversion_factor(d)
PSI.get_multiplier_value(::OutflowTimeSeriesParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_outflow(d) * PSY.get_conversion_factor(d)
PSI.get_multiplier_value(::InflowTimeSeriesParameter, d::PSY.HydroReservoir, ::AbstractHydroFormulation) = 1.0
PSI.get_multiplier_value(::OutflowTimeSeriesParameter, d::PSY.HydroReservoir, ::AbstractHydroFormulation) = 1.0
PSI.get_multiplier_value(::PSI.TimeSeriesParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = PSY.get_max_active_power(d)
PSI.get_multiplier_value(::PSI.TimeSeriesParameter, d::PSY.HydroGen, ::PSI.FixedOutput) = PSY.get_max_active_power(d)
PSI.get_multiplier_value(::InflowTimeSeriesParameter, d::PSY.HydroReservoir, ::AbstractHydroFormulation) = 1.0
PSI.get_multiplier_value(::OutflowTimeSeriesParameter, d::PSY.HydroReservoir, ::AbstractHydroFormulation) = 1.0

PSI.get_parameter_multiplier(::PSI.VariableValueParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = 1.0
PSI.get_initial_parameter_value(::PSI.VariableValueParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = 1.0
PSI.get_initial_parameter_value(::HydroUsageLimitParameter, d::PSY.HydroGen, ::AbstractHydroFormulation) = 1e6 #unbounded
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
PSI.proportional_cost(cost::PSY.OperationalCost, ::HydroEnergySurplusVariable, ::PSY.HydroGen, ::AbstractHydroReservoirFormulation)=0.0
PSI.proportional_cost(cost::PSY.OperationalCost, ::HydroEnergyShortageVariable, ::PSY.HydroGen, ::AbstractHydroReservoirFormulation)=0.0
PSI.proportional_cost(cost::PSY.StorageCost, ::HydroEnergySurplusVariable, ::PSY.HydroGen, ::AbstractHydroReservoirFormulation)=PSY.get_energy_surplus_cost(cost)
PSI.proportional_cost(cost::PSY.StorageCost, ::HydroEnergyShortageVariable, ::PSY.HydroGen, ::AbstractHydroReservoirFormulation)=PSY.get_energy_shortage_cost(cost)

PSI.objective_function_multiplier(::PSI.ActivePowerVariable, ::AbstractHydroFormulation)=PSI.OBJECTIVE_FUNCTION_POSITIVE
PSI.objective_function_multiplier(::PSI.ActivePowerOutVariable, ::HydroDispatchPumpedStorage)=PSI.OBJECTIVE_FUNCTION_POSITIVE
PSI.objective_function_multiplier(::PSI.OnVariable, ::AbstractHydroFormulation)=PSI.OBJECTIVE_FUNCTION_POSITIVE
PSI.objective_function_multiplier(::HydroEnergySurplusVariable, ::AbstractHydroReservoirFormulation)=PSI.OBJECTIVE_FUNCTION_NEGATIVE
PSI.objective_function_multiplier(::HydroEnergyShortageVariable, ::AbstractHydroReservoirFormulation)=PSI.OBJECTIVE_FUNCTION_POSITIVE

# PSI.objective_function_multiplier(::PSI.ActivePowerOutVariable, ::HydroEnergyBlockOptimization)=PSI.OBJECTIVE_FUNCTION_POSITIVE

PSI.sos_status(::PSY.HydroGen, ::AbstractHydroReservoirFormulation)=PSI.SOSStatusVariable.NO_VARIABLE
PSI.sos_status(::PSY.HydroGen, ::AbstractHydroUnitCommitment)=PSI.SOSStatusVariable.VARIABLE

PSI.variable_cost(::Nothing, ::PSI.ActivePowerVariable, ::PSY.HydroGen, ::AbstractHydroReservoirFormulation)=0.0
PSI.variable_cost(cost::PSY.OperationalCost, ::PSI.ActivePowerVariable, ::PSY.HydroGen, ::AbstractHydroFormulation)=PSY.get_variable(cost)
PSI.variable_cost(cost::PSY.OperationalCost, ::PSI.ActivePowerOutVariable, ::PSY.HydroPumpedStorage, ::HydroDispatchPumpedStorage)=PSY.get_variable(cost)

# PSI.variable_cost(cost::PSY.OperationalCost, ::PSI.ActivePowerOutVariable, ::PSY.HydroTurbine, ::AbstractHydroFormulation)=PSY.get_variable(cost)

PSI.variable_cost(cost::PSY.StorageCost, ::PSI.ActivePowerVariable, ::PSY.HydroGen, ::AbstractHydroFormulation)=PSY.get_discharge_variable_cost(cost)
PSI.variable_cost(cost::PSY.StorageCost, ::PSI.ActivePowerInVariable, ::PSY.HydroPumpedStorage, ::HydroDispatchPumpedStorage)=PSY.get_charge_variable_cost(cost)
PSI.variable_cost(cost::PSY.StorageCost, ::PSI.ActivePowerOutVariable, ::PSY.HydroPumpedStorage, ::HydroDispatchPumpedStorage)=PSY.get_discharge_variable_cost(cost)

const WATER_DENSITY = 1000
const GRAVITATIONAL_CONSTANT = 9.81

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

function PSI.get_default_time_series_names(
    ::Type{PSY.HydroReservoir},
    ::Type{<:HydroEnergyBlockOptimization},
)
    return Dict{Type{<:PSI.TimeSeriesParameter}, String}(
        InflowTimeSeriesParameter => "inflow",
        OutflowTimeSeriesParameter => "outflow",
    )
end

function PSI.get_default_time_series_names(
    ::Type{PSY.HydroReservoir},
    ::Type{<:HydroLongTermReservoir},
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
function PSI.get_default_attributes(
    ::Type{PSY.HydroReservoir},
    ::Type{HydroEnergyBlockOptimization},
)
    return Dict{String, Any}()
end

function PSI.get_default_attributes(
    ::Type{PSY.HydroReservoir},
    ::Type{HydroLongTermReservoir},
)
    return Dict{String, Any}()
end

############################################################################
############################### Variables ##################################
############################################################################

function PSI.add_variables!(
    container::PSI.OptimizationContainer,
    variable_type::Type{T},
    turbines::U,
    reservoirs::W,
    formulation::X,
) where {
    T <: HydroTurbineFlowRateVariable,
    U <: Union{Vector{D}, IS.FlattenIteratorWrapper{D}},
    W <: Union{Vector{E}, IS.FlattenIteratorWrapper{E}},
    X <: HydroTurbineBilinearDispatch,
} where {
    D <: PSY.HydroTurbine,
    E <: PSY.HydroReservoir,
}
    time_steps = PSI.get_time_steps(container)
    variable = PSI.add_variable_container!(
        container,
        variable_type(),
        D,
        [PSY.get_name(d) for d in turbines],
        [PSY.get_name(d) for d in reservoirs],
        time_steps,
    )

    for t in time_steps, d in turbines, r in reservoirs
        name = PSY.get_name(d)
        name_res = PSY.get_name(r)
        variable[name, name_res, t] = JuMP.@variable(
            PSI.get_jump_model(container),
            base_name = "$(T)_$(D)_{$(name), $(name_res), $(t)}",
        )

        ub = PSI.get_variable_upper_bound(variable_type(), d, formulation)
        ub !== nothing && JuMP.set_upper_bound(variable[name, name_res, t], ub)

        lb = PSI.get_variable_lower_bound(variable_type(), d, formulation)
        lb !== nothing && JuMP.set_lower_bound(variable[name, name_res, t], lb)
    end
end

############################################################################
############################### Constraints ################################
############################################################################

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
Add semicontinuous range constraints for [`HydroCommitmentRunOfRiver`](@ref) formulation
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
    return (min = 0.0, max = PSY.get_max_active_power(x))
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
Add power variable limits constraints for abstract hydro unit commitment formulations
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
Add power variable limits constraints for abstract hydro dispatch formulations
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
Add input power variable limits constraints for abstract hydro dispatch formulations
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
Add output power variable limits constraints for abstract hydro dispatch formulations
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
Min and max output active power variable limits for [`HydroDispatchPumpedStorage`](@ref)
"""
function PSI.get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.OutputActivePowerVariableLimitsConstraint},
    ::Type{HydroDispatchPumpedStorage},
)
    return PSY.get_active_power_limits(x)
end

"""
Min and max input active power variable limits for [`HydroDispatchPumpedStorage`](@ref)
"""
function PSI.get_min_max_limits(
    x::PSY.HydroGen,
    ::Type{<:PSI.InputActivePowerVariableLimitsConstraint},
    ::Type{HydroDispatchPumpedStorage},
)
    return PSY.get_active_power_limits_pump(x)
end

######################## Energy Limits Constraints #############################

function _add_output_limit_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{PSI.OutputActivePowerVariableLimitsConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    network_model::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroPumpedStorage,
    W <: AbstractHydroReservoirFormulation,
    X <: PM.AbstractPowerModel,
}
    if !PSI.has_service_model(model)
        PSI.add_constraints!(
            container,
            PSI.OutputActivePowerVariableLimitsConstraint,
            PSI.ActivePowerOutVariable,
            devices,
            model,
            network_model,
        )
    else
        if PSI.get_attribute(model, "reservation")
            array_lb = PSI.get_expression(
                container,
                ReserveRangeExpressionLB(),
                PSY.HydroPumpedStorage,
            )
            PSI._add_reserve_lower_bound_range_constraints_impl!(
                container,
                PSI.OutputActivePowerVariableLimitsConstraint,
                array_lb,
                devices,
                model,
            )
            array_ub = PSI.get_expression(
                container,
                ReserveRangeExpressionUB(),
                PSY.HydroPumpedStorage,
            )
            PSI._add_reserve_upper_bound_range_constraints_impl!(
                container,
                PSI.OutputActivePowerVariableLimitsConstraint,
                array_ub,
                devices,
                model,
            )
        else
            array_lb = PSI.get_expression(
                container,
                ReserveRangeExpressionLB(),
                PSY.HydroPumpedStorage,
            )
            PSI._add_lower_bound_range_constraints_impl!(
                container,
                PSI.OutputActivePowerVariableLimitsConstraint,
                array_lb,
                devices,
                model,
            )
            array_ub = PSI.get_expression(
                container,
                ReserveRangeExpressionUB(),
                PSY.HydroPumpedStorage,
            )
            PSI._add_upper_bound_range_constraints_impl!(
                container,
                PSI.OutputActivePowerVariableLimitsConstraint,
                array_ub,
                devices,
                model,
            )
        end
    end
end
function _add_output_limits_with_reserves!(
    container::PSI.OptimizationContainer,
    ::Type{PSI.OutputActivePowerVariableLimitsConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    network_model::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroPumpedStorage,
    W <: AbstractHydroReservoirFormulation,
    X <: PM.AbstractPowerModel,
} end

######################## Energy balance constraints ############################

"""
This function defines the constraints for the water level (or state of charge)
for the [`PowerSystems.HydroEnergyReservoir`](@extref).
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
for the [`PowerSystems.HydroPumpedStorage`](@extref).
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
Add energy capacity down constraints for [`PowerSystems.HydroPumpedStorage`](@extref)
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
Add energy target constraints for [`PowerSystems.HydroGen`](@extref)
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
        if isa(cost_data, PSY.StorageCost)
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

##################################### Energy Block Optimization ############################
"""
This function defines the constraint for the hydro power generation
for the [`HydroEnergyBlockOptimization`](@extref).
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{HydroPowerConstraint},
    devices::IS.FlattenIteratorWrapper{PSY.HydroTurbine},
    model::PSI.DeviceModel{PSY.HydroTurbine, W},
    ::PSI.NetworkModel{X},
) where {
    W <: AbstractHydroReservoirFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    resolution = PSI.get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    names = [PSY.get_name(x) for x in devices]

    energy_var = PSI.get_variable(container, HydroEnergyVariableUp(), PSY.HydroReservoir)
    turbined_out_flow_var =
        PSI.get_variable(container, HydroTurbineFlowRateVariable(), PSY.HydroTurbine)

    hydro_power = PSI.get_variable(container, PSI.ActivePowerVariable(), PSY.HydroTurbine)

    constraint = PSI.add_constraints_container!(
        container,
        HydroPowerConstraint(),
        PSY.HydroTurbine,
        names,
        time_steps,
    )

    base_power = PSI.get_base_power(container)
    t_first = first(time_steps)
    t_final = last(time_steps)

    for d in devices
        name = PSY.get_name(d)

        ##TODO: fix for mutiplple turbine-reservoir mapping
        reservoir = only(PSY.get_reservoirs(d))
        reservoir_name = PSY.get_name(reservoir)
        initial_level = PSY.get_initial_level(reservoir)
        max_storage_level = PSY.get_storage_level_limits(reservoir).max

        efficiency = PSY.get_efficiency(d)
        head_to_volume_factor = PSY.get_head_to_volume_factor(reservoir)

        #TODO: K2 assumes difference of reference height to penstock (H0) and height to river level (Hd) = 1
        # H0-Hd = 1.0 m
        K1 = (efficiency * WATER_DENSITY * GRAVITATIONAL_CONSTANT) * head_to_volume_factor
        K2 = (efficiency * WATER_DENSITY * GRAVITATIONAL_CONSTANT) / (1.0)

        constraint[name, t_first] = JuMP.@constraint(
            container.JuMPmodel,
            hydro_power[name, t_first] ==
            fraction_of_hour * (
                turbined_out_flow_var[name, t_first] *
                (0.5 * K1 * (energy_var[reservoir_name, t_first] + initial_level) + K2)
            ) / base_power
        )
        for t in time_steps[(t_first + 1):t_final]
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                hydro_power[name, t] ==
                fraction_of_hour * (
                    turbined_out_flow_var[name, t] * (
                        0.5 * K1 *
                        (energy_var[reservoir_name, t] + energy_var[reservoir_name, t - 1]) + K2
                    )
                ) / base_power
            )
        end
    end
    return
end

"""
This function defines the constraints for the water level (or state of charge)
for the [`HydroEnergyBlockOptimization`](@extref).
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::Type{ReservoirInventoryConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroReservoir,
    W <: AbstractHydroReservoirFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    resolution = PSI.get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    names = [PSY.get_name(x) for x in devices]

    energy_var = PSI.get_variable(container, HydroEnergyVariableUp(), V)
    turbined_out_flow_var =
        PSI.get_variable(container, HydroTurbineFlowRateVariable(), PSY.HydroTurbine)
    spillage_var = PSI.get_variable(container, WaterSpillageVariable(), V)

    constraint = PSI.add_constraints_container!(
        container,
        ReservoirInventoryConstraint(),
        V,
        names,
        time_steps,
    )

    param_container = PSI.get_parameter(container, InflowTimeSeriesParameter(), V)
    multiplier = PSI.get_multiplier_array(param_container)

    t_first = first(time_steps)
    t_final = last(time_steps)

    for d in devices
        name = PSY.get_name(d)
        initial_level = PSY.get_initial_level(d)
        target_level = PSY.get_level_targets(d)
        #TODO: change sum of turbines outflow into an expression
        turbines = get_connected_devices(sys, d)
        turbine_names = [PSY.get_name(turbine) for turbine in turbines]

        constraint[name, t_first] = JuMP.@constraint(
            container.JuMPmodel,
            energy_var[name, t_first] ==
            initial_level
            +
            fraction_of_hour * (
                PSI.get_parameter_column_refs(param_container, name)[t_first] *
                multiplier[name, t_first] -
                (
                    sum(
                        turbined_out_flow_var[turbine_name, t_first] for
                        turbine_name in turbine_names
                    )
                    +
                    spillage_var[name, t_first]
                )
            )
        )

        constraint[name, t_final] = JuMP.@constraint(
            container.JuMPmodel,
            energy_var[name, t_final] == target_level
        )

        for t in time_steps[(t_first + 1):(t_final)]
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                energy_var[name, t] ==
                energy_var[name, t - 1] +
                fraction_of_hour * (
                    PSI.get_parameter_column_refs(param_container, name)[t] *
                    multiplier[name, t] -
                    (
                        sum(
                            turbined_out_flow_var[turbine_name, t] for
                            turbine_name in turbine_names
                        )
                        +
                        spillage_var[name, t]
                    )
                )
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
            sum([variable_out[name, t] for t in time_steps]) <=
            sum([multiplier[name, t] * param[t] for t in time_steps])
        )
    end
    return
end

############################################################################
###################### Medium Term Constraints #############################
############################################################################

"""
This function defines the constraints for the energy balance in a medium term planning problem.
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{EnergyBalanceExpression},
    ::Type{PSI.EnergyBalanceConstraint},
    ::PSI.NetworkModel{X},
) where {
    X <: PM.AbstractPowerModel,
}
    bal_expr = PSI.get_expression(container, EnergyBalanceExpression(), PSY.System)
    buses_ax, times_ax = axes(bal_expr)

    constraint = PSI.add_constraints_container!(
        container,
        PSI.EnergyBalanceConstraint(),
        PSY.System,
        buses_ax,
        times_ax,
    )

    for bus in buses_ax, t in times_ax
        constraint[bus, t] = JuMP.@constraint(
            container.JuMPmodel,
            bal_expr[bus, t] == 0.0,
        )
    end
    return
end

"""
This function define the level (head or volume) limits for the reservoir.
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{ReservoirLevelLimitConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroReservoir,
    W <: AbstractHydroFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    names = [PSY.get_name(d) for d in devices]
    constraint_ub =
        PSI.add_constraints_container!(
            container,
            ReservoirLevelLimitConstraint(),
            V,
            names,
            time_steps;
            meta = "ub",
        )
    constraint_lb =
        PSI.add_constraints_container!(
            container,
            ReservoirLevelLimitConstraint(),
            V,
            names,
            time_steps;
            meta = "lb",
        )

    for d in devices
        name = PSY.get_name(d)
        res_type = PSY.get_level_data_type(d)
        if res_type == PSY.ReservoirDataType.VOLUME
            var = PSI.get_variable(container, HydroReservoirVolumeVariable(), V)
        else
            var = PSI.get_variable(container, HydroReservoirHeadVariable(), V)
        end
        level_limits = PSY.get_storage_level_limits(d)
        if isa(level_limits, PSY.TimeSeriesKey)
            error("Level limits are not supported with timeseries yet")
        end
        for t in time_steps
            constraint_ub[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                var[name, t] <= level_limits.max
            )
            constraint_lb[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                var[name, t] >= level_limits.min
            )
        end
    end
    return
end

"""
This function define the level (head or volume) limits for the reservoir.
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{ReservoirInventoryConstraint},
    ::Type{HydroReservoirVolumeVariable},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
    hourly_resolution::Float64,
) where {
    V <: PSY.HydroReservoir,
    W <: AbstractHydroFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    names = [PSY.get_name(d) for d in devices]
    constraint =
        PSI.add_constraints_container!(
            container,
            ReservoirInventoryConstraint(),
            V,
            names,
            time_steps,
        )
    turbine_out = PSI.get_expression(container, TotalHydroFlowRateReservoirOut(), V)
    volume = PSI.get_variable(container, HydroReservoirVolumeVariable(), V)
    spillage_var = PSI.get_variable(container, WaterSpillageVariable(), V)
    param_container = PSI.get_parameter(container, InflowTimeSeriesParameter(), V)

    for d in devices
        name = PSY.get_name(d)
        initial_level = PSY.get_initial_level(d)
        h2v_factor = PSY.get_head_to_volume_factor(d)
        if PSY.get_level_data_type(d) == PSY.ReservoirDataType.VOLUME
            initial_vol = initial_level
        else
            initial_vol = initial_level * h2v_factor
        end
        inflow = PSI.get_parameter_column_refs(param_container, name)

        constraint[name, 1] = JuMP.@constraint(
            container.JuMPmodel,
            volume[name, 1] ==
            (
                initial_vol -
                hourly_resolution * SECONDS_IN_HOUR *
                (spillage_var[name, 1] + turbine_out[name, 1] - inflow[1])
            ) * M3_TO_KM3
        )
        for t in time_steps[2:end]
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                volume[name, t] ==
                volume[name, t - 1] -
                (
                    hourly_resolution * SECONDS_IN_HOUR *
                    (spillage_var[name, t] + turbine_out[name, t] - inflow[t])
                ) * M3_TO_KM3
            )
        end
    end
    return
end

"""
This function define the target level constraint for the reservoir.
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{ReservoirLevelTargetConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroReservoir,
    W <: AbstractHydroFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    names = PSY.get_name.(devices)
    constraint =
        PSI.add_constraints_container!(
            container,
            ReservoirLevelTargetConstraint(),
            V,
            names,
        )

    for d in devices
        name = PSY.get_name(d)
        level_targets = PSY.get_level_targets(d)
        if PSY.get_level_data_type(d) == PSY.ReservoirDataType.VOLUME
            var = PSI.get_variable(container, HydroReservoirVolumeVariable(), V)
        else
            var = PSI.get_variable(container, HydroReservoirHeadVariable(), V)
        end

        constraint[name] = JuMP.@constraint(
            container.JuMPmodel,
            var[name, time_steps[end]] >= level_targets
        )
    end
    return
end

"""
This function define the relationship between head and volume for the reservoir.
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{ReservoirHeadToVolumeConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroReservoir,
    W <: AbstractHydroFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    names = PSY.get_name.(devices)
    constraint =
        PSI.add_constraints_container!(
            container,
            ReservoirHeadToVolumeConstraint(),
            V,
            names,
            time_steps,
        )
    volume = PSI.get_variable(container, HydroReservoirVolumeVariable(), V)
    head = PSI.get_variable(container, HydroReservoirHeadVariable(), V)

    for d in devices
        name = PSY.get_name(d)
        h2v_factor = PSY.get_head_to_volume_factor(d)
        for t in time_steps
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                volume[name, t] == h2v_factor * head[name, t] * M3_TO_KM3
            )
        end
    end
    return
end

"""
This function define the relationship between turbined flow and power produced
"""
function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    ::Type{TurbinePowerOutputConstraint},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {
    V <: PSY.HydroTurbine,
    W <: AbstractHydroFormulation,
    X <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    base_power = PSI.get_base_power(container)
    names = PSY.get_name.(devices)
    constraint =
        PSI.add_constraints_container!(
            container,
            TurbinePowerOutputConstraint(),
            V,
            names,
            time_steps,
        )
    power = PSI.get_variable(container, PSI.ActivePowerVariable(), V)
    flow = PSI.get_variable(container, HydroTurbineFlowRateVariable(), V)
    head = PSI.get_variable(container, HydroReservoirHeadVariable(), PSY.HydroReservoir)
    for d in devices
        name = PSY.get_name(d)
        conversion_factor = PSY.get_conversion_factor(d)
        reservoirs = PSY.get_reservoirs(d)
        res_names = PSY.get_name.(reservoirs)
        for t in time_steps
            constraint[name, t] = JuMP.@constraint(
                container.JuMPmodel,
                power[name, t] ==
                GRAVITY_CONSTANT * WATER_DENSITY * conversion_factor *
                sum(head[res_name, t] * flow[name, res_name, t] for res_name in res_names) / (1e6 * base_power)
            )
        end
    end
    return
end

############################################################################
############################### Expressions ################################
############################################################################

function PSI.add_expressions!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::Type{TotalHydroFlowRateReservoirOut},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
) where {
    V <: PSY.HydroReservoir,
    W <: AbstractHydroFormulation,
}
    time_steps = PSI.get_time_steps(container)
    expression = PSI.add_expression_container!(
        container,
        TotalHydroFlowRateReservoirOut(),
        V,
        [PSY.get_name(d) for d in devices],
        time_steps,
    )

    variable = PSI.get_variable(container, HydroTurbineFlowRateVariable(), PSY.HydroTurbine)

    for d in devices
        turbines = PSY.get_connected_devices(sys, d)
        turbine_names = PSY.get_name.(turbines)
        reservoir_name = PSY.get_name(d)
        for t in time_steps
            expression[reservoir_name, t] =
                sum(variable[name, reservoir_name, t] for name in turbine_names)
        end
    end
end

function PSI.add_expressions!(
    container::PSI.OptimizationContainer,
    ::Type{TotalHydroFlowRateTurbineOut},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
) where {
    V <: PSY.HydroTurbine,
    W <: AbstractHydroFormulation,
}
    time_steps = PSI.get_time_steps(container)
    expression = PSI.add_expression_container!(
        container,
        TotalHydroFlowRateTurbineOut(),
        V,
        [PSY.get_name(d) for d in devices],
        time_steps,
    )

    variable = PSI.get_variable(container, HydroTurbineFlowRateVariable(), PSY.HydroTurbine)

    for d in devices
        reservoirs = PSY.get_reservoirs(d)
        reservoir_names = PSY.get_name.(reservoirs)
        name = PSY.get_name(d)
        for t in time_steps
            expression[name, t] =
                sum(variable[name, reservoir_name, t] for reservoir_name in reservoir_names)
        end
    end
end

function add_to_balance_expression!(
    container::PSI.OptimizationContainer,
    ::Type{U},
    ::Type{V},
    devices::IS.FlattenIteratorWrapper{W},
    model::PSI.DeviceModel{W, X},
    ::PSI.NetworkModel{Y},
    resolution::Float64,
) where {
    U <: EnergyBalanceExpression,
    V <: PSI.ActivePowerVariable,
    W <: PSY.Generator,
    X <: PSI.AbstractDeviceFormulation,
    Y <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    expression = PSI.get_expression(container, U(), PSY.System)
    ref_buses, time_ax = axes(expression)
    ref_bus = only(ref_buses)
    variable = PSI.get_variable(container, V(), W)

    for d in devices
        name = PSY.get_name(d)
        for t in time_steps
            JuMP.add_to_expression!(
                expression[ref_bus, t],
                resolution * variable[name, t],
            )
        end
    end
end

function add_to_balance_expression!(
    container::PSI.OptimizationContainer,
    ::Type{U},
    ::Type{V},
    devices::IS.FlattenIteratorWrapper{W},
    model::PSI.DeviceModel{W, X},
    ::PSI.NetworkModel{Y},
) where {
    U <: EnergyBalanceExpression,
    V <: PSI.ActivePowerTimeSeriesParameter,
    W <: PSY.ElectricLoad,
    X <: PSI.AbstractDeviceFormulation,
    Y <: PM.AbstractPowerModel,
}
    time_steps = PSI.get_time_steps(container)
    expression = PSI.get_expression(container, U(), PSY.System)
    ref_buses, time_ax = axes(expression)
    ref_bus = only(ref_buses)
    param_container = PSI.get_parameter(container, V(), W)
    param_multiplier = PSI.get_parameter_multiplier_array(
        container,
        V(),
        W,
    )

    for d in devices
        name = PSY.get_name(d)
        param = PSI.get_parameter_column_refs(param_container, name)
        for t in time_steps
            JuMP.add_to_expression!(
                expression[ref_bus, t],
                param_multiplier[name, t] * param[t],
            )
        end
    end
end

##################################### Auxillary Variables ############################
function PSI.calculate_aux_variable_value!(
    container::PSI.OptimizationContainer,
    ::PSI.AuxVarKey{HydroEnergyOutput, T},
    system::PSY.System,
) where {T <: PSY.HydroGen}
    time_steps = PSI.get_time_steps(container)
    resolution = PSI.get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    p_variable_results = PSI.get_variable(container, PSI.ActivePowerVariable(), T)
    aux_variable_container = PSI.get_aux_variable(container, HydroEnergyOutput(), T)
    devices_names = axes(aux_variable_container, 1)
    for name in devices_names
        d = PSY.get_component(T, system, name)
        for t in time_steps
            if PSI.has_container_key(container, HydroServedReserveUpExpression, typeof(d))
                served_regup = PSI.jump_value(
                    PSI.get_expression(container, HydroServedReserveUpExpression(), T)[
                        name,
                        t,
                    ],
                )
            else
                served_regup = 0.0
            end
            if PSI.has_container_key(container, HydroServedReserveUpExpression, typeof(d))
                served_regdn = PSI.jump_value(
                    PSI.get_expression(container, HydroServedReserveDownExpression(), T)[
                        name,
                        t,
                    ],
                )
            else
                served_regdn = 0.0
            end
            aux_variable_container[name, t] =
                (
                    PSI.jump_value(p_variable_results[name, t]) +
                    served_regup - served_regdn
                ) * fraction_of_hour
        end
    end

    return
end

function PSI.calculate_aux_variable_value!(
    container::PSI.OptimizationContainer,
    ::PSI.AuxVarKey{HydroEnergyOutput, T},
    system::PSY.System,
) where {T <: PSY.HydroPumpedStorage}
    time_steps = PSI.get_time_steps(container)
    resolution = PSI.get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    p_variable_results = PSI.get_variable(container, PSI.ActivePowerOutVariable(), T)
    aux_variable_container = PSI.get_aux_variable(container, HydroEnergyOutput(), T)
    devices_names = axes(aux_variable_container, 1)
    for name in devices_names
        d = PSY.get_component(T, system, name)
        for t in time_steps
            if PSI.has_container_key(container, HydroServedReserveUpExpression, typeof(d))
                served_regup = PSI.jump_value(
                    PSI.get_expression(container, HydroServedReserveUpExpression(), T)[
                        name,
                        t,
                    ],
                )
            else
                served_regup = 0.0
            end
            if PSI.has_container_key(container, HydroServedReserveUpExpression, typeof(d))
                served_regdn = PSI.jump_value(
                    PSI.get_expression(container, HydroServedReserveDownExpression(), T)[
                        name,
                        t,
                    ],
                )
            else
                served_regdn = 0.0
            end
            aux_variable_container[name, t] =
                (
                    PSI.jump_value(p_variable_results[name, t]) +
                    served_regup - served_regdn
                ) * fraction_of_hour
        end
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
            step = state_resolution,
            length = PSI.get_num_rows(state_data),
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
    T <: Union{
        PSI.InitialCondition{InitialHydroEnergyLevelUp, Float64},
        PSI.InitialCondition{InitialHydroEnergyLevelUp, JuMP.VariableRef},
        PSI.InitialCondition{InitialHydroEnergyLevelUp, Nothing},
    },
}
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
    T <: Union{
        PSI.InitialCondition{InitialHydroEnergyLevelDown, Float64},
        PSI.InitialCondition{InitialHydroEnergyLevelDown, JuMP.VariableRef},
        PSI.InitialCondition{InitialHydroEnergyLevelDown, Nothing},
    },
}
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
    T <: Union{
        PSI.InitialCondition{InitialHydroEnergyLevelUp, Float64},
        PSI.InitialCondition{InitialHydroEnergyLevelUp, JuMP.VariableRef},
        PSI.InitialCondition{InitialHydroEnergyLevelUp, Nothing},
    },
}
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
    T <: Union{
        PSI.InitialCondition{InitialHydroEnergyLevelDown, Float64},
        PSI.InitialCondition{InitialHydroEnergyLevelDown, JuMP.VariableRef},
        PSI.InitialCondition{InitialHydroEnergyLevelDown, Nothing},
    },
}
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

function PSI.add_constraints!(
    container::PSI.OptimizationContainer,
    T::Type{<:ReserveRangeExpressionUB},
    U::Type{<:PSI.ActivePowerReserveVariable},
    devices::IS.FlattenIteratorWrapper{V},
    model::PSI.DeviceModel{V, W},
    ::PSI.NetworkModel{X},
) where {V <: PSY.HydroGen, W <: PSI.AbstractDeviceFormulation, X <: PM.AbstractPowerModel}
    PSI.add_range_constraints!(container, T, U, devices, model, X)
    return
end

function PSI.add_to_expression!(
    container::PSI.OptimizationContainer,
    ::Type{T},
    ::Type{U},
    devices::Union{Vector{V}, IS.FlattenIteratorWrapper{V}},
    model::PSI.DeviceModel{V, W},
    network_model::PSI.NetworkModel{X},
) where {
    T <: Union{ReserveRangeExpressionLB, ReserveRangeExpressionUB},
    U <: PSI.VariableType,
    V <: PSY.Device,
    W <: PSI.AbstractDeviceFormulation,
    X <: PM.AbstractPowerModel,
}
    variable = PSI.get_variable(container, U(), V)
    if !PSI.has_container_key(container, T, V)
        PSI.add_expressions!(container, T, devices, model)
    end
    expression = PSI.get_expression(container, T(), V)
    for d in devices, t in PSI.get_time_steps(container)
        name = PSY.get_name(d)
        PSI._add_to_jump_expression!(expression[name, t], variable[name, t], 1.0)
    end
    return
end

function PSI.add_to_expression!(
    container::PSI.OptimizationContainer,
    ::Type{T},
    ::Type{U},
    devices::Union{Vector{V}, IS.FlattenIteratorWrapper{V}},
    model::PSI.ServiceModel{X, W},
) where {
    T <: ReserveRangeExpressionUB,
    U <: PSI.VariableType,
    V <: PSY.HydroGen,
    X <: PSY.Reserve{PSY.ReserveUp},
    W <: PSI.AbstractReservesFormulation,
}
    service_name = PSI.get_service_name(model)
    variable = PSI.get_variable(container, U(), X, service_name)
    if !PSI.has_container_key(container, T, V)
        PSI.add_expressions!(container, T, devices, model)
    end
    expression = PSI.get_expression(container, T(), V)
    for d in devices, t in PSI.get_time_steps(container)
        name = PSY.get_name(d)
        PSI._add_to_jump_expression!(expression[name, t], variable[name, t], 1.0)
    end
    return
end

function PSI.add_to_expression!(
    container::PSI.OptimizationContainer,
    ::Type{T},
    ::Type{U},
    devices::Union{Vector{V}, IS.FlattenIteratorWrapper{V}},
    model::PSI.ServiceModel{X, W},
) where {
    T <: ReserveRangeExpressionLB,
    U <: PSI.VariableType,
    V <: PSY.HydroGen,
    X <: PSY.Reserve{PSY.ReserveDown},
    W <: PSI.AbstractReservesFormulation,
}
    service_name = PSI.get_service_name(model)
    variable = PSI.get_variable(container, U(), X, service_name)
    if !PSI.has_container_key(container, T, V)
        PSI.add_expressions!(container, T, devices, model)
    end
    expression = PSI.get_expression(container, T(), V)
    for d in devices, t in PSI.get_time_steps(container)
        name = PSY.get_name(d)
        PSI._add_to_jump_expression!(expression[name, t], variable[name, t], -1.0)
    end
    return
end

function PSI.add_to_expression!(
    container::PSI.OptimizationContainer,
    ::Type{T},
    ::Type{U},
    devices::Union{Vector{V}, IS.FlattenIteratorWrapper{V}},
    model::PSI.DeviceModel{V, W},
    network_model::PSI.NetworkModel{X},
) where {
    T <: HydroServedReserveUpExpression,
    U <: PSI.ActivePowerReserveVariable,
    V <: PSY.HydroGen,
    W <: PSI.AbstractDeviceFormulation,
    X <: PM.AbstractPowerModel,
}
    expression = PSI.get_expression(container, T(), V)
    for d in devices
        name = PSY.get_name(d)
        service_models = PSI.get_services(model)
        for service_model in service_models
            service_name = PSI.get_service_name(service_model)
            services = PSY.get_services(d)
            service_ix = findfirst(x -> PSY.get_name(x) == service_name, services)
            service = services[service_ix]
            if isa(service, PSY.Reserve{PSY.ReserveUp})
                deployed_fraction = PSY.get_deployed_fraction(service)
                variable = PSI.get_variable(
                    container,
                    U(),
                    typeof(service),
                    service_name,
                )
                for t in PSI.get_time_steps(container)
                    PSI._add_to_jump_expression!(
                        expression[name, t],
                        variable[name, t],
                        deployed_fraction,
                    )
                end
            end
        end
    end
end

function PSI.add_to_expression!(
    container::PSI.OptimizationContainer,
    ::Type{T},
    ::Type{U},
    devices::Union{Vector{V}, IS.FlattenIteratorWrapper{V}},
    model::PSI.DeviceModel{V, W},
    network_model::PSI.NetworkModel{X},
) where {
    T <: HydroServedReserveDownExpression,
    U <: PSI.ActivePowerReserveVariable,
    V <: PSY.HydroGen,
    W <: PSI.AbstractDeviceFormulation,
    X <: PM.AbstractPowerModel,
}
    expression = PSI.get_expression(container, T(), V)
    for d in devices
        name = PSY.get_name(d)
        service_models = PSI.get_services(model)
        for service_model in service_models
            service_name = PSI.get_service_name(service_model)
            # Find service with the same name of the service_model, that should exist in the device
            services = PSY.get_services(d)
            service_ix = findfirst(x -> PSY.get_name(x) == service_name, services)
            service = services[service_ix]
            if isa(service, PSY.Reserve{PSY.ReserveDown})
                deployed_fraction = PSY.get_deployed_fraction(service)
                variable = PSI.get_variable(
                    container,
                    U(),
                    typeof(service),
                    service_name,
                )
                for t in PSI.get_time_steps(container)
                    PSI._add_to_jump_expression!(
                        expression[name, t],
                        variable[name, t],
                        deployed_fraction,
                    )
                end
            end
        end
    end
end

###################################################################
##################### Hydro Usage Parameters ######################
###################################################################

function PSI._add_parameters!(
    container::PSI.OptimizationContainer,
    ::Type{T},
    devices::V,
    model::PSI.DeviceModel{D, W},
) where {
    T <: HydroUsageLimitParameter,
    V <: Union{Vector{D}, IS.FlattenIteratorWrapper{D}},
    W <: AbstractHydroFormulation,
} where {D <: PSY.HydroGen}
    #@debug "adding" T D U _group = LOG_GROUP_OPTIMIZATION_CONTAINER
    names = [PSY.get_name(device) for device in devices]
    time_steps = PSI.get_time_steps(container)
    resolution = PSI.get_resolution(container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / PSI.MINUTES_IN_HOUR
    HOURS_IN_DAY = 24
    mult = fraction_of_hour * length(time_steps) / HOURS_IN_DAY
    key = PSI.AuxVarKey{HydroEnergyOutput, D}("")
    parameter_container =
        PSI.add_param_container!(container, T(), D, key, names, [time_steps[end]])
    jump_model = PSI.get_jump_model(container)

    for d in devices
        name = PSY.get_name(d)
        PSI.set_multiplier!(parameter_container, 1.0, name, time_steps[end])
        PSI.set_parameter!(
            parameter_container,
            jump_model,
            mult * PSI.get_initial_parameter_value(T(), d, W()),
            name,
            time_steps[end],
        )
    end
    return
end

function PSI.add_to_expression!(
    container::PSI.OptimizationContainer,
    ::Type{T},
    ::Type{U},
    devices::Union{Vector{V}, IS.FlattenIteratorWrapper{V}},
    model::PSI.ServiceModel{X, W},
) where {
    T <: HydroServedReserveUpExpression,
    U <: PSI.VariableType,
    V <: PSY.HydroGen,
    X <: PSY.Reserve{PSY.ReserveUp},
    W <: PSI.AbstractReservesFormulation,
}
    service_name = PSI.get_service_name(model)
    variable = PSI.get_variable(container, U(), X, service_name)
    if !PSI.has_container_key(container, T, V)
        PSI.add_expressions!(container, T, devices, model)
    end
    expression = PSI.get_expression(container, T(), V)
    for d in devices, t in PSI.get_time_steps(container)
        name = PSY.get_name(d)
        PSI._add_to_jump_expression!(expression[name, t], variable[name, t], 1.0)
    end
    return
end

function PSI.add_to_expression!(
    container::PSI.OptimizationContainer,
    ::Type{T},
    ::Type{U},
    devices::Union{Vector{V}, IS.FlattenIteratorWrapper{V}},
    model::PSI.ServiceModel{X, W},
) where {
    T <: HydroServedReserveDownExpression,
    U <: PSI.VariableType,
    V <: PSY.HydroGen,
    X <: PSY.Reserve{PSY.ReserveDown},
    W <: PSI.AbstractReservesFormulation,
}
    service_name = PSI.get_service_name(model)
    variable = PSI.get_variable(container, U(), X, service_name)
    if !PSI.has_container_key(container, T, V)
        PSI.add_expressions!(container, T, devices, model)
    end
    expression = PSI.get_expression(container, T(), V)
    for d in devices, t in PSI.get_time_steps(container)
        name = PSY.get_name(d)
        PSI._add_to_jump_expression!(expression[name, t], variable[name, t], -1.0)
    end
    return
end
