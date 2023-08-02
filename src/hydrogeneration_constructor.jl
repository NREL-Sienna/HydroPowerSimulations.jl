#=
"""
Construct model for HydroGen with RunOfRiver Dispatch Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: PSI.AbstractHydroDispatchFormulation,
    S <: PM.AbstractPowerModel,
}
    devices = get_available_components(H, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.ReactivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.EnergyOutput, devices, D())
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
    D <: PSI.AbstractHydroDispatchFormulation,
    S <: PM.AbstractPowerModel,
}
    devices = get_available_components(H, sys)

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
    PSI._add_feedforward_constraints!(container, model, devices)

    PSI.objective_function!(container, devices, model, S)
    PSI.add_constraint_dual!(container, sys, model)

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
    network_model::PSI.NetworkModel{S},
) where {
    H <: PSY.HydroGen,
    D <: PSI.AbstractHydroDispatchFormulation,
    S <: PM.AbstractActivePowerModel,
}
    devices = get_available_components(H, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.EnergyOutput, devices, D())
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
    D <: PSI.AbstractHydroDispatchFormulation,
    S <: PM.AbstractActivePowerModel,
}
    devices = get_available_components(H, sys)

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
=#

"""
Construct model for HydroGen with ReservoirBudget Dispatch Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirBudget},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractPowerModel}
    devices = get_available_components(H, sys)

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
    PSI.add_variables!(container, PSI.EnergyOutput, devices, HydroDispatchReservoirBudget())
    PSI.add_parameters!(container, EnergyBudgetTimeSeriesParameter, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)

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
    devices = get_available_components(H, sys)

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
Construct model for HydroGen with ReservoirBudget Dispatch Formulation
with only Active Power.
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirBudget},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = get_available_components(H, sys)

    PSI.add_variables!(
        container,
        PSI.ActivePowerVariable,
        devices,
        HydroDispatchReservoirBudget(),
    )
    PSI.add_variables!(container, PSI.EnergyOutput, devices, HydroDispatchReservoirBudget())
    PSI.add_parameters!(container, EnergyBudgetTimeSeriesParameter, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)

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
    devices = get_available_components(H, sys)

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
Construct model for HydroGen with ReservoirStorage Dispatch Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirStorage},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractPowerModel}
    devices = get_available_components(H, sys)

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
        PSI.EnergyOutput,
        devices,
        HydroDispatchReservoirStorage(),
    )
    PSI.add_parameters!(container, EnergyTargetTimeSeriesParameter, devices, model)
    PSI.add_parameters!(container, InflowTimeSeriesParameter, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)

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
    devices = get_available_components(H, sys)

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
Construct model for HydroGen with ReservoirStorage Dispatch Formulation
with only Active Power
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchReservoirStorage},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = get_available_components(H, sys)

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
        PSI.EnergyOutput,
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
    devices = get_available_components(H, sys)

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
Construct model for HydroGen with ReservoirBudget Commitment Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, D},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroGen, D <: HydroCommitmentReservoirBudget, S <: PM.AbstractPowerModel}
    devices = get_available_components(H, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.ReactivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.OnVariable, devices, D())
    PSI.add_variables!(container, PSI.EnergyOutput, devices, D())
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
    devices = get_available_components(H, sys)

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
Construct model for HydroGen with ReservoirBudget Commitment Formulation
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
    devices = get_available_components(H, sys)

    PSI.add_variables!(container, PSI.ActivePowerVariable, devices, D())
    PSI.add_variables!(container, PSI.OnVariable, devices, D())
    PSI.add_variables!(container, PSI.EnergyOutput, devices, D())
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
    devices = get_available_components(H, sys)

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
Construct model for HydroGen with ReservoirStorage Commitment Formulation
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroCommitmentReservoirStorage},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractPowerModel}
    devices = get_available_components(H, sys)

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
        PSI.EnergyOutput,
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
    devices = get_available_components(H, sys)

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
Construct model for HydroGen with ReservoirStorage Dispatch Formulation
with only Active Power
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroCommitmentReservoirStorage},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroEnergyReservoir, S <: PM.AbstractActivePowerModel}
    devices = get_available_components(H, sys)

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
        PSI.EnergyOutput,
        devices,
        HydroCommitmentReservoirStorage(),
    )
    PSI.add_parameters!(container, EnergyTargetTimeSeriesParameter, devices, model)
    PSI.add_parameters!(container, InflowTimeSeriesParameter, devices, model)

    PSI.add_expressions!(container, PSI.ProductionCostExpression, devices, model)

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
    devices = get_available_components(H, sys)

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
Construct model for HydroPumpedStorage with PumpedStorage Dispatch Formulation
with only Active Power
"""
function PSI.construct_device!(
    container::PSI.OptimizationContainer,
    sys::PSY.System,
    ::PSI.ArgumentConstructStage,
    model::PSI.DeviceModel{H, HydroDispatchPumpedStorage},
    network_model::PSI.NetworkModel{S},
) where {H <: PSY.HydroPumpedStorage, S <: PM.AbstractActivePowerModel}
    devices = get_available_components(H, sys)

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
    PSI.add_variables!(container, HydroEnergyVariableUp, devices, HydroDispatchPumpedStorage())
    PSI.add_variables!(container, HydroEnergyVariableDown, devices, HydroDispatchPumpedStorage())
    PSI.add_variables!(
        container,
        WaterSpillageVariable,
        devices,
        HydroDispatchPumpedStorage(),
    )
    PSI.add_variables!(container, PSI.EnergyOutput, devices, HydroDispatchPumpedStorage())
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

    PSI.add_expressions!(container, PSI.ReserveRangeExpressionLB, devices, model)
    PSI.add_expressions!(container, PSI.ReserveRangeExpressionUB, devices, model)

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
    devices = get_available_components(H, sys)

    PSI.add_constraints!(
        container,
        PSI.OutputActivePowerVariableLimitsConstraint,
        PSI.ActivePowerOutVariable,
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
