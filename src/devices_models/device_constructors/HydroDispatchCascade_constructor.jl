
"""
Construct model for HydroGen with RunOfRiver Dispatch Formulation
"""
function PSI.construct_device!(
    optimization_container::PSI.OptimizationContainer,
    sys::PSY.System,
    model::PSI.DeviceModel{H, D},
    ::Type{S},
) where {H <: HydroCascade, D <: HydroDispatchRunOfRiverCascade, S <: PM.AbstractPowerModel}
    devices = PSI.get_available_components(H, sys)

    if !PSI.validate_available_devices(H, devices)
        return
    end

    #Variables
    PSI.add_variables!(optimization_container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(optimization_container, PSI.ReactivePowerVariable, devices, D())
    PSI.add_variables!(optimization_container, PSI.SpillageVariable, devices, D())

    #Constraints
    #=
    PSI.add_constraints!(
        optimization_container,
        PSI.RangeConstraint,
        PSI.ActivePowerVariable,
        devices,
        model,
        S,
        PSI.get_feedforward(model),
    )
    PSI.add_constraints!(
        optimization_container,
        PSI.RangeConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        S,
        PSI.get_feedforward(model),
    )=#
    flow_balance_cascade_constraint!(
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

"""
Construct model for HydroGen with RunOfRiver Dispatch Formulation
with only Active Power.
"""
function PSI.construct_device!(
    optimization_container::PSI.OptimizationContainer,
    sys::PSY.System,
    model::PSI.DeviceModel{H, D},
    ::Type{S},
) where {
    H <: HydroCascade,
    D <: HydroDispatchRunOfRiverCascade,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(H, sys)

    if !PSI.validate_available_devices(H, devices)
        return
    end

    #Variables
    PSI.add_variables!(optimization_container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(optimization_container, PSI.SpillageVariable, devices, D())

    #Constraints
    #=
    PSI.add_constraints!(
        optimization_container,
        PSI.RangeConstraint,
        PSI.ActivePowerVariable,
        devices,
        model,
        S,
        PSI.get_feedforward(model),
    )=#
    flow_balance_cascade_constraint!(
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
