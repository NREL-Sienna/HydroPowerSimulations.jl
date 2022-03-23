struct HydroDispatchReservoirIntervalBudget <: PSI.AbstractHydroReservoirFormulation end
struct HydroDispatchRunOfRiverCascade <: PSI.AbstractHydroDispatchFormulation end
struct HydroDispatchRunOfRiverLowerBound <: PSI.AbstractHydroDispatchFormulation end
struct HydroDispatchReservoirBudgetLowerUpperBound <: PSI.AbstractHydroDispatchFormulation end
struct HydroDispatchReservoirCascade <: PSI.AbstractHydroReservoirFormulation end
struct HydroDispatchReservoirBudgetUpperBound <: PSI.AbstractHydroReservoirFormulation end
struct HydroDispatchReservoirCustomBudget <: PSI.AbstractHydroReservoirFormulation end
struct HydroDispatchReservoirNestedCustomBudget <: PSI.AbstractHydroReservoirFormulation end

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

function energy_custom_budget_constraints!(
    optimization_container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{H},
    budget_step::Int,
    ::PSI.DeviceModel{H, <:PSI.AbstractHydroReservoirFormulation},
    ::Type{<:PM.AbstractPowerModel},
    ::Union{Nothing, PSI.AbstractAffectFeedForward},
) where {H <: PSY.HydroGen}
    forecast_label = "hydro_budget"
    constraint_data = Vector{PSI.DeviceTimeSeriesConstraintInfo}(undef, length(devices))
    for (ix, d) in enumerate(devices)
        ts_vector = PSI.get_time_series(optimization_container, d, forecast_label)
        @debug "time_series" ts_vector
        constraint_d = PSI.DeviceTimeSeriesConstraintInfo(
            d,
            x -> PSY.get_storage_capacity(x),
            ts_vector,
        )
        constraint_data[ix] = constraint_d
    end

    if PSI.model_has_parameters(optimization_container)
        device_interval_energy_budget_param_ub(
            optimization_container,
            constraint_data,
            PSI.make_constraint_name(ENERGY_INTERVAL_BUDGET, H),
            PSI.UpdateRef{H}(ENERGY_INTERVAL_BUDGET, forecast_label),
            PSI.make_variable_name(PSI.ACTIVE_POWER, H),
            budget_step,
        )
    else
        device_interval_energy_budget_ub(
            optimization_container,
            constraint_data,
            PSI.make_constraint_name(ENERGY_INTERVAL_BUDGET),
            PSI.make_variable_name(PSI.ACTIVE_POWER, H),
            budget_step,
        )
    end
end

function device_interval_energy_budget_param_ub(
    optimization_container::PSI.OptimizationContainer,
    energy_budget_data::Vector{PSI.DeviceTimeSeriesConstraintInfo},
    cons_name::Symbol,
    param_reference::PSI.UpdateRef,
    var_names::Symbol,
    budget_step::Int,
)
    time_steps = PSI.model_time_steps(optimization_container)
    resolution = PSI.model_resolution(optimization_container)

    inv_dt = 1.0 / (Dates.value(Dates.Second(resolution)) / PSI.SECONDS_IN_HOUR)
    variable_out = PSI.get_variable(optimization_container, var_names)
    set_name = [PSI.get_component_name(r) for r in energy_budget_data]
    constraint = PSI.add_cons_container!(optimization_container, cons_name, set_name)
    container = PSI.add_param_container!(optimization_container, param_reference, set_name, time_steps)
    multiplier = PSI.get_multiplier_array(container)
    param = PSI.get_parameter_array(container)
    for constraint_info in energy_budget_data
        name = PSI.get_component_name(constraint_info)
        for t in time_steps
            multiplier[name, t] = constraint_info.multiplier * inv_dt
            param[name, t] = PSI.add_parameter(
                optimization_container.JuMPmodel,
                constraint_info.timeseries[t],
            )
        end
        constraint[name] = JuMP.@constraint(
            optimization_container.JuMPmodel,
            sum([variable_out[name, t] for t in 1:budget_step]) <= sum([multiplier[name, t] * param[name, t] for t in 1:budget_step])
        )
    end

    return
end

"""
This function define the budget constraint
for the active power budget formulation.
"""
function device_interval_energy_budget_ub(
    optimization_container::PSI.OptimizationContainer,
    energy_budget_constraints::Vector{PSI.DeviceTimeSeriesConstraintInfo},
    cons_name::Symbol,
    var_names::Symbol,
    budget_step::Int,
)
    time_steps = PSI.model_time_steps(optimization_container)
    variable_out = PSI.get_variable(optimization_container, var_names)
    names = [PSI.get_component_name(x) for x in energy_budget_constraints]
    constraint = PSI.add_cons_container!(optimization_container, cons_name, names)

    for constraint_info in energy_budget_constraints
        name = PSI.get_component_name(constraint_info)
        resolution = PSI.model_resolution(optimization_container)
        inv_dt = 1.0 / (Dates.value(Dates.Second(resolution)) / PSI.SECONDS_IN_HOUR)
        forecast = constraint_info.timeseries
        multiplier = constraint_info.multiplier * inv_dt
        constraint[name] = JuMP.@constraint(
            optimization_container.JuMPmodel,
            sum([variable_out[name, t] for t in 1:budget_step]) <= multiplier * sum(forecast[t] for t in 1:budget_step)
        )
    end

    return
