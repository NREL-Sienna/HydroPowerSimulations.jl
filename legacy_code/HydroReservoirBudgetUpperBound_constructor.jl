function PSI.construct_device!(
    optimization_container::PSI.PSI.OptimizationContainer,
    sys::PSY.System,
    model::PSI.DeviceModel{H, D},
    ::Type{S},
) where {
    H <: PSY.HydroEnergyReservoir,
    D <: HydroDispatchReservoirBudgetUpperBound,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(H, sys)

    if !PSI.validate_available_devices(H, devices)
        return
    end

    # Variables
    PSI.add_variables!(optimization_container, PSI.ActivePowerVariable, devices, D())

    # Energy Budget Constraint
    PSI.energy_budget_constraints!(
        optimization_container,
        devices,
        model,
        S,
        PSI.get_feedforward(model),
    )

    # Range Constraints
    PSI.add_constraints!(
        optimization_container,
        PSI.RangeConstraint,
        PSI.ActivePowerVariable,
        devices,
        model,
        S,
        PSI.get_feedforward(model),
    )

    PSI.feedforward!(optimization_container, devices, model, PSI.get_feedforward(model))

    # Cost Function
    PSI.cost_function!(optimization_container, devices, model, S, nothing)

    return
end
