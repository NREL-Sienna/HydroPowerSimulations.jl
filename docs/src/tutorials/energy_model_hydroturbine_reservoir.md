# HydroTurbine + Reservoir for EnergyModel

!!! note
    
    `HydroPowerSimulations.jl` is an extension library of [`PowerSimulations.jl`](https://nrel-sienna.github.io/PowerSimulations.jl/latest/) for modeling hydro units. Users are encouraged to review the [single-step tutorial in `PowerSimulations.jl`](https://nrel-sienna.github.io/PowerSimulations.jl/latest/tutorials/decision_problem/) before this tutorial.

## Load packages

```@repl op_problem
using PowerSystems
using PowerSimulations
using HydroPowerSimulations
using PowerSystemCaseBuilder
using HiGHS # solver
```

## Data

!!! note
    
    `PowerSystemCaseBuilder.jl` is a helper library that makes it easier to reproduce examples in the documentation and tutorials. Normally you would pass your local files to create the system data instead of calling the function `build_system`.
    For more details visit [PowerSystemCaseBuilder README](https://github.com/NREL-Sienna/PowerSystemCaseBuilder.jl/blob/main/README.md)

```@repl op_problem
sys = build_system(PSITestSystems, "c_sys5_hy")
```

With a single [`PowerSystems.HydroDispatch`](@extref):

```@repl op_problem
hy = only(get_components(HydroDispatch, sys))
```

## Decision Model

## Exploring Results

Results can be explored using:

```@repl op_problem
res = OptimizationProblemResults(model)
```

Use [`read_variable`](@ref InfrastructureSystems.Optimization.read_variable) to read in the dispatch variable results for the hydro:

```@repl op_problem
var = read_variable(res, "ActivePowerVariable__HydroDispatch")
```
