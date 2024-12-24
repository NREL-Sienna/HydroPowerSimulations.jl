# [Operation Problem with `HydroPowerSimulations.jl`](@id op_problem)

**Originally Contributed by:** Rodrigo Henriquez-Auba

Load packages:

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
    For more details visit [PowerSystemCaseBuilder Documentation](https://nrel-sienna.github.io/PowerSystems.jl/stable/tutorials/powersystembuilder/)

```@repl op_problem
sys = build_system(PSITestSystems, "c_sys5_hy")
```

With a single `HydroDispatch`:

```@repl op_problem
hy = only(get_components(HydroDispatch, sys))
```

## Decision Model

Setting up the formulations, including hydro using `HydroDispatchRunOfRiver`

```@repl op_problem
template = ProblemTemplate(PTDFPowerModel)
set_device_model!(template, ThermalStandard, ThermalBasicDispatch)
set_device_model!(template, PowerLoad, StaticPowerLoad)
set_device_model!(template, Line, StaticBranch)
set_device_model!(template, HydroDispatch, HydroDispatchRunOfRiver)
```

```@repl op_problem
model = DecisionModel(template, sys; optimizer=HiGHS.Optimizer)
build!(model, output_dir=mktempdir())
solve!(model)
```

## Exploring Results

Results can be explored using:

```@repl op_problem
res = OptimizationProblemResults(model)
```

with dispatch variable for the hydro:

```@repl op_problem
var = read_variable(res, "ActivePowerVariable__HydroDispatch")
```
