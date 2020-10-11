function PSI.construct_device!(
    psi_container::PSI.PSIContainer,
    sys::PSY.System,
    model::PSI.DeviceModel{H, HydroDispatchReservoirCascade},
    ::Type{S},
) where {H <: HydroEnergyCascade, S <: PM.AbstractActivePowerModel}
    devices = PSI.get_available_components(H, sys)

    if !PSI.validate_available_devices(H, devices)
        return
    end

    #Variables
    PSI.add_variables!(psi_container, PSI.ActivePowerVariable, devices)
    PSI.add_variables!(psi_container, PSI.EnergyVariable, devices)
    PSI.add_variables!(psi_container, PSI.SpillageVariable, devices)

    #Initial Conditions
    PSI.storage_energy_init(psi_container, devices)

    energy_balance_cascade_constraint!(psi_container, devices, model, S, PSI.get_feedforward(model))
    PSI.feedforward!(psi_container, devices, model, PSI.get_feedforward(model))

    #Cost Function
    PSI.cost_function(psi_container, devices, HydroDispatchReservoirCascade, S)

    return
end

function PSI.construct_device!(
    psi_container::PSI.PSIContainer,
    sys::PSY.System,
    model::PSI.DeviceModel{H, HydroDispatchReservoirCascade},
    ::Type{S},
) where {H <: HydroEnergyCascade, S <: PM.AbstractPowerModel}
    devices = PSI.get_available_components(H, sys)

    if !PSI.validate_available_devices(H, devices)
        return
    end


    #Variables
    PSI.add_variables!(psi_container, PSI.ActivePowerVariable, devices)
    PSI.add_variables!(psi_container, PSI.EnergyVariable, devices)
    PSI.add_variables!(psi_container, PSI.SpillageVariable, devices)
    PSI.add_variables!(psi_container, PSI.ReactivePowerVariable, devices)

    #Initial Conditions
    PSI.storage_energy_init(psi_container, devices)

    #Constraints
    energy_balance_cascade_constraint!(psi_container, devices, model, S, PSI.get_feedforward(model))
    PSI.feedforward!(psi_container, devices, model, PSI.get_feedforward(model))

    #Cost Function
    PSI.cost_function(psi_container, devices, HydroDispatchReservoirCascade, S)

    return
end
