function PSI.construct_device!(
    psi_container::PSI.PSIContainer,
    sys::PSY.System,
    model::PSI.DeviceModel{H, HydroDispatchReservoirBudgetUpperBound},
    ::Type{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = PSI.get_available_components(H, sys)

    if !PSI.validate_available_devices(H, devices)
        return
    end

    # Variables
    PSI.add_variables!(psi_container, PSI.ActivePowerVariable, devices)

    # Energy Budget Constraint
    PSI.energy_budget_constraints!(psi_container, devices, model, S, PSI.get_feedforward(model))

    # Range Constraints
    PSI.add_constraints!(
        psi_container,
        PSI.RangeConstraint,
        PSI.ActivePowerVariable,
        devices,
        model,
        S,
        PSI.get_feedforward(model),
    )

    PSI.feedforward!(psi_container, devices, model, PSI.get_feedforward(model))

    # Cost Function
    PSI.cost_function!(psi_container, devices, model, S, nothing)

    return
end