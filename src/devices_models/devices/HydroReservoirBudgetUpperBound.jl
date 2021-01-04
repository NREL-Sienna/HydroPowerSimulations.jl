struct HydroDispatchReservoirBudgetUpperBound <: PSI.AbstractHydroReservoirFormulation end

function PSI.DeviceRangeConstraintSpec(
    ::Type{<:PSI.RangeConstraint},
    ::Type{PSI.ActivePowerVariable},
    ::Type{T},
    ::Type{<:HydroDispatchReservoirBudgetUpperBound},
    ::Type{<:PM.AbstractPowerModel},
    feedforward::Union{Nothing, PSI.AbstractAffectFeedForward},
    use_parameters::Bool,
    use_forecasts::Bool,
) where {T <: PSY.HydroGen}
    if !use_parameters && !use_forecasts
        return PSI.DeviceRangeConstraintSpec(;
            range_constraint_spec = PSI.RangeConstraintSpec(;
                constraint_name = PSI.make_constraint_name(
                    PSI.RangeConstraint,
                    PSI.ActivePowerVariable,
                    T,
                ),
                variable_name = PSI.make_variable_name(PSI.ActivePowerVariable, T),
                limits_func = x -> (min = 0.0, max = PSY.get_active_power(x)),
                constraint_func = PSI.device_range!,
                constraint_struct = PSI.DeviceRangeConstraintInfo,
            ),
        )
    end

    return PSI.DeviceRangeConstraintSpec(;
        timeseries_range_constraint_spec = PSI.TimeSeriesConstraintSpec(
            constraint_name = PSI.make_constraint_name(
                PSI.RangeConstraint,
                PSI.ActivePowerVariable,
                T,
            ),
            variable_name = PSI.make_variable_name(PSI.ActivePowerVariable, T),
            parameter_name = use_parameters ? PSI.ACTIVE_POWER : nothing,
            forecast_label = "storage_target",
            multiplier_func = x -> PSY.get_storage_capacity(x),
            constraint_func = use_parameters ? PSI.device_timeseries_param_ub! :
                              PSI.device_timeseries_ub!,
        ),
    )
end
