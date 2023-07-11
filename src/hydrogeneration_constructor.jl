"""
Construct model for HydroGen with FixedOutput Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, FixedOutput},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroGen, S <: PM.AbstractPowerModel}
    devices = get_available_components(H, sys)

    add_parameters!(container, ActivePowerTimeSeriesParameter, devices, model)
    add_parameters!(container, ReactivePowerTimeSeriesParameter, devices, model)

    # Expression
    add_to_expression!(
        container,
        ActivePowerBalance,
        ActivePowerTimeSeriesParameter,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ReactivePowerBalance,
        ReactivePowerTimeSeriesParameter,
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
    ::PSI.DeviceModel{H, FixedOutput},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroGen, S <: PM.AbstractPowerModel}
    # FixedOutput doesn't add any constraints to the model. This function covers
    # AbstractPowerModel and AbtractActivePowerModel
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, FixedOutput},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroGen, S <: PM.AbstractActivePowerModel}
    devices = get_available_components(H, sys)

    add_parameters!(container, ActivePowerTimeSeriesParameter, devices, model)

    # Expression
    add_to_expression!(
        container,
        ActivePowerBalance,
        ActivePowerTimeSeriesParameter,
        devices,
        model,
        network_model,
    )
    return
end

"""
Construct model for HydroGen with RunOfRiver Dispatch Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: AbstractHydroDispatchFormulation,
    S <: PM.AbstractPowerModel,
}
    devices = get_available_components(H, sys)

    add_variables!(container, PSI.ActivePowerVariable, devices, D())
    add_variables!(container, PSI.ReactivePowerVariable, devices, D())
    add_variables!(container, EnergyOutput, devices, D())
    add_to_expression!(
        container,
        ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ReactivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    add_parameters!(container, ActivePowerTimeSeriesParameter, devices, model)

    add_expressions!(container, ProductionCostExpression, devices, model)

    add_to_expression!(
        container,
        ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: AbstractHydroDispatchFormulation,
    S <: PM.AbstractPowerModel,
}
    devices = get_available_components(H, sys)

    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    add_constraints!(
        container,
        PSI.ReactivePowerVariableLimitsConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_feedforward_constraints!(container, model, devices)

    objective_function!(container, devices, model, S)
    add_constraint_dual!(container, sys, model)

    return
end

"""
Construct model for HydroGen with RunOfRiver Dispatch Formulation
with only Active Power.
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: AbstractHydroDispatchFormulation,
    S <: PM.AbstractActivePowerModel,
}
    devices = get_available_components(H, sys)

    add_variables!(container, PSI.ActivePowerVariable, devices, D())
    add_variables!(container, EnergyOutput, devices, D())
    add_to_expression!(
        container,
        ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    add_parameters!(container, ActivePowerTimeSeriesParameter, devices, model)
    add_to_expression!(
        container,
        ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    add_expressions!(container, ProductionCostExpression, devices, model)

    add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: AbstractHydroDispatchFormulation,
    S <: PM.AbstractActivePowerModel,
}
    devices = get_available_components(H, sys)

    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    add_feedforward_constraints!(container, model, devices)

    objective_function!(container, devices, model, S)

    add_constraint_dual!(container, sys, model)
    return
end

"""
Construct model for HydroGen with ReservoirBudget Dispatch Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirBudget},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractPowerModel}
    devices = get_available_components(H, sys)

    add_variables!(container, PSI.ActivePowerVariable, devices, HydroDispatchReservoirBudget())
    add_variables!(
        container,
        PSI.ReactivePowerVariable,
        devices,
        HydroDispatchReservoirBudget(),
    )
    add_variables!(container, EnergyOutput, devices, HydroDispatchReservoirBudget())
    add_parameters!(container, EnergyBudgetTimeSeriesParameter, devices, model)

    add_expressions!(container, ProductionCostExpression, devices, model)

    add_to_expression!(
        container,
        ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ReactivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirBudget},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractPowerModel}
    devices = get_available_components(H, sys)

    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    add_constraints!(
        container,
        PSI.ReactivePowerVariableLimitsConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    # Energy Budget Constraint
    add_constraints!(container, EnergyBudgetConstraint, devices, model, network_model)

    add_feedforward_constraints!(container, model, devices)

    objective_function!(container, devices, model, S)

    add_constraint_dual!(container, sys, model)
    return
end

"""
Construct model for HydroGen with ReservoirBudget Dispatch Formulation
with only Active Power.
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirBudget},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = get_available_components(H, sys)

    add_variables!(container, PSI.ActivePowerVariable, devices, HydroDispatchReservoirBudget())
    add_variables!(container, EnergyOutput, devices, HydroDispatchReservoirBudget())
    add_parameters!(container, EnergyBudgetTimeSeriesParameter, devices, model)

    add_expressions!(container, ProductionCostExpression, devices, model)

    add_to_expression!(
        container,
        ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    add_to_expression!(
        container,
        ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirBudget},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = get_available_components(H, sys)

    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    # Energy Budget Constraint
    add_constraints!(container, EnergyBudgetConstraint, devices, model, network_model)

    add_feedforward_constraints!(container, model, devices)

    objective_function!(container, devices, model, S)
    add_constraint_dual!(container, sys, model)

    return
end

"""
Construct model for HydroGen with ReservoirStorage Dispatch Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirStorage},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractPowerModel}
    devices = get_available_components(H, sys)

    add_variables!(container, PSI.ActivePowerVariable, devices, HydroDispatchReservoirStorage())
    add_variables!(
        container,
        PSI.ReactivePowerVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    add_variables!(container, PSI.EnergyVariable, devices, HydroDispatchReservoirStorage())
    add_variables!(
        container,
        WaterSpillageVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    add_variables!(
        container,
        EnergyShortageVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    add_variables!(
        container,
        EnergySurplusVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    add_variables!(container, EnergyOutput, devices, HydroDispatchReservoirStorage())
    add_parameters!(container, EnergyTargetTimeSeriesParameter, devices, model)
    add_parameters!(container, InflowTimeSeriesParameter, devices, model)

    add_expressions!(container, ProductionCostExpression, devices, model)

    add_to_expression!(
        container,
        ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ReactivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirStorage},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractPowerModel}
    devices = get_available_components(H, sys)

    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    add_constraints!(
        container,
        PSI.ReactivePowerVariableLimitsConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    add_initial_condition!(
        container,
        devices,
        HydroDispatchReservoirStorage(),
        InitialEnergyLevel(),
    )
    # Energy Balance Constraint
    add_constraints!(container, EnergyBalanceConstraint, devices, model, network_model)
    add_constraints!(container, EnergyTargetConstraint, devices, model, network_model)
    add_feedforward_constraints!(container, model, devices)

    objective_function!(container, devices, model, S)

    add_constraint_dual!(container, sys, model)
    return
end

"""
Construct model for HydroGen with ReservoirStorage Dispatch Formulation
with only Active Power
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirStorage},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = get_available_components(H, sys)

    add_variables!(container, PSI.ActivePowerVariable, devices, HydroDispatchReservoirStorage())
    add_variables!(container, PSI.EnergyVariable, devices, HydroDispatchReservoirStorage())
    add_variables!(
        container,
        WaterSpillageVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    add_variables!(
        container,
        EnergyShortageVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    add_variables!(
        container,
        EnergySurplusVariable,
        devices,
        HydroDispatchReservoirStorage(),
    )
    add_variables!(container, EnergyOutput, devices, HydroDispatchReservoirStorage())
    add_to_expression!(
        container,
        ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    add_parameters!(container, EnergyTargetTimeSeriesParameter, devices, model)
    add_parameters!(container, InflowTimeSeriesParameter, devices, model)

    add_expressions!(container, ProductionCostExpression, devices, model)

    add_to_expression!(
        container,
        ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    add_feedforward_arguments!(container, model, devices)

    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirStorage},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = get_available_components(H, sys)

    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    add_initial_condition!(
        container,
        devices,
        HydroDispatchReservoirStorage(),
        InitialEnergyLevel(),
    )
    # Energy Balance Constraint
    add_constraints!(container, EnergyBalanceConstraint, devices, model, network_model)
    add_constraints!(container, EnergyTargetConstraint, devices, model, network_model)
    add_feedforward_constraints!(container, model, devices)

    objective_function!(container, devices, model, S)
    add_constraint_dual!(container, sys, model)

    return
end

"""
Construct model for HydroGen with RunOfRiver Commitment Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroGen, D <: HydroCommitmentRunOfRiver, S <: PM.AbstractPowerModel}
    devices = get_available_components(H, sys)

    add_variables!(container, PSI.ActivePowerVariable, devices, D())
    add_variables!(container, PSI.ReactivePowerVariable, devices, D())
    add_variables!(container, OnVariable, devices, D())
    add_variables!(container, EnergyOutput, devices, D())
    add_to_expression!(
        container,
        ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    add_to_expression!(
        container,
        ReactivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    add_parameters!(container, ActivePowerTimeSeriesParameter, devices, model)

    add_expressions!(container, ProductionCostExpression, devices, model)

    add_to_expression!(
        container,
        ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroGen, D <: HydroCommitmentRunOfRiver, S <: PM.AbstractPowerModel}
    devices = get_available_components(H, sys)

    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    add_constraints!(
        container,
        PSI.ReactivePowerVariableLimitsConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    add_feedforward_constraints!(container, model, devices)

    objective_function!(container, devices, model, S)

    add_constraint_dual!(container, sys, model)
    return
end

"""
Construct model for HydroGen with RunOfRiver Commitment Formulation
with only Active Power.
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: HydroCommitmentRunOfRiver,
    S <: PM.AbstractActivePowerModel,
}
    devices = get_available_components(H, sys)

    add_variables!(container, PSI.ActivePowerVariable, devices, D())
    add_variables!(container, OnVariable, devices, D())
    add_variables!(container, EnergyOutput, devices, D())
    add_to_expression!(
        container,
        ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    add_expressions!(container, ProductionCostExpression, devices, model)

    add_parameters!(container, ActivePowerTimeSeriesParameter, devices, model)
    add_to_expression!(
        container,
        ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: HydroCommitmentRunOfRiver,
    S <: PM.AbstractActivePowerModel,
}
    devices = get_available_components(H, sys)

    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    add_feedforward_constraints!(container, model, devices)

    objective_function!(container, devices, model, S)

    add_constraint_dual!(container, sys, model)
    return
end

"""
Construct model for HydroGen with ReservoirBudget Commitment Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroGen, D <: HydroCommitmentReservoirBudget, S <: PM.AbstractPowerModel}
    devices = get_available_components(H, sys)

    add_variables!(container, PSI.ActivePowerVariable, devices, D())
    add_variables!(container, PSI.ReactivePowerVariable, devices, D())
    add_variables!(container, OnVariable, devices, D())
    add_variables!(container, EnergyOutput, devices, D())
    add_to_expression!(
        container,
        ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ActivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    add_parameters!(container, EnergyBudgetTimeSeriesParameter, devices, model)

    add_expressions!(container, ProductionCostExpression, devices, model)

    add_to_expression!(
        container,
        ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroGen, D <: HydroCommitmentReservoirBudget, S <: PM.AbstractPowerModel}
    devices = get_available_components(H, sys)

    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    add_constraints!(
        container,
        PSI.ReactivePowerVariableLimitsConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )
    # Energy Budget Constraint
    add_constraints!(container, EnergyBudgetConstraint, devices, model, network_model)

    add_feedforward_constraints!(container, model, devices)

    objective_function!(container, devices, model, S)
    add_constraint_dual!(container, sys, model)

    return
end

"""
Construct model for HydroGen with ReservoirBudget Commitment Formulation
with only Active Power.
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: HydroCommitmentReservoirBudget,
    S <: PM.AbstractActivePowerModel,
}
    devices = get_available_components(H, sys)

    add_variables!(container, PSI.ActivePowerVariable, devices, D())
    add_variables!(container, OnVariable, devices, D())
    add_variables!(container, EnergyOutput, devices, D())
    add_to_expression!(
        container,
        ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )

    add_parameters!(container, EnergyBudgetTimeSeriesParameter, devices, model)

    add_expressions!(container, ProductionCostExpression, devices, model)
    add_to_expression!(
        container,
        ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_feedforward_arguments!(container, model, devices)

    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: HydroCommitmentReservoirBudget,
    S <: PM.AbstractActivePowerModel,
}
    devices = get_available_components(H, sys)

    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    # Energy Budget Constraint
    add_constraints!(container, EnergyBudgetConstraint, devices, model, network_model)

    add_feedforward_constraints!(container, model, devices)

    objective_function!(container, devices, model, S)

    add_constraint_dual!(container, sys, model)
    return
end

"""
Construct model for HydroGen with ReservoirStorage Commitment Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroCommitmentReservoirStorage},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractPowerModel}
    devices = get_available_components(H, sys)

    add_variables!(
        container,
        PSI.ActivePowerVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    add_variables!(
        container,
        PSI.ReactivePowerVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    add_variables!(container, OnVariable, devices, HydroCommitmentReservoirStorage())
    add_variables!(container, PSI.EnergyVariable, devices, HydroCommitmentReservoirStorage())
    add_variables!(
        container,
        WaterSpillageVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    add_variables!(
        container,
        EnergyShortageVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    add_variables!(
        container,
        EnergySurplusVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    add_variables!(container, EnergyOutput, devices, HydroCommitmentReservoirStorage())
    add_to_expression!(
        container,
        ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ActivePowerBalance,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    add_parameters!(container, EnergyTargetTimeSeriesParameter, devices, model)
    add_parameters!(container, InflowTimeSeriesParameter, devices, model)

    add_expressions!(container, ProductionCostExpression, devices, model)

    add_to_expression!(
        container,
        ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, HydroCommitmentReservoirStorage},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractPowerModel}
    devices = get_available_components(H, sys)

    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    add_constraints!(
        container,
        PSI.ReactivePowerVariableLimitsConstraint,
        PSI.ReactivePowerVariable,
        devices,
        model,
        network_model,
    )

    add_initial_condition!(
        container,
        devices,
        HydroCommitmentReservoirStorage(),
        InitialEnergyLevel(),
    )
    # Energy Balance Constraint
    add_constraints!(container, EnergyBalanceConstraint, devices, model, network_model)
    add_constraints!(container, EnergyTargetConstraint, devices, model, network_model)
    add_feedforward_constraints!(container, model, devices)

    objective_function!(container, devices, model, S)
    add_constraint_dual!(container, sys, model)

    return
end

"""
Construct model for HydroGen with ReservoirStorage Dispatch Formulation
with only Active Power
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroCommitmentReservoirStorage},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = get_available_components(H, sys)

    add_variables!(
        container,
        PSI.ActivePowerVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    add_variables!(container, OnVariable, devices, HydroCommitmentReservoirStorage())
    add_variables!(container, PSI.EnergyVariable, devices, HydroCommitmentReservoirStorage())
    add_variables!(
        container,
        WaterSpillageVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    add_variables!(
        container,
        EnergyShortageVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    add_variables!(
        container,
        EnergySurplusVariable,
        devices,
        HydroCommitmentReservoirStorage(),
    )

    add_to_expression!(
        container,
        ActivePowerBalance,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_variables!(container, EnergyOutput, devices, HydroCommitmentReservoirStorage())
    add_parameters!(container, EnergyTargetTimeSeriesParameter, devices, model)
    add_parameters!(container, InflowTimeSeriesParameter, devices, model)

    add_expressions!(container, ProductionCostExpression, devices, model)

    add_to_expression!(
        container,
        ActivePowerRangeExpressionLB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ActivePowerRangeExpressionUB,
        PSI.ActivePowerVariable,
        devices,
        model,
        network_model,
    )
    add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, HydroCommitmentReservoirStorage},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = get_available_components(H, sys)

    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionLB,
        devices,
        model,
        network_model,
    )
    add_constraints!(
        container,
        PSI.ActivePowerVariableLimitsConstraint,
        ActivePowerRangeExpressionUB,
        devices,
        model,
        network_model,
    )

    add_initial_condition!(
        container,
        devices,
        HydroCommitmentReservoirStorage(),
        InitialEnergyLevel(),
    )

    # Energy Balance Constraint
    add_constraints!(container, EnergyBalanceConstraint, devices, model, network_model)
    add_constraints!(container, EnergyTargetConstraint, devices, model, network_model)
    add_feedforward_constraints!(container, model, devices)

    objective_function!(container, devices, model, S)
    add_constraint_dual!(container, sys, model)

    return
end

"""
Construct model for HydroPumpedStorage with PumpedStorage Dispatch Formulation
with only Active Power
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchPumpedStorage},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroPumpedStorage, S <: PM.AbstractActivePowerModel}
    devices = get_available_components(H, sys)

    add_variables!(container, PSI.ActivePowerInVariable, devices, HydroDispatchPumpedStorage())
    add_variables!(container, PSI.ActivePowerOutVariable, devices, HydroDispatchPumpedStorage())
    add_variables!(container, EnergyVariableUp, devices, HydroDispatchPumpedStorage())
    add_variables!(container, EnergyVariableDown, devices, HydroDispatchPumpedStorage())
    add_variables!(container, WaterSpillageVariable, devices, HydroDispatchPumpedStorage())
    add_variables!(container, EnergyOutput, devices, HydroDispatchPumpedStorage())
    if get_attribute(model, "reservation")
        add_variables!(
            container,
            ReservationVariable,
            devices,
            HydroDispatchPumpedStorage(),
        )
    end

    add_parameters!(container, InflowTimeSeriesParameter, devices, model)
    add_parameters!(container, OutflowTimeSeriesParameter, devices, model)

    add_expressions!(container, ProductionCostExpression, devices, model)

    add_to_expression!(
        container,
        ActivePowerBalance,
        PSI.ActivePowerInVariable,
        devices,
        model,
        network_model,
    )
    add_to_expression!(
        container,
        ActivePowerBalance,
        PSI.ActivePowerOutVariable,
        devices,
        model,
        network_model,
    )

    add_expressions!(container, ReserveRangeExpressionLB, devices, model)
    add_expressions!(container, ReserveRangeExpressionUB, devices, model)

    add_feedforward_arguments!(container, model, devices)
    return
end

function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ModelConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchPumpedStorage},
    network_model::NetworkModel{S},
) where {H <: PSY.HydroPumpedStorage, S <: PM.AbstractActivePowerModel}
    devices = get_available_components(H, sys)

    add_constraints!(
        container,
        OutputPSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerOutVariable,
        devices,
        model,
        network_model,
    )
    add_constraints!(
        container,
        InputPSI.ActivePowerVariableLimitsConstraint,
        PSI.ActivePowerInVariable,
        devices,
        model,
        network_model,
    )

    add_initial_condition!(
        container,
        devices,
        HydroDispatchPumpedStorage(),
        InitialEnergyLevelUp(),
    )
    add_initial_condition!(
        container,
        devices,
        HydroDispatchPumpedStorage(),
        InitialEnergyLevelDown(),
    )

    # Energy Balanace limits
    add_constraints!(container, EnergyCapacityUpConstraint, devices, model, network_model)
    add_constraints!(container, EnergyCapacityDownConstraint, devices, model, network_model)
    add_feedforward_constraints!(container, model, devices)

    objective_function!(container, devices, model, S)

    add_constraint_dual!(container, sys, model)
    return
end
