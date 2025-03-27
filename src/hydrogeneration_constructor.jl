"""
Construct model for [`PowerSystems.HydroGen``](@extref) with [`PowerSimulations.FixedOutput`](@extref) Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, PSI.FixedOutput},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroGen, S <: PM.AbstractPowerModel}
    devices = PSI.get_available_components(model, sys)

    PSI.add_parameters!(container, PSI.ActivePowerTimeSeriesParameter, devices, model)
    PSI.add_parameters!(container, PSI.ReactivePowerTimeSeriesParameter, devices, model)

    # Expression
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerTimeSeriesParameter,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ReactivePowerBalance,
        PSI.ReactivePowerTimeSeriesParameter,
        devices,
        model,
        network_model,
    )
    return
end

function PSI.construct_device!(
    ::PSI.OptimizationContainer,
    ::PSY.System,
    ::PSI.ModelConstructStage,
    ::PSI.DeviceModel{H, PSI.FixedOutput},
    ::PSI.NetworkModel{S},
) where {H <: PSY.HydroGen, S <: PM.AbstractPowerModel}
    # FixedOutput doesn't add any constraints to the model. This function covers
    # AbstractPowerModel and AbstractActivePowerModel
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, PSI.FixedOutput},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroGen, S <: PM.AbstractActivePowerModel}
    devices = PSI.get_available_components(model, sys)

    PSI.add_parameters!(container, PSI.ActivePowerTimeSeriesParameter, devices, model)

    # Expression
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerTimeSeriesParameter,
        devices,
        model,
        network_model,
    )
    return
end

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroDispatchRunOfRiver`](@ref) Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: AbstractHydroDispatchFormulation,
    S <: PM.AbstractPowerModel,
}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.ReactivePowerVariable, devices, D())
    PSI.add_variables!(container, HydroEnergyOutput, devices, D())
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ReactivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_parameters!(container, PSI.ActivePowerTimeSeriesParameter, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)

    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: AbstractHydroDispatchFormulation,
    S <: PM.AbstractPowerModel,
}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        PSI.ReactivePowerVariableLimitsConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_constraint_dual!(container, sys, model)

    return
end

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroDispatchRunOfRiver`](@ref) Formulation
with only Active Power.
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: AbstractHydroDispatchFormulation,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, HydroEnergyOutput, devices, D())
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_parameters!(container, PSI.ActivePowerTimeSeriesParameter, devices, model)
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: AbstractHydroDispatchFormulation,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)

    PSI.add_constraint_dual!(container, sys, model)
    return
end

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with ReservoirBudget Dispatch Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirBudget},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractPowerModel}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(
        container,
        PSI.ActivePowerVariable,
        devices,
        HydroDispatchReservoirBudget(),
    )
    PSI.add_variables!(
        container,
        PSI.ReactivePowerVariable,
        devices,
        HydroDispatchReservoirBudget(),
    )
    PSI.add_variables!(
        container,
        HydroEnergyOutput,
        devices,
        HydroDispatchReservoirBudget(),
    )
    PSI.add_parameters!(container, EnergyBudgetTimeSeriesParameter, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ReactivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirBudget},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractPowerModel}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        PSI.ReactivePowerVariableLimitsConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    # Energy Budget Constraint
    PSI.add_constraints!(container, EnergyBudgetConstraint, devices, model, network_model)

    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)

    PSI.add_constraint_dual!(container, sys, model)
    return
end

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroDispatchReservoirBudget`](@ref) Formulation
with only Active Power.
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirBudget},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(
        container,
        PSI.ActivePowerVariable,
        devices,
        HydroDispatchReservoirBudget(),
    )
    PSI.add_variables!(
        container,
        HydroEnergyOutput,
        devices,
        HydroDispatchReservoirBudget(),
    )
    PSI.add_parameters!(container, EnergyBudgetTimeSeriesParameter, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirBudget},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    # Energy Budget Constraint
    PSI.add_constraints!(container, EnergyBudgetConstraint, devices, model, network_model)

    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_constraint_dual!(container, sys, model)

    return
end

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroDispatchReservoirStorage`](@ref) Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirStorage},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractPowerModel}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(
        container,
        PSI.ActivePowerVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        PSI.ReactivePowerVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        PSI.EnergyVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        WaterSpillageVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        HydroEnergyShortageVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        HydroEnergySurplusVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        HydroEnergyOutput,
        devices,
        HydroDispatchReservoirStorage(),
    )
    PSI.add_parameters!(container, EnergyTargetTimeSeriesParameter, devices, model)
    PSI.add_parameters!(container, InflowTimeSeriesParameter, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ReactivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirStorage},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractPowerModel}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        PSI.ReactivePowerVariableLimitsConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_initial_condition!(
        container,
        devices,
        HydroDispatchReservoirStorage(),
        PSI.InitialEnergyLevel(),
    )
    # Energy Balance Constraint
    PSI.add_constraints!(
        container,
        PSI.EnergyBalanceConstraint,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(container, EnergyTargetConstraint, devices, model, network_model)
    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)

    PSI.add_constraint_dual!(container, sys, model)
    return
end

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroDispatchReservoirStorage`](@ref) Formulation
with only Active Power
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirStorage},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(
        container,
        PSI.ActivePowerVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        PSI.EnergyVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        WaterSpillageVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        HydroEnergyShortageVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        HydroEnergySurplusVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        HydroEnergyOutput,
        devices,
        HydroDispatchReservoirStorage(),
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_parameters!(container, EnergyTargetTimeSeriesParameter, devices, model)
    PSI.add_parameters!(container, InflowTimeSeriesParameter, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_arguments!(container, model, devices)

    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirStorage},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_initial_condition!(
        container,
        devices,
        HydroDispatchReservoirStorage(),
        PSI.InitialEnergyLevel(),
    )
    # Energy Balance Constraint
    PSI.add_constraints!(
        container,
        PSI.EnergyBalanceConstraint,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(container, EnergyTargetConstraint, devices, model, network_model)
    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_constraint_dual!(container, sys, model)

    return
end

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroCommitmentReservoirBudget`](@ref) Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroGen, D <: HydroCommitmentReservoirBudget, S <: PM.AbstractPowerModel}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.ReactivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.OnVariable, devices, D())
    PSI.add_variables!(container, HydroEnergyOutput, devices, D())
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_parameters!(container, EnergyBudgetTimeSeriesParameter, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroGen, D <: HydroCommitmentReservoirBudget, S <: PM.AbstractPowerModel}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        PSI.ReactivePowerVariableLimitsConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )
    # Energy Budget Constraint
    PSI.add_constraints!(container, EnergyBudgetConstraint, devices, model, network_model)

    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_constraint_dual!(container, sys, model)

    return
end

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroCommitmentReservoirBudget`](@ref) Formulation
with only Active Power.
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: HydroCommitmentReservoirBudget,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.OnVariable, devices, D())
    PSI.add_variables!(container, HydroEnergyOutput, devices, D())
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_parameters!(container, EnergyBudgetTimeSeriesParameter, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_feedforward_arguments!(container, model, devices)

    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: HydroCommitmentReservoirBudget,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    # Energy Budget Constraint
    PSI.add_constraints!(container, EnergyBudgetConstraint, devices, model, network_model)

    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)

    PSI.add_constraint_dual!(container, sys, model)
    return
end

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroCommitmentReservoirStorage`](@ref) Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroCommitmentReservoirStorage},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractPowerModel}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(
        container,
        PSI.ActivePowerVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        PSI.ReactivePowerVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        PSI.OnVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        PSI.EnergyVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        WaterSpillageVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        HydroEnergyShortageVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        HydroEnergySurplusVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        HydroEnergyOutput,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_parameters!(container, EnergyTargetTimeSeriesParameter, devices, model)
    PSI.add_parameters!(container, InflowTimeSeriesParameter, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, HydroCommitmentReservoirStorage},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractPowerModel}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        PSI.ReactivePowerVariableLimitsConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_initial_condition!(
        container,
        devices,
        HydroCommitmentReservoirStorage(),
        PSI.InitialEnergyLevel(),
    )
    # Energy Balance Constraint
    PSI.add_constraints!(
        container,
        PSI.EnergyBalanceConstraint,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(container, EnergyTargetConstraint, devices, model, network_model)
    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_constraint_dual!(container, sys, model)

    return
end

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroCommitmentReservoirStorage`](@ref) Formulation
with only Active Power
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroCommitmentReservoirStorage},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_variables!(
        container,
        PSI.ActivePowerVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        PSI.OnVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        PSI.EnergyVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        WaterSpillageVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        HydroEnergyShortageVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    PSI.add_variables!(
        container,
        HydroEnergySurplusVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_variables!(
        container,
        HydroEnergyOutput,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    PSI.add_parameters!(container, EnergyTargetTimeSeriesParameter, devices, model)
    PSI.add_parameters!(container, InflowTimeSeriesParameter, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, HydroCommitmentReservoirStorage},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_initial_condition!(
        container,
        devices,
        HydroCommitmentReservoirStorage(),
        PSI.InitialEnergyLevel(),
    )

    # Energy Balance Constraint
    PSI.add_constraints!(
        container,
        PSI.EnergyBalanceConstraint,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(container, EnergyTargetConstraint, devices, model, network_model)
    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_constraint_dual!(container, sys, model)

    return
end

"""
Construct model for [`PowerSystems.HydroPumpedStorage`](@extref) with [`HydroDispatchPumpedStorage`](@ref) Formulation
with only Active Power
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchPumpedStorage},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroPumpedStorage, S <: PM.AbstractActivePowerModel}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(
        container,
        PSI.ActivePowerInVariable,
        devices,
        HydroDispatchPumpedStorage(),
    )
    PSI.add_variables!(
        container,
        PSI.ActivePowerOutVariable,
        devices,
        HydroDispatchPumpedStorage(),
    )
    PSI.add_variables!(
        container,
        HydroEnergyVariableUp,
        devices,
        HydroDispatchPumpedStorage(),
    )
    PSI.add_variables!(
        container,
        HydroEnergyVariableDown,
        devices,
        HydroDispatchPumpedStorage(),
    )
    PSI.add_variables!(
        container,
        WaterSpillageVariable,
        devices,
        HydroDispatchPumpedStorage(),
    )
    PSI.add_variables!(container, HydroEnergyOutput, devices, HydroDispatchPumpedStorage())
    if PSI.get_attribute(model, "reservation")
        PSI.add_variables!(
            container,
            PSI.ReservationVariable,
            devices,
            HydroDispatchPumpedStorage(),
        )
    end

    PSI.add_parameters!(container, InflowTimeSeriesParameter, devices, model)
    PSI.add_parameters!(container, OutflowTimeSeriesParameter, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerInVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerOutVariable,
        devices,
        model,
        network_model,
    )
    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            ReserveRangeExpressionUB,
            PSI.ActivePowerOutVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            ReserveRangeExpressionLB,
            PSI.ActivePowerOutVariable,
            devices,
            model,
            network_model,
        )
    end
    # PSI.add_range_constraints!(container, ReserveRangeExpressionLB, devices, model)
    # PSI.add_range_constraints!(container, ReserveRangeExpressionUB, devices, model)

    PSI.add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchPumpedStorage},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroPumpedStorage, S <: PM.AbstractActivePowerModel}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    _add_output_limit_constraints!(
        container,
        PSI.OutputActivePowerVariableLimitsConstraint,
        devices,
        model,
        network_model,
    )

    PSI.add_constraints!(
        container,
        PSI.InputActivePowerVariableLimitsConstraint,
        PSI.ActivePowerInVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_initial_condition!(
        container,
        devices,
        HydroDispatchPumpedStorage(),
        InitialHydroEnergyLevelUp(),
    )
    PSI.add_initial_condition!(
        container,
        devices,
        HydroDispatchPumpedStorage(),
        InitialHydroEnergyLevelDown(),
    )

    # Energy Balance limits
    PSI.add_constraints!(
        container,
        EnergyCapacityUpConstraint,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        EnergyCapacityDownConstraint,
        devices,
        model,
        network_model,
    )
    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)

    PSI.add_constraint_dual!(container, sys, model)
    return
