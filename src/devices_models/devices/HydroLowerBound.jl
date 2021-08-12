struct HydroDispatchRunOfRiverLowerBound <: PSI.AbstractHydroDispatchFormulation end
struct HydroDispatchReservoirBudgetLowerUpperBound <: PSI.AbstractHydroDispatchFormulation end
const MIN_HOURLY_HYDRO_BOUND = "min_hourly_hydro_bound"

function time_series_lower_bound!(
    optimization_container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{H},
    ::PSI.DeviceModel{H, <:PSI.AbstractHydroDispatchFormulation},
    ::Type{<:PM.AbstractPowerModel},
    ::Union{Nothing, PSI.AbstractAffectFeedForward},
) where {H <: PSY.HydroGen}
    forecast_label = "min_hourly_hydro_bound"
    constraint_data = Vector{PSI.DeviceTimeSeriesConstraintInfo}(undef, length(devices))
    for (ix, d) in enumerate(devices)
        ts_vector = PSI.get_time_series(optimization_container, d, forecast_label)
        @debug "time_series" ts_vector
        constraint_d =
            PSI.DeviceTimeSeriesConstraintInfo(d, x -> PSY.get_max_active_power(x), ts_vector)
        constraint_data[ix] = constraint_d
    end

    if PSI.model_has_parameters(optimization_container)
        device_time_series_param_lb(
            optimization_container,
            constraint_data,
            PSI.make_constraint_name(MIN_HOURLY_HYDRO_BOUND, H),
            PSI.UpdateRef{H}(MIN_HOURLY_HYDRO_BOUND, forecast_label),
            PSI.make_variable_name(PSI.ACTIVE_POWER, H),
        )
    else
        device_time_series_lb(
            optimization_container,
            constraint_data,
            PSI.make_constraint_name(MIN_HOURLY_HYDRO_BOUND),
            PSI.make_variable_name(PSI.ACTIVE_POWER, H),
        )
    end
end


function device_time_series_param_lb(
    optimization_container::PSI.OptimizationContainer,
    time_series_lower_bound_data::Vector{PSI.DeviceTimeSeriesConstraintInfo},
    cons_name::Symbol,
    param_reference::PSI.UpdateRef,
    var_names::Symbol,
)
    time_steps = PSI.model_time_steps(optimization_container)
    resolution = PSI.model_resolution(optimization_container)
    inv_dt = 1.0 / (Dates.value(Dates.Second(resolution)) / PSI.SECONDS_IN_HOUR)
    variable_out = PSI.get_variable(optimization_container, var_names)
    set_name = [PSI.get_component_name(r) for r in time_series_lower_bound_data]
    constraint = PSI.add_cons_container!(optimization_container, cons_name, set_name, time_steps)
    container =
        PSI.add_param_container!(optimization_container, param_reference, set_name, time_steps)
    multiplier = PSI.get_multiplier_array(container)
    param = PSI.get_parameter_array(container)
    for constraint_info in time_series_lower_bound_data
        name = PSI.get_component_name(constraint_info)
        for t in time_steps
            multiplier[name, t] = constraint_info.multiplier * inv_dt
            param[name, t] = PSI.add_parameter(
                optimization_container.JuMPmodel,
                constraint_info.timeseries[t],
            )
        end
        for t in time_steps
            constraint[name,t] = JuMP.@constraint(
                optimization_container.JuMPmodel,
                variable_out[name, t] >= multiplier[name, t] * param[name, t]
            )
        end
    end

    return
end


function device_time_series_lb(
    optimization_container::PSI.OptimizationContainer,
    time_series_lower_bound_data::Vector{PSI.DeviceTimeSeriesConstraintInfo},
    cons_name::Symbol,
    var_names::Symbol,
)
    time_steps = PSI.model_time_steps(optimization_container)
    variable_out = PSI.get_variable(optimization_container, var_names)
    names = [PSI.get_component_name(x) for x in time_series_lower_bound_data]
    constraint = PSI.add_cons_container!(optimization_container, cons_name, names, time_steps)

    for constraint_info in time_series_lower_bound_data
        name = PSI.get_component_name(constraint_info)
        resolution = PSI.model_resolution(optimization_container)
        inv_dt = 1.0 / (Dates.value(Dates.Second(resolution)) / PSI.SECONDS_IN_HOUR)
        forecast = constraint_info.timeseries
        multiplier = constraint_info.multiplier * inv_dt
        for t in time_steps
            constraint[name,t] = JuMP.@constraint(
                optimization_container.JuMPmodel,
                variable_out[name, t] >= multiplier .* forecast[t]
            )
        end
    end

    return
end