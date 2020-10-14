struct HydroDispatchRunOfRiverCascade <: PSI.AbstractHydroDispatchFormulation end

# Constraint name
const CASCADING_FLOW = "cascading_flow"

function flow_balance_external_input_param_cascade(
    psi_container::PSI.PSIContainer,
    inflow_data::Vector{PSI.DeviceTimeSeriesConstraintInfo},
    upstream::Vector{Vector{HydroCascade}},
    cons_name::Symbol,
    var_names::Tuple{Symbol, Symbol},
    param_reference::PSI.UpdateRef,
)
    time_steps = PSI.model_time_steps(psi_container)
    resolution = PSI.model_resolution(psi_container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / 60.0

    name_index = [PSI.get_component_name(d) for d in inflow_data]

    varspill = PSI.get_variable(psi_container, var_names[1])
    varout = PSI.get_variable(psi_container, var_names[2])

    container_inflow =
        PSI.add_param_container!(psi_container, param_reference, name_index, time_steps)
    param_inflow = PSI.get_parameter_array(container_inflow)
    multiplier_inflow = PSI.get_multiplier_array(container_inflow)

    flow_constraint =
        PSI.add_cons_container!(psi_container, cons_name, name_index, time_steps)

    for (ix, d) in enumerate(inflow_data)
        name = PSI.get_component_name(d)
        upstream_devices = upstream[ix]
        multiplier_inflow[name, 1] = d.multiplier
        param_inflow[name, 1] = PJ.add_parameter(psi_container.JuMPmodel, d.timeseries[1])

        exp =
            multiplier_inflow[name, 1] * param_inflow[name, 1] - varspill[name, 1] -
            varout[name, 1] #+ initial_conditions[ix].value
        #= spillage isn't an initial condition because it's not stored in the struct, so we can't make the cascading flow constrainits for the first periiod.
            for j in upstream_devices
                JuMP.add_to_expression!(exp, varspill[IS.get_name(j), 1])
                JuMP.add_to_expression!(exp, varout[IS.get_name(j), 1])
            end
        =#
        flow_constraint[name, 1] = JuMP.@constraint(psi_container.JuMPmodel, exp == 0.0)

        for t in time_steps[2:end]
            param_inflow[name, t] =
                PJ.add_parameter(psi_container.JuMPmodel, d.timeseries[t])

            exp = d.multiplier * param_inflow[name, t] - varspill[name, t] - varout[name, t]
            for j in upstream_devices
                JuMP.add_to_expression!(exp, varspill[IS.get_name(j), t - 1])
                JuMP.add_to_expression!(exp, varout[IS.get_name(j), t - 1])
            end
            flow_constraint[name, t] = JuMP.@constraint(psi_container.JuMPmodel, exp == 0.0)
        end
    end

    return
end

function flow_balance_external_input_cascade(
    psi_container::PSI.PSIContainer,
    inflow_data::Vector{PSI.DeviceTimeSeriesConstraintInfo},
    upstream::Vector{Vector{HydroCascade}},
    cons_name::Symbol,
    var_names::Tuple{Symbol, Symbol},
)
    time_steps = PSI.model_time_steps(psi_container)
    resolution = PSI.model_resolution(psi_container)
    fraction_of_hour = Dates.value(Dates.Minute(resolution)) / 60.0

    name_index = [PSI.get_component_name(d) for d in inflow_data]

    varspill = PSI.get_variable(psi_container, var_names[1])
    varout = PSI.get_variable(psi_container, var_names[2])

    flow_constraint =
        PSI.add_cons_container!(psi_container, cons_name, name_index, time_steps)

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
        flow_constraint[name, 1] = JuMP.@constraint(psi_container.JuMPmodel, exp == 0.0)

        for t in time_steps[2:end]
            exp = d.multiplier * d.timeseries[t] - varspill[name, t] - varout[name, t]

            for j in upstream_devices
                JuMP.add_to_expression!(exp, varspill[IS.get_name(j), t - 1])
                JuMP.add_to_expression!(exp, varout[IS.get_name(j), t - 1])
            end
            flow_constraint[name, t] = JuMP.@constraint(psi_container.JuMPmodel, exp == 0.0)
        end
    end
    return
end

function flow_balance_cascade_constraint!(
    psi_container::PSI.PSIContainer,
    devices::IS.FlattenIteratorWrapper{H},
    model::PSI.DeviceModel{H, HydroDispatchRunOfRiverCascade},
    system_formulation::Type{<:PM.AbstractPowerModel},
    feedforward::Union{Nothing, PSI.AbstractAffectFeedForward},
) where {H <: HydroCascade}
    parameters = PSI.model_has_parameters(psi_container)
    use_forecast_data = PSI.model_uses_forecasts(psi_container)

    inflow_forecast_label = "get_max_active_power"
    constraint_infos_inflow =
        Vector{PSI.DeviceTimeSeriesConstraintInfo}(undef, length(devices))
    upstream_data = Vector{Vector{HydroCascade}}(undef, length(devices))

    for (ix, d) in enumerate(devices)
        ts_vector_inflow = PSI.get_time_series(psi_container, d, inflow_forecast_label)
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
            psi_container,
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
            psi_container,
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
