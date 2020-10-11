
"""
Construct model for HydroGen with RunOfRiver Dispatch Formulation
"""
function PSI.construct_device!(
    psi_container::PSI.PSIContainer,
    sys::PSY.System,
    model::PSI.DeviceModel{H, HydroDispatchRunOfRiverCascade},
    ::Type{S},
) where {
    H <: HydroCascade,
    S <: PM.AbstractPowerModel,
}
    devices = PSI.get_available_components(H, sys)

    if !PSI.validate_available_devices(H, devices)
        return
    end

    #Variables
    PSI.add_variables!(psi_container, PSI.ActivePowerVariable, devices)
    PSI.add_variables!(psi_container, PSI.ReactivePowerVariable, devices)
    PSI.add_variables!(psi_container, PSI.SpillageVariable, devices)


    #Constraints
    PSI.add_constraints!(
        psi_container,
        PSI.RangeConstraint,
        PSI.ActivePowerVariable,
        devices,
        model,
        S,
        PSI.get_feedforward(model),
    )
    PSI.add_constraints!(
        psi_container,
        PSI.RangeConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        S,
        PSI.get_feedforward(model),
    )
    flow_balance_cascade_constraint!(psi_container, devices, model, S, PSI.get_feedforward(model))


    PSI.feedforward!(psi_container, devices, model, PSI.get_feedforward(model))

    #Cost Function
    PSI.cost_function(psi_container, devices, HydroDispatchReservoirCascade, S)

    return
end

"""
Construct model for HydroGen with RunOfRiver Dispatch Formulation
with only Active Power.
"""
function PSI.construct_device!(
    psi_container::PSI.PSIContainer,
    sys::PSY.System,
    model::PSI.DeviceModel{H, HydroDispatchRunOfRiverCascade},
    ::Type{S},
) where {
    H <: HydroCascade,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(H, sys)

    if !PSI.validate_available_devices(H, devices)
        return
    end

    #Variables
    PSI.add_variables!(psi_container, PSI.ActivePowerVariable, devices)
    PSI.add_variables!(psi_container, PSI.SpillageVariable, devices)


    #Constraints
    PSI.add_constraints!(
        psi_container,
        PSI.RangeConstraint,
        PSI.ActivePowerVariable,
        devices,
        model,
        S,
        PSI.get_feedforward(model),
    )
    flow_balance_cascade_constraint!(psi_container, devices, model, S, PSI.get_feedforward(model))

    PSI.feedforward!(psi_container, devices, model, PSI.get_feedforward(model))

    #Cost Function
    PSI.cost_function(psi_container, devices, HydroDispatchReservoirCascade, S)

    return
end
