struct EnergyLimitConstraint <: PSI.ConstraintType end
"""
Struct to create the constraint that set-up the target for reservoir formulations.

For more information check [HydroPowerSimulations Formulations](@ref HydroPowerSimulations-Formulations).

The specified constraint is formulated as:

```math
e_t + e^\\text{shortage} + e^\\text{surplus} = \\text{EnergyTargetTimeSeriesParameter}_t, \\quad \\forall t \\in \\{1,\\dots, T\\}
```
"""
struct EnergyTargetConstraint <: PSI.ConstraintType end
struct EnergyShortageVariableLimitsConstraint <: PSI.ConstraintType end

"""
Struct to create the constraint that keeps track of the reservoir level of the lower (down) reservoir

For more information check [HydroPowerSimulations Formulations](@ref HydroPowerSimulations-Formulations).

The specified constraint is formulated as:

```math
e_{t}^\\text{dn} = e_{t-1}^\\text{dn} + \\left (p_t^\\text{hy,out} + s_t - \\frac{p_t^\\text{hy,in}}{\\eta^\\text{pump}} \\right) \\Delta T - \\text{OutflowTimeSeriesParameter}_t, \\quad \\forall t \\in \\{1,\\dots, T\\}
```
"""
struct EnergyCapacityDownConstraint <: PSI.ConstraintType end
"""
Struct to create the constraint that keeps track of the reservoir level of the upper (up) reservoir

For more information check [HydroPowerSimulations Formulations](@ref HydroPowerSimulations-Formulations).

The specified constraint is formulated as:

```math
e_{t}^\\text{up} = e_{t-1}^\\text{up} + \\left (p_t^\\text{hy,in} - \\frac{p_t^\\text{hy,out} + s_t}{\\eta^\\text{pump}} \\right) \\Delta T + \\text{InflowTimeSeriesParameter}_t, \\quad \\forall t \\in \\{1,\\dots, T\\}
```
"""
struct EnergyCapacityUpConstraint <: PSI.ConstraintType end
"""
Struct to create the constraint that limits the budget for reservoir formulations.

For more information check [HydroPowerSimulations Formulations](@ref HydroPowerSimulations-Formulations).

The specified constraint is formulated as:

```math
\\sum_{t=1}^T p^\\text{hy}_t \\le \\sum_{t=1}^T \\text{EnergyBudgetTimeSeriesParameter}_t,
```
"""
struct EnergyBudgetConstraint <: PSI.ConstraintType end
struct EnergyCapacityConstraint <: PSI.ConstraintType end

"""
Struct to create the constraint that limits the hydro usage for hydro formulations.

For more information check [HydroPowerSimulations Formulations](@ref HydroPowerSimulations-Formulations).

The specified constraint is formulated as:

```math
\\sum_{t=1}^T E^\\text{hy}_t \\le  \\text{HydroUsageLimitParameter}_T,
```
"""
struct FeedForwardHydroUsageLimitConstraint <: PSI.ConstraintType end

"""
Struct to model turbine outflow limits

For more information check [HydroPowerSimulations Formulations](@ref HydroPowerSimulations-Formulations).

The specified constraint is formulated as:

```math
\\ p_{t} = \\Delta t (f^{Tu}_{t-1}(0.5 K_1 (v_{t} + v_{t-1}) + K_2))
```
"""
struct HydroPowerConstraint <: PSI.ConstraintType end

"""
Struct to create the constraint for hydro reservoir storage

For more information check [HydroPowerSimulations Formulations](@ref HydroPowerSimulations-Formulations).

The specified constraint is formulated as:

```math
\\ v_{t} = v_{t-1} + \\Delta t (f^{UR}_{t-1} - f^{Sp}_{t-1} - f^{Tu}_{t-1})
```
"""
struct ReservoirInventoryConstraint <: PSI.ConstraintType end

"""
Struct to limit the turbine flow

```math
QW^{min} \\le \\sum_{j \\in J(i)}^T wq_{jt} \\le  QW^{max},
```
"""
struct TurbineFlowLimitConstraint <: PSI.ConstraintType end

"""
Struct to model turbine power output as a function of head

TODO
"""
struct TurbinePowerOutputConstraint <: PSI.ConstraintType end

"""
Struct to model reservoir stored volume/head limits

TODO
"""
struct ReservoirLevelLimitConstraint <: PSI.ConstraintType end

"""
Struct to model the final (target) volume/head storage constraint

TODO
"""
struct ReservoirLevelTargetConstraint <: PSI.ConstraintType end

"""
Struct to model the transformation from head to volume constraint

TODO
"""
struct ReservoirHeadToVolumeConstraint <: PSI.ConstraintType end
