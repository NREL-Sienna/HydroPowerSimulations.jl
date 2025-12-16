function PSI.add_event_constraints!(
    container::PSI.OptimizationContainer,
    devices::T,
    device_model::PSI.DeviceModel{U, V},
    network_model::PSI.NetworkModel{W},
) where {
    T <: Union{Vector{U}, IS.FlattenIteratorWrapper{U}},
    V <: PSI.AbstractDeviceFormulation,
    W <: PM.AbstractActivePowerModel,
} where {U <: PSY.HydroGen}
    for (key, event_model) in PSI.get_events(device_model)
        event_type = PSI.get_entry_type(key)
        devices_with_attributes =
            [d for d in devices if PSY.has_supplemental_attributes(d, event_type)]
        isempty(devices_with_attributes) &&
            error("no devices found with a supplemental attribute for event $event_type")
        PSI.add_parameterized_upper_bound_range_constraints(
            container,
            PSI.ActivePowerOutageConstraint,
            PSI.ActivePowerRangeExpressionUB,
            PSI.AvailableStatusParameter,
            devices_with_attributes,
            device_model,
            W,
        )
    end
    return
end

function PSI.add_event_constraints!(
    container::PSI.OptimizationContainer,
    devices::T,
    device_model::PSI.DeviceModel{U, V},
    network_model::PSI.NetworkModel{W},
) where {
    T <: Union{Vector{U}, IS.FlattenIteratorWrapper{U}},
    V <: PSI.AbstractDeviceFormulation,
    W <: PM.AbstractPowerModel,
} where {U <: PSY.HydroGen}
    for (key, event_model) in PSI.get_events(device_model)
        event_type = PSI.get_entry_type(key)
        devices_with_attributes =
            [d for d in devices if PSY.has_supplemental_attributes(d, event_type)]
        isempty(devices_with_attributes) &&
            error("no devices found with a supplemental attribute for event $event_type")
        PSI.add_parameterized_upper_bound_range_constraints(
            container,
            PSI.ActivePowerOutageConstraint,
            PSI.ActivePowerRangeExpressionUB,
            PSI.AvailableStatusParameter,
            devices_with_attributes,
            device_model,
            W,
        )
        PSI.add_reactive_power_contingency_constraint(
            container,
            ReactivePowerOutageConstraint,
            ReactivePowerVariable,
            AvailableStatusParameter,
            devices_with_attributes,
            device_model,
            W,
        )
    end
    return
end

function PSI.add_event_constraints!(
    container::PSI.OptimizationContainer,
    devices::T,
    device_model::PSI.DeviceModel{U, V},
    network_model::PSI.NetworkModel{W},
) where {
    T <: Union{Vector{U}, IS.FlattenIteratorWrapper{U}},
    V <: PSI.AbstractDeviceFormulation,
    W <: PM.AbstractActivePowerModel,
} where {U <: PSY.HydroPumpTurbine}
    for (key, event_model) in PSI.get_events(device_model)
        event_type = PSI.get_entry_type(key)
        devices_with_attributes =
            [d for d in devices if PSY.has_supplemental_attributes(d, event_type)]
        isempty(devices_with_attributes) &&
            error("no devices found with a supplemental attribute for event $event_type")
        add_pump_turbine_active_power_contingency_constraints!(
            container,
            devices_with_attributes,
            device_model,
        )
    end
    return
end

function PSI.add_event_constraints!(
    container::PSI.OptimizationContainer,
    devices::T,
    device_model::PSI.DeviceModel{U, V},
    network_model::PSI.NetworkModel{W},
) where {
    T <: Union{Vector{U}, IS.FlattenIteratorWrapper{U}},
    V <: PSI.AbstractDeviceFormulation,
    W <: PM.AbstractPowerModel,
} where {U <: PSY.HydroPumpTurbine}
    for (key, event_model) in PSI.get_events(device_model)
        event_type = PSI.get_entry_type(key)
        devices_with_attributes =
            [d for d in devices if PSY.has_supplemental_attributes(d, event_type)]
        isempty(devices_with_attributes) &&
            error("no devices found with a supplemental attribute for event $event_type")
        add_pump_turbine_active_power_contingency_constraints!(
            container,
            devices_with_attributes,
            device_model,
        )
        PSI.add_reactive_power_contingency_constraint(
            container,
            ReactivePowerOutageConstraint,
            ReactivePowerVariable,
            AvailableStatusParameter,
            devices_with_attributes,
            device_model,
            W,
        )
    end
    return
end

function add_pump_turbine_active_power_contingency_constraints!(
    container::PSI.OptimizationContainer,
    devices::T,
    device_model::PSI.DeviceModel{U, V},
) where {
    T <: Union{Vector{U}, IS.FlattenIteratorWrapper{U}},
    V <: PSI.AbstractDeviceFormulation,
} where {U <: PSY.HydroPumpTurbine}
    names = PSY.get_name.(devices)
    time_steps = PSI.get_time_steps(container)
    array_active_power = PSI.get_variable(container, PSI.ActivePowerVariable(), U)
    array_active_power_pump = PSI.get_variable(container, ActivePowerPumpVariable(), U)
    constraint_active_power = PSI.add_constraints_container!(
        container,
        PSI.ActivePowerOutageConstraint(),
        U,
        names,
        time_steps,
    )
    constraint_active_power_pump = PSI.add_constraints_container!(
        container,
        ActivePowerPumpOutageConstraint(),
        U,
        names,
        time_steps,
    )
    param_array = PSI.get_parameter_array(container, PSI.AvailableStatusParameter(), U)
    jump_model = PSI.get_jump_model(container)
    time_steps = axes(constraint_active_power)[2]
    for device in devices, t in time_steps
        name = PSY.get_name(device)
        ub_active_power = PSY.get_active_power_limits(device).max
        constraint_active_power[name, t] = JuMP.@constraint(
            jump_model,
            array_active_power[name, t] <= ub_active_power * param_array[name, t]
        )
        ub_active_power_pump = PSY.get_active_power_limits_pump(device).max
        constraint_active_power_pump[name, t] = JuMP.@constraint(
            jump_model,
            array_active_power_pump[name, t] <= ub_active_power_pump * param_array[name, t]
        )
    end
    return
end
