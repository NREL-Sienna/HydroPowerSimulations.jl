# [Hydro Unit Commitment](@id unit_commitment)

This tutorial demonstrates how to use unit commitment formulations in `HydroPowerSimulations.jl` for hydro generators that have significant startup/shutdown considerations. Unit commitment adds binary on/off decision variables that determine whether a generator is online at each time step.

!!! note

    `HydroPowerSimulations.jl` is an extension library of [`PowerSimulations.jl`](https://nrel-sienna.github.io/PowerSimulations.jl/latest/). Users are encouraged to review the [unit commitment tutorial in PowerSimulations.jl](https://nrel-sienna.github.io/PowerSimulations.jl/latest/tutorials/decision_problem/) before this tutorial.

## When to Use Unit Commitment

Unit commitment formulations are appropriate when:

- Hydro units have significant minimum generation levels when operating
- There are startup or shutdown costs to consider
- The unit cannot operate below a certain power threshold
- You need to model on/off decisions explicitly

## Available Unit Commitment Formulations

HydroPowerSimulations provides two unit commitment formulations:

1. **[`HydroCommitmentRunOfRiver`](@ref)** - For `HydroGen` and `HydroDispatch` devices (run-of-river without storage)
2. **[`HydroTurbineEnergyCommitment`](@ref)** - For `HydroTurbine` devices (connected to reservoirs)

## Load Packages

```@repl unit_commitment
using PowerSystems
using PowerSimulations
using HydroPowerSimulations
using PowerSystemCaseBuilder
using HiGHS # solver
```

## Data

```@repl unit_commitment
sys = build_system(PSITestSystems, "c_sys5_hy")
```

Let's examine the hydro dispatch unit:

```@repl unit_commitment
hy = only(get_components(HydroDispatch, sys))
get_active_power_limits(hy)
```

## Example 1: HydroCommitmentRunOfRiver

This formulation adds binary commitment variables to run-of-river hydro units.

### Setting Up the Template

```@repl unit_commitment
template_uc = ProblemTemplate(CopperPlatePowerModel)
set_device_model!(template_uc, ThermalStandard, ThermalBasicDispatch)
set_device_model!(template_uc, PowerLoad, StaticPowerLoad)
```

Now we use the unit commitment formulation instead of simple dispatch:

```@repl unit_commitment
set_device_model!(template_uc, HydroDispatch, HydroCommitmentRunOfRiver)
```

### Build and Solve

```@repl unit_commitment
model_uc = DecisionModel(template_uc, sys; optimizer = HiGHS.Optimizer)
build!(model_uc; output_dir = mktempdir())
solve!(model_uc)
```

### Exploring Results

```@repl unit_commitment
res_uc = OptimizationProblemResults(model_uc)
```

Read the commitment (on/off) variable:

```@repl unit_commitment
on_var = read_variable(res_uc, "OnVariable__HydroDispatch")
```

Read the power output:

```@repl unit_commitment
power_var = read_variable(res_uc, "ActivePowerVariable__HydroDispatch")
```

## Mathematical Formulation

The unit commitment formulation adds the following constraints that couple the power output to the commitment status:

```math
\begin{align*}
&  u_t P^{\text{min}} \le p_t \le u_t P^{\text{max}}, \quad \forall t \\
&  u_t Q^{\text{min}} \le q_t \le u_t Q^{\text{max}}, \quad \forall t
\end{align*}
```

Where:
- ``u_t \in \{0, 1\}`` is the binary commitment variable
- ``p_t`` is the active power output
- ``P^{\text{min}}, P^{\text{max}}`` are the power limits

When ``u_t = 0`` (unit is off), the power output is forced to zero. When ``u_t = 1`` (unit is on), the power must be between the minimum and maximum limits.

## Comparison: Dispatch vs Unit Commitment

| Aspect | Dispatch | Unit Commitment |
|--------|----------|-----------------|
| Variables | Continuous power | Continuous power + Binary on/off |
| Minimum power | Can be zero | Must be at ``P^{\text{min}}`` when on |
| Computational complexity | LP | MIP |
| Use case | Flexible units | Units with min generation constraints |

## Tips for Unit Commitment Problems

1. **Solver selection**: Unit commitment creates mixed-integer programs (MIP). Use solvers like HiGHS, Gurobi, or CPLEX that support integer variables.

2. **Minimum generation**: Set appropriate `active_power_limits.min` values in your device data. This becomes the minimum output when the unit is online.

3. **Fixed costs**: Define fixed costs in the operation cost structure to penalize having units online. These costs apply when ``u_t = 1``.

4. **Computational time**: MIP problems can take longer to solve. Consider using dispatch formulations for initial analysis and switching to unit commitment for detailed studies.

## See Also

- [`HydroCommitmentRunOfRiver`](@ref) - Full formulation documentation
- [`HydroTurbineEnergyCommitment`](@ref) - For turbines connected to reservoirs
- [PowerSimulations Unit Commitment](https://nrel-sienna.github.io/PowerSimulations.jl/latest/tutorials/decision_problem/) - General unit commitment concepts