end

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroCommitmentRunOfRiver`](@ref) Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroGen, D <: HydroCommitmentRunOfRiver, S <: PM.AbstractPowerModel}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.ReactivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.OnVariable, devices, D())
    PSI.add_variables!(container, HydroEnergyOutput, devices, D())
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_to_expression!(
        container,
        PSI.ReactivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_parameters!(container, PSI.ActivePowerTimeSeriesParameter, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_feedforward_arguments!(container, model, devices)
    return
end

"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroCommitmentRunOfRiver`](@ref) Formulation
with only Active Power.
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: HydroCommitmentRunOfRiver,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.OnVariable, devices, D())
    PSI.add_variables!(container, HydroEnergyOutput, devices, D())
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_parameters!(container, PSI.ActivePowerTimeSeriesParameter, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)
    if PSI.has_service_model(model)
        PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
        PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: HydroCommitmentRunOfRiver,
    S <: PM.AbstractActivePowerModel,
}
    devices = PSI.get_available_components(model, sys)

    if PSI.has_service_model(model)
        PSI.add_to_expression!(
            container,
            HydroServedReserveUpExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
        PSI.add_to_expression!(
            container,
            HydroServedReserveDownExpression,
            PSI.ActivePowerReserveVariable,
            devices,
            model,
            network_model,
        )
    end

    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    PSI.add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)

    PSI.add_constraint_dual!(container, sys, model)
    return
