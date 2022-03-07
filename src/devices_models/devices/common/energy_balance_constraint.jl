
function flow_balance_external_input_param_cascade(
    optimization_container::PSI.OptimizationContainer,
    inflow_data::Vector{PSI.DeviceTimeSeriesConstraintInfo},
    upstream::Vector{
        Vector{NamedTuple{(:unit, :lag, :multiplier), Tuple{PSY.HydroGen, Int64, Float64}}},
    },
    cons_name::Symbol,
    var_names::Tuple{Symbol, Symbol},
    param_reference::PSI.UpdateRef,
)
    time_steps = PSI.model_time_steps(optimization_container)
    resolution = PSI.model_resolution(optimization_container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / 60.0

    name_index = [PSI.get_component_name(d) for d in inflow_data]

    varspill = PSI.get_variable(optimization_container, var_names[1])
    varout = PSI.get_variable(optimization_container, var_names[2])

    container_inflow = PSI.add_param_container!(
        optimization_container,
        param_reference,
        name_index,
        time_steps,
    )
    param_inflow = PSI.get_parameter_array(container_inflow)
    multiplier_inflow = PSI.get_multiplier_array(container_inflow)

    flow_constraint =
        PSI.add_cons_container!(optimization_container, cons_name, name_index, time_steps)

    for (ix, d) in enumerate(inflow_data)
        name = PSI.get_component_name(d)
        upstream_devices = upstream[ix]

        multiplier_inflow[name, 1] = d.multiplier
        param_inflow[name, 1] =
            PJ.add_parameter(optimization_container.JuMPmodel, d.timeseries[1])

        exp =
            multiplier_inflow[name, 1] * param_inflow[name, 1] - varspill[name, 1] -
            varout[name, 1] #+ initial_conditions[ix].value
        #= spillage isn't an initial condition because it's not stored in the struct, so we can't make the cascading flow constrainits for the first periiod.
            for j in upstream_devices
                JuMP.add_to_expression!(exp, varspill[IS.get_name(j), 1])
                JuMP.add_to_expression!(exp, varout[IS.get_name(j), 1])
            end
        =#
        flow_constraint[name, 1] =
            JuMP.@constraint(optimization_container.JuMPmodel, exp == 0.0)

        for t in time_steps[2:end]
            param_inflow[name, t] =
                PJ.add_parameter(optimization_container.JuMPmodel, d.timeseries[t])

            exp = d.multiplier * param_inflow[name, t] - varspill[name, t] - varout[name, t]
            for j in upstream_devices
                if t - j.lag >= 1
                    JuMP.add_to_expression!(
                        exp,
                        varspill[IS.get_name(j.unit), t - j.lag],
                        j.multiplier,
                    )
                    JuMP.add_to_expression!(
                        exp,
                        varout[IS.get_name(j.unit), t - j.lag],
                        j.multiplier,
                    )
                end
            end
            flow_constraint[name, t] =
                JuMP.@constraint(optimization_container.JuMPmodel, exp == 0.0)
        end
    end

    return
end

function flow_balance_external_input_cascade(
    optimization_container::PSI.OptimizationContainer,
    inflow_data::Vector{PSI.DeviceTimeSeriesConstraintInfo},
    upstream::Vector{
        Vector{NamedTuple{(:unit, :lag, :multiplier), Tuple{PSY.HydroGen, Int64, Float64}}},
    },
    cons_name::Symbol,
    var_names::Tuple{Symbol, Symbol},
)
    time_steps = PSI.model_time_steps(optimization_container)
    resolution = PSI.model_resolution(optimization_container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / 60.0

    name_index = [PSI.get_component_name(d) for d in inflow_data]

    varspill = PSI.get_variable(optimization_container, var_names[1])
    varout = PSI.get_variable(optimization_container, var_names[2])

    flow_constraint =
        PSI.add_cons_container!(optimization_container, cons_name, name_index, time_steps)

    for (ix, d) in enumerate(inflow_data)
        name = PSI.get_component_name(d)
        upstream_devices = upstream[ix]

        exp = d.multiplier * d.timeseries[1] - varspill[name, 1] - varout[name, 1] #+ initial_conditions[ix].value
        #= spillage isn't an initial condition because it's not stored in the struct, so we can't make the cascading flow constrainits for the first periiod.
            for j in upstream_devices
                JuMP.add_to_expression!(exp, varspill[IS.get_name(j), 1])
                JuMP.add_to_expression!(exp, varout[IS.get_name(j), 1])
            end
        =#
        flow_constraint[name, 1] =
            JuMP.@constraint(optimization_container.JuMPmodel, exp == 0.0)

        for t in time_steps[2:end]
            exp = d.multiplier * d.timeseries[t] - varspill[name, t] - varout[name, t]

            for j in upstream_devices
                if t - j.lag >= 1
                    JuMP.add_to_expression!(
                        exp,
                        varspill[IS.get_name(j.unit), t - j.lag],
                        j.multiplier,
                    )
                    JuMP.add_to_expression!(
                        exp,
                        varout[IS.get_name(j.unit), t - j.lag],
                        j.multiplier,
                    )
                end
            end
            flow_constraint[name, t] =
                JuMP.@constraint(optimization_container.JuMPmodel, exp == 0.0)
        end
    end
    return
end

function flow_balance_cascade_constraint!(
    optimization_container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{H},
    model::PSI.DeviceModel{H, HydroDispatchRunOfRiverCascade},
    system_formulation::Type{<:PM.AbstractPowerModel},
    feedforward::Union{Nothing, PSI.AbstractAffectFeedForward},
) where {H <: HydroCascade}
    parameters = PSI.model_has_parameters(optimization_container)
    use_forecast_data = PSI.model_uses_forecasts(optimization_container)

    inflow_forecast_label = "max_active_power"
    constraint_infos_inflow =
        Vector{PSI.DeviceTimeSeriesConstraintInfo}(undef, length(devices))
    upstream_data = Vector{
        Vector{NamedTuple{(:unit, :lag, :multiplier), Tuple{PSY.HydroGen, Int64, Float64}}},
    }(
        undef,
        length(devices),
    )

    for (ix, d) in enumerate(devices)
        ts_vector_inflow =
            PSI.get_time_series(optimization_container, d, inflow_forecast_label)
        constraint_info_inflow = PSI.DeviceTimeSeriesConstraintInfo(
            d,
            x -> PSY.get_max_active_power(x),
            ts_vector_inflow,
        )
        PSI.add_device_services!(constraint_info_inflow.range, d, model)
        constraint_infos_inflow[ix] = constraint_info_inflow
        upstream_data[ix] = get_upstream(d)
    end

    if parameters
        flow_balance_external_input_param_cascade(
            optimization_container,
            constraint_infos_inflow,
            upstream_data,
            PSI.make_constraint_name(CASCADING_FLOW, H),
            (
                PSI.make_variable_name(PSI.SPILLAGE, H),
                PSI.make_variable_name(PSI.ACTIVE_POWER, H),
            ),
            PSI.UpdateRef{H}(PSI.INFLOW, inflow_forecast_label),
        )
    else
        flow_balance_external_input_cascade(
            optimization_container,
            constraint_infos_inflow,
            upstream_data,
            PSI.make_constraint_name(CASCADING_FLOW, H),
            (
                PSI.make_variable_name(PSI.SPILLAGE, H),
                PSI.make_variable_name(PSI.ACTIVE_POWER, H),
            ),
        )
    end
    return
end

function energy_balance_external_input_param_cascade(
    optimization_container::PSI.OptimizationContainer,
    initial_conditions::Vector{PSI.InitialCondition},
    time_series_data::Tuple{
        Vector{PSI.DeviceTimeSeriesConstraintInfo},
        Vector{PSI.DeviceTimeSeriesConstraintInfo},
    },
    upstream::Vector{
        Vector{NamedTuple{(:unit, :lag, :multiplier), Tuple{PSY.HydroGen, Int64, Float64}}},
    },
    cons_names::Tuple{Symbol, Symbol},
    var_names::Tuple{Symbol, Symbol, Symbol},
    param_references::Tuple{PSI.UpdateRef, PSI.UpdateRef},
)
    time_steps = PSI.model_time_steps(optimization_container)
    resolution = PSI.model_resolution(optimization_container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / 60.0

    inflow_data = time_series_data[1]
    target_data = time_series_data[2]

    name_index = [PSI.get_component_name(d) for d in inflow_data]

    varspill = PSI.get_variable(optimization_container, var_names[1])
    varout = PSI.get_variable(optimization_container, var_names[2])
    varenergy = PSI.get_variable(optimization_container, var_names[3])

    balance_cons_name = cons_names[1]
    target_cons_name = cons_names[2]
    balance_param_reference = param_references[1]
    target_param_reference = param_references[2]

    container_inflow = PSI.add_param_container!(
        optimization_container,
        balance_param_reference,
        name_index,
        time_steps,
    )
    param_inflow = PSI.get_parameter_array(container_inflow)
    multiplier_inflow = PSI.get_multiplier_array(container_inflow)

    container_target = PSI.add_param_container!(
        optimization_container,
        target_param_reference,
        name_index,
        time_steps,
    )
    param_target = PSI.get_parameter_array(container_target)
    multiplier_target = PSI.get_multiplier_array(container_target)

    balance_constraint = PSI.add_cons_container!(
        optimization_container,
        balance_cons_name,
        name_index,
        time_steps,
    )
    target_constraint =
        PSI.add_cons_container!(optimization_container, target_cons_name, name_index, 1)

    for (ix, d) in enumerate(inflow_data)
        name = PSI.get_component_name(d)
        upstream_devices = upstream[ix]

        multiplier_inflow[name, 1] = d.multiplier
        param_inflow[name, 1] =
            PJ.add_parameter(optimization_container.JuMPmodel, d.timeseries[1])
        exp =
            initial_conditions[ix].value +
            (
                multiplier_inflow[name, 1] * param_inflow[name, 1] - varspill[name, 1] -
                varout[name, 1]
            ) * fraction_of_hour

        #= This is commented out because it constrains the cascading inflow in period 1 to upstream outflows in period 1 instead of 0
        if !isempty(upstream_devices)
            for j in upstream_devices
                JuMP.add_to_expression!(exp, varspill[IS.get_name(j), 1], fraction_of_hour)
                JuMP.add_to_expression!(exp, varout[IS.get_name(j), 1], fraction_of_hour)
            end
        end
        =#

        balance_constraint[name, 1] =
            JuMP.@constraint(optimization_container.JuMPmodel, varenergy[name, 1] == exp)

        for t in time_steps[2:end]
            param_inflow[name, t] =
                PJ.add_parameter(optimization_container.JuMPmodel, d.timeseries[t])
            exp =
                varenergy[name, t - 1] +
                (
                    d.multiplier * param_inflow[name, t] - varspill[name, t] -
                    varout[name, t]
                ) * fraction_of_hour

            if !isempty(upstream_devices)
                for j in upstream_devices
                    if t - j.lag >= 1
                        JuMP.add_to_expression!(
                            exp,
                            varspill[IS.get_name(j.unit), t - j.lag],
                            j.multiplier * fraction_of_hour,
                        )
                        JuMP.add_to_expression!(
                            exp,
                            varout[IS.get_name(j.unit), t - j.lag],
                            j.multiplier * fraction_of_hour,
                        )
                    end
                end
            end

            balance_constraint[name, t] = JuMP.@constraint(
                optimization_container.JuMPmodel,
                varenergy[name, t] == exp
            )
        end
    end

    for (ix, d) in enumerate(target_data)
        name = PSI.get_component_name(d)
        for t in time_steps
            param_target[name, t] =
                PJ.add_parameter(optimization_container.JuMPmodel, d.timeseries[t])
        end
        target_constraint[name, 1] = JuMP.@constraint(
            optimization_container.JuMPmodel,
            varenergy[name, time_steps[end]] >=
            d.multiplier * param_target[name, time_steps[end]]
        )
    end

    return
end

function energy_balance_external_input_cascade(
    optimization_container::PSI.OptimizationContainer,
    initial_conditions::Vector{PSI.InitialCondition},
    time_series_data::Tuple{
        Vector{PSI.DeviceTimeSeriesConstraintInfo},
        Vector{PSI.DeviceTimeSeriesConstraintInfo},
    },
    upstream::Vector{
        Vector{NamedTuple{(:unit, :lag, :multiplier), Tuple{PSY.HydroGen, Int64, Float64}}},
    },
    cons_names::Tuple{Symbol, Symbol},
    var_names::Tuple{Symbol, Symbol, Symbol},
)
    time_steps = PSI.model_time_steps(optimization_container)
    resolution = PSI.model_resolution(optimization_container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / 60.0

    inflow_data = time_series_data[1]
    target_data = time_series_data[2]

    name_index = [PSI.get_component_name(d) for d in inflow_data]

    varspill = PSI.get_variable(optimization_container, var_names[1])
    varout = PSI.get_variable(optimization_container, var_names[2])
    varenergy = PSI.get_variable(optimization_container, var_names[3])

    balance_cons_name = cons_names[1]
    target_cons_name = cons_names[2]

    balance_constraint = PSI.add_cons_container!(
        optimization_container,
        balance_cons_name,
        name_index,
        time_steps,
    )
    target_constraint =
        PSI.add_cons_container!(optimization_container, target_cons_name, name_index, 1)

    for (ix, d) in enumerate(inflow_data)
        name = PSI.get_component_name(d)
        upstream_devices = upstream[ix]

        exp =
            initial_conditions[ix].value +
            (d.multiplier * d.timeseries[1] - varspill[name, 1] - varout[name, 1]) *
            fraction_of_hour

        #= This is commented out because it constrains the cascading inflow in period 1 to upstream outflows in period 1 instead of
        if !isempty(upstream_devices)
            for j in upstream_devices
                JuMP.add_to_expression!(exp, varspill[IS.get_name(j), 1], fraction_of_hour)
                JuMP.add_to_expression!(exp, varout[IS.get_name(j), 1], fraction_of_hour)
            end
        end
        =#

        balance_constraint[name, 1] =
            JuMP.@constraint(optimization_container.JuMPmodel, varenergy[name, 1] == exp)

        for t in time_steps[2:end]
            exp =
                varenergy[name, t - 1] +
                (d.multiplier * d.timeseries[t] - varspill[name, t] - varout[name, t]) *
                fraction_of_hour

            if !isempty(upstream_devices)
                for j in upstream_devices
                    if t - j.lag >= 1
                        JuMP.add_to_expression!(
                            exp,
                            varspill[IS.get_name(j.unit), t - j.lag],
                            j.multiplier * fraction_of_hour,
                        )
                        JuMP.add_to_expression!(
                            exp,
                            varout[IS.get_name(j.unit), t - j.lag],
                            j.multiplier * fraction_of_hour,
                        )
                    end
                end
            end

            balance_constraint[name, t] = JuMP.@constraint(
                optimization_container.JuMPmodel,
                varenergy[name, t] == exp
            )
        end
    end

    for (ix, d) in enumerate(target_data)
        name = PSI.get_component_name(d)
        target_constraint[name, 1] = JuMP.@constraint(
            optimization_container.JuMPmodel,
            varenergy[name, time_steps[end]] >=
            d.multiplier * d.timeseries[time_steps[end]]
        )
    end

    return
end

function energy_balance_cascade_constraint!(
    optimization_container::PSI.OptimizationContainer,
    devices::IS.FlattenIteratorWrapper{H},
    model::PSI.DeviceModel{H, HydroDispatchReservoirCascade},
    system_formulation::Type{<:PM.AbstractPowerModel},
    feedforward::Union{Nothing, PSI.AbstractAffectFeedForward},
) where {H <: HydroEnergyCascade}
    key = PSI.ICKey(PSI.EnergyLevel, H)
    parameters = PSI.model_has_parameters(optimization_container)
    use_forecast_data = PSI.model_uses_forecasts(optimization_container)

    if !PSI.has_initial_conditions(optimization_container.initial_conditions, key)
        throw(
            IS.DataFormatError(
                "Initial Conditions for $(H) Energy Constraints not in the model",
            ),
        )
    end

    inflow_forecast_label = "inflow"
    target_forecast_label = "storage_target"
    constraint_infos_inflow =
        Vector{PSI.DeviceTimeSeriesConstraintInfo}(undef, length(devices))
    constraint_infos_target =
        Vector{PSI.DeviceTimeSeriesConstraintInfo}(undef, length(devices))
    upstream_data = Vector{
        Vector{NamedTuple{(:unit, :lag, :multiplier), Tuple{PSY.HydroGen, Int64, Float64}}},
    }(
        undef,
        length(devices),
    )

    for (ix, d) in enumerate(devices)
        ts_vector_inflow =
            PSI.get_time_series(optimization_container, d, inflow_forecast_label)
        constraint_info_inflow = PSI.DeviceTimeSeriesConstraintInfo(
            d,
            x -> PSY.get_inflow(x) * PSY.get_conversion_factor(x),
            ts_vector_inflow,
        )
        PSI.add_device_services!(constraint_info_inflow.range, d, model)
        constraint_infos_inflow[ix] = constraint_info_inflow

        ts_vector_target =
            PSI.get_time_series(optimization_container, d, target_forecast_label)
        constraint_info_target = PSI.DeviceTimeSeriesConstraintInfo(
            d,
            x -> PSY.get_storage_target(x) * PSY.get_storage_capacity(x),
            ts_vector_target,
        )
        PSI.add_device_services!(constraint_info_target.range, d, model)
        constraint_infos_target[ix] = constraint_info_target

        upstream_data[ix] = get_upstream(d)
    end

    if parameters
        energy_balance_external_input_param_cascade(
            optimization_container,
            PSI.get_initial_conditions(optimization_container, key),
            (constraint_infos_inflow, constraint_infos_target),
            upstream_data,
            (
                PSI.make_constraint_name(PSI.ENERGY_CAPACITY, H),
                PSI.make_constraint_name(PSI.ENERGY_TARGET, H),
            ),
            (
                PSI.make_variable_name(PSI.SPILLAGE, H),
                PSI.make_variable_name(PSI.ACTIVE_POWER, H),
                PSI.make_variable_name(PSI.ENERGY, H),
            ),
            (
                PSI.UpdateRef{H}(PSI.INFLOW, inflow_forecast_label),
                PSI.UpdateRef{H}(PSI.TARGET, target_forecast_label),
            ),
        )
    else
        energy_balance_external_input_cascade(
            optimization_container,
            PSI.get_initial_conditions(optimization_container, key),
            (constraint_infos_inflow, constraint_infos_target),
            upstream_data,
            (
                PSI.make_constraint_name(PSI.ENERGY_CAPACITY, H),
                PSI.make_constraint_name(PSI.ENERGY_TARGET, H),
            ),
            (
                PSI.make_variable_name(PSI.SPILLAGE, H),
                PSI.make_variable_name(PSI.ACTIVE_POWER, H),
                PSI.make_variable_name(PSI.ENERGY, H),
            ),
        )
    end
    return
end