end

function get_nested_budget_length(
    optimization_container::PSI.OptimizationContainer,
    budget_step::Int,
    interval::Int,
)
    time_steps = PSI.model_time_steps(optimization_container)
    horizon = time_steps[end]
    range_time_periods = collect(budget_step:interval:horizon)
    return range_time_periods
end

function energy_custom_budget_constraints!(
    optimization_container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{H},
    budget_step::Int,
    interval::Int,
    ::PSI.DeviceModel{H, <:PSI.AbstractHydroReservoirFormulation},
    ::Type{<:PM.AbstractPowerModel},
    ::Union{Nothing, PSI.AbstractAffectFeedForward},
) where {H <: PSY.HydroGen}
    forecast_label = "hydro_budget"
    constraint_data = Vector{PSI.DeviceTimeSeriesConstraintInfo}(undef, length(devices))
    for (ix, d) in enumerate(devices)
        ts_vector = PSI.get_time_series(optimization_container, d, forecast_label)
        @debug "time_series" ts_vector
        constraint_d = PSI.DeviceTimeSeriesConstraintInfo(
            d,
            x -> PSY.get_storage_capacity(x),
            ts_vector,
        )
        constraint_data[ix] = constraint_d
    end

    if PSI.model_has_parameters(optimization_container)
        device_interval_nested_energy_budget_param_ub(
            optimization_container,
            constraint_data,
            PSI.make_constraint_name(ENERGY_INTERVAL_BUDGET, H),
            PSI.UpdateRef{H}(ENERGY_INTERVAL_BUDGET, forecast_label),
            PSI.make_variable_name(PSI.ACTIVE_POWER, H),
            get_nested_budget_length(optimization_container, budget_step, interval),
        )
    else
        device_interval_nested_energy_budget_ub(
            optimization_container,
            constraint_data,
            PSI.make_constraint_name(ENERGY_INTERVAL_BUDGET),
            PSI.make_variable_name(PSI.ACTIVE_POWER, H),
            get_nested_budget_length(optimization_container, budget_step, interval),
        )
    end
end

function device_interval_nested_energy_budget_param_ub(
    optimization_container::PSI.OptimizationContainer,
    energy_budget_data::Vector{PSI.DeviceTimeSeriesConstraintInfo},
    cons_name::Symbol,
    param_reference::PSI.UpdateRef,
    var_names::Symbol,
    budget_steps::Vector{Int},
)
    time_steps = PSI.model_time_steps(optimization_container)
    resolution = PSI.model_resolution(optimization_container)

    inv_dt = 1.0 / (Dates.value(Dates.Second(resolution)) / PSI.SECONDS_IN_HOUR)
    variable_out = PSI.get_variable(optimization_container, var_names)
    set_name = [PSI.get_component_name(r) for r in energy_budget_data]
    constraint = PSI.add_cons_container!(optimization_container, cons_name, set_name, 1:length(budget_steps))
    container = PSI.add_param_container!(
        optimization_container,
        param_reference,
        set_name,
        time_steps,
    )
    multiplier = PSI.get_multiplier_array(container)
    param = PSI.get_parameter_array(container)
    for constraint_info in energy_budget_data
        name = PSI.get_component_name(constraint_info)
        for t in time_steps
            multiplier[name, t] = constraint_info.multiplier * inv_dt
            param[name, t] = PSI.add_parameter(
                optimization_container.JuMPmodel,
                constraint_info.timeseries[t],
            )
        end
        for (ix, T) in enumerate(budget_steps)
            constraint[name, ix] = JuMP.@constraint(
                optimization_container.JuMPmodel,
                sum([variable_out[name, t] for t in 1:T]) <= sum([multiplier[name, t] * param[name, t] for t in 1:T])
            )
        end
    end

    return
end

"""
This function define the budget constraint
for the active power budget formulation.
"""
function device_interval_nested_energy_budget_ub(
    optimization_container::PSI.OptimizationContainer,
    energy_budget_constraints::Vector{PSI.DeviceTimeSeriesConstraintInfo},
    cons_name::Symbol,
    var_names::Symbol,
    budget_steps::Vector{Int},
)
    time_steps = PSI.model_time_steps(optimization_container)
    variable_out = PSI.get_variable(optimization_container, var_names)
    names = [PSI.get_component_name(x) for x in energy_budget_constraints]
    constraint = PSI.add_cons_container!(
        optimization_container,
        cons_name,
        names,
        1:length(budget_steps),
    )

    for constraint_info in energy_budget_constraints
        name = PSI.get_component_name(constraint_info)
        resolution = PSI.model_resolution(optimization_container)
        inv_dt = 1.0 / (Dates.value(Dates.Second(resolution)) / PSI.SECONDS_IN_HOUR)
        forecast = constraint_info.timeseries
        multiplier = constraint_info.multiplier * inv_dt
        for (ix, T) in enumerate(budget_steps)
            constraint[name, ix] = JuMP.@constraint(
                optimization_container.JuMPmodel,
                sum([variable_out[name, t] for t in 1:T]) <= multiplier * sum(forecast[t] for t in 1:T)
            )
        end
    end

    return
end