end

################################################################################################
#### New Hydro Block Optimization Model ####
"""
Construct model for [`PowerSystems.HydroGen`](@extref) with [`HydroEnergyBlockOptimization`](@ref) Formulation
with only Active Power
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroEnergyBlockOptimization},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = PSI.get_available_components(model, sys)

    PSI.add_variables!(
        container,
        PSI.ActivePowerVariable,
        devices,
        HydroEnergyBlockOptimization(),
    )
    PSI.add_variables!(
        container,
        HydroTurbinedOutflow,
        devices,
        HydroEnergyBlockOptimization(),
    )    
    PSI.add_variables!(
        container,
        WaterSpillageVariable,
        devices,
        HydroEnergyBlockOptimization(),
    )
    PSI.add_variables!(
        container,
        HydroEnergyVariableUp,
        devices,
        HydroEnergyBlockOptimization(),
    )    
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_parameters!(container, InflowTimeSeriesParameter, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)

    # if PSI.has_service_model(model)
    #     PSI.add_expressions!(container, HydroServedReserveUpExpression, devices, model)
    #     PSI.add_expressions!(container, HydroServedReserveDownExpression, devices, model)
    # end

    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    PSI.add_to_expression!(
        container,
        PSI.ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    PSI.add_feedforward_arguments!(container, model, devices)

    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, HydroEnergyBlockOptimization},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = PSI.get_available_components(model, sys)

    # if PSI.has_service_model(model)
    #     PSI.add_to_expression!(
    #         container,
    #         HydroServedReserveUpExpression,
    #         PSI.ActivePowerReserveVariable,
    #         devices,
    #         model,
    #         network_model,
    #     )
    #     PSI.add_to_expression!(
    #         container,
    #         HydroServedReserveDownExpression,
    #         PSI.ActivePowerReserveVariable,
    #         devices,
    #         model,
    #         network_model,
    #     )
    # end

    # PSI.add_constraints!(
    #     container,
    #     PSI.ActivePowerVariableLimitsConstraint,
    #     PSI.ActivePowerRangeExpressionLB,
    #     devices,
    #     model,
    #     network_model,
    # )
    # PSI.add_constraints!(
    #     container,
    #     PSI.ActivePowerVariableLimitsConstraint,
    #     PSI.ActivePowerRangeExpressionUB,
    #     devices,
    #     model,
    #     network_model,
    # )

    # PSI.add_initial_condition!(
    #     container,
    #     devices,
    #     HydroDispatchReservoirStorage(),
    #     PSI.InitialEnergyLevel(),
    # )

    # # Energy Balance Constraint
    # PSI.add_constraints!(
    #     container,
    #     PSI.EnergyBalanceConstraint,
    #     devices,
    #     model,
    #     network_model,
    # )

    # PSI.add_constraints!(container, EnergyTargetConstraint, devices, model, network_model)

    PSI.add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_constraint_dual!(container, sys, model)

    return
end