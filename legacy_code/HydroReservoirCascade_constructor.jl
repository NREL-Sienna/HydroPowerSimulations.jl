function PSI.construct_device!(
    optimization_container::PSI.PSI.OptimizationContainer,
    sys::PSY.System,
    model::PSI.DeviceModel{H, D},
    ::Type{S},
) where {
    H <: HydroEnergyCascade,
    D <: HydroDispatchReservoirCascade,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(H, sys)

    if !PSI.validate_available_devices(H, devices)
        return
    end

    #Variables
    PSI.add_variables!(optimization_container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(optimization_container, PSI .. EnergyVariable, devices, D())
    PSI.add_variables!(optimization_container, PSI.SpillageVariable, devices, D())

    #Initial Conditions
    PSI.storage_energy_init(optimization_container, devices)

    #Constraints
    energy_balance_cascade_constraint!(
        optimization_container,
        devices,
        model,
        S,
        PSI.get_feedforward(model),
    )
    PSI.feedforward!(optimization_container, devices, model, PSI.get_feedforward(model))

    #Cost Function
    PSI.cost_function!(optimization_container, devices, model, S, nothing)

    return
end

function PSI.construct_device!(
    optimization_container::PSI.PSI.OptimizationContainer,
    sys::PSY.System,
    model::PSI.DeviceModel{H, D},
    ::Type{S},
) where {
    H <: HydroEnergyCascade,
    D <: HydroDispatchReservoirCascade,
    S <: PM.AbstractPowerModel,
}
    devices = PSI.get_available_components(H, sys)

    if !PSI.validate_available_devices(H, devices)
        return
    end

    #Variables
    PSI.add_variables!(optimization_container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(optimization_container, PSI .. EnergyVariable, devices, D())
    PSI.add_variables!(optimization_container, PSI.SpillageVariable, devices, D())
    PSI.add_variables!(optimization_container, PSI.ReactivePowerVariable, devices, D())

    #Initial Conditions
    PSI.storage_energy_init(optimization_container, devices)

    #Constraints
    PSI.add_constraints!(
        optimization_container,
        PSI.RangeConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        S,
        PSI.get_feedforward(model),
    )
    energy_balance_cascade_constraint!(
        optimization_container,
        devices,
        model,
        S,
        PSI.get_feedforward(model),
    )
    PSI.feedforward!(optimization_container, devices, model, PSI.get_feedforward(model))

    #Cost Function
    PSI.cost_function!(optimization_container, devices, model, S, nothing)

    return
end
