struct HydroDispatchReservoirIntervalBudget <: PSI.AbstractHydroDispatchFormulation end
struct HydroDispatchRunOfRiverCascade <: PSI.AbstractHydroDispatchFormulation end
struct HydroDispatchRunOfRiverLowerBound <: PSI.AbstractHydroDispatchFormulation end
struct HydroDispatchReservoirBudgetLowerUpperBound <: PSI.AbstractHydroDispatchFormulation end
struct HydroDispatchReservoirCascade <: PSI.AbstractHydroReservoirFormulation end
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
            forecast_label = "max_hourly_hydro_budget",
            multiplier_func = x -> PSY.get_max_active_power(x),
            constraint_func = use_parameters ? PSI.device_timeseries_param_ub! :
                              PSI.device_timeseries_ub!,
        ),
    )
end

function energy_interval_budget_constraints!(
    optimization_container::OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{H},
    ::DeviceModel{H, HydroDispatchReservoirIntervalBudget},
    ::Type{<:PM.AbstractPowerModel},
    ::Union{Nothing, AbstractAffectFeedForward},
) where {H <: PSY.HydroGen}
    forecast_label = "hydro_budget"
    constraint_data = Vector{DeviceTimeSeriesConstraintInfo}(undef, length(devices))
    interval_step = get_internal(model).simulation_info.end_of_interval_step
    for (ix, d) in enumerate(devices)
        ts_vector = get_time_series(optimization_container, d, forecast_label)
        @debug "time_series" ts_vector
        constraint_d =
            DeviceTimeSeriesConstraintInfo(d, x -> PSY.get_storage_capacity(x), ts_vector)
        constraint_data[ix] = constraint_d
    end

    if model_has_parameters(optimization_container)
        device_interval_energy_budget_param_ub(
            optimization_container,
            constraint_data,
            make_constraint_name(ENERGY_INTERVAL_BUDGET, H),
            UpdateRef{H}(ENERGY_INTERVAL_BUDGET, forecast_label),
            make_variable_name(ACTIVE_POWER, H),
            interval_step,
        )
    else
        device_interval_energy_budget_ub(
            optimization_container,
            constraint_data,
            make_constraint_name(ENERGY_INTERVAL_BUDGET),
            make_variable_name(ACTIVE_POWER, H),
            interval_step,
        )
    end
end

function device_interval_energy_budget_param_ub(
    optimization_container::OptimizationContainer,
    energy_budget_data::Vector{DeviceTimeSeriesConstraintInfo},
    cons_name::Symbol,
    param_reference::UpdateRef,
    var_names::Symbol,
    interval_step::Float64,
)
    time_steps = model_time_steps(optimization_container)
    resolution = model_resolution(optimization_container)
    
    inv_dt = 1.0 / (Dates.value(Dates.Second(resolution)) / SECONDS_IN_HOUR)
    variable_out = get_variable(optimization_container, var_names)
    set_name = [get_component_name(r) for r in energy_budget_data]
    constraint = add_cons_container!(optimization_container, cons_name, set_name)
    container =
        add_param_container!(optimization_container, param_reference, set_name, time_steps)
    multiplier = get_multiplier_array(container)
    param = get_parameter_array(container)
    for constraint_info in energy_budget_data
        name = get_component_name(constraint_info)
        for t in time_steps
            multiplier[name, t] = constraint_info.multiplier * inv_dt
            param[name, t] = add_parameter(
                optimization_container.JuMPmodel,
                constraint_info.timeseries[t],
            )
        end
        constraint[name] = JuMP.@constraint(
            optimization_container.JuMPmodel,
            sum([variable_out[name, t] for t in 1:interval_step]) <= sum([multiplier[name, t] * param[name, t] for t in 1:interval_step])
        )
    end

    return
end

"""
This function define the budget constraint
for the active power budget formulation.
"""
function device_interval_energy_budget_ub(
    optimization_container::OptimizationContainer,
    energy_budget_constraints::Vector{DeviceTimeSeriesConstraintInfo},
    cons_name::Symbol,
    var_names::Symbol,
    interval_step::Float64,
)
    time_steps = model_time_steps(optimization_container)
    variable_out = get_variable(optimization_container, var_names)
    names = [get_component_name(x) for x in energy_budget_constraints]
    constraint = add_cons_container!(optimization_container, cons_name, names)

    for constraint_info in energy_budget_constraints
        name = get_component_name(constraint_info)
        resolution = model_resolution(optimization_container)
        inv_dt = 1.0 / (Dates.value(Dates.Second(resolution)) / SECONDS_IN_HOUR)
        forecast = constraint_info.timeseries
        multiplier = constraint_info.multiplier * inv_dt
        constraint[name] = JuMP.@constraint(
            optimization_container.JuMPmodel,
            sum([variable_out[name, t] for t in 1:interval_step]) <= multiplier * sum(forecast[t] for t in 1:interval_step)
        )
    end

    return
end
