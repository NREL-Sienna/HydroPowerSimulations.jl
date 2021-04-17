function PSI.construct_device!(
    optimization_container::PSI.OptimizationContainer,
    sys::PSY.System,
    model::PSI.DeviceModel{H, HydroDispatchReservoirCascade},
    ::Type{S},
) where {H <: HydroEnergyCascade, S <: PM.AbstractActivePowerModel}
    devices = PSI.get_available_components(H, sys)

    if !PSI.validate_available_devices(H, devices)
        return
    end

    #Variables
    PSI.add_variables!(optimization_container, PSI.ActivePowerVariable, devices)
    PSI.add_variables!(optimization_container, PSI.EnergyVariable, devices)
    PSI.add_variables!(optimization_container, PSI.SpillageVariable, devices)

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
    PSI.cost_function(optimization_container, devices, HydroDispatchReservoirCascade, S)

    return
end

function PSI.construct_device!(
    optimization_container::PSI.OptimizationContainer,
    sys::PSY.System,
    model::PSI.DeviceModel{H, HydroDispatchReservoirCascade},
    ::Type{S},
) where {H <: HydroEnergyCascade, S <: PM.AbstractPowerModel}
    devices = PSI.get_available_components(H, sys)

    if !PSI.validate_available_devices(H, devices)
        return
    end

    #Variables
    PSI.add_variables!(optimization_container, PSI.ActivePowerVariable, devices)
    PSI.add_variables!(optimization_container, PSI.EnergyVariable, devices)
    PSI.add_variables!(optimization_container, PSI.SpillageVariable, devices)
    PSI.add_variables!(optimization_container, PSI.ReactivePowerVariable, devices)

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
    PSI.cost_function(optimization_container, devices, HydroDispatchReservoirCascade, S)

    return
end
