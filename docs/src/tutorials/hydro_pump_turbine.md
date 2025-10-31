# HydroPumpTurbine

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
sys = PSB.build_system(PSITestSystems, "c_sys5_hydro_pump_energy"; add_reserves = true)
```

With one or more [`PowerSystems.HydroPumpTurbine`](@extref):

```@repl op_problem
hy_pump = first(PSY.get_components(HydroPumpTurbine, sys))
```

Add time series 
```
DayAhead = collect(
    DateTime("1/1/2024  0:00:00", "d/m/y  H:M:S"):Hour(1):DateTime(
        "1/1/2024  23:00:00",
        "d/m/y  H:M:S",
    ),
)

hydro_max_power = 0.8 * ones(48)
hydro_max_cap = 0.9 * ones(48)
tstamps = vcat(DayAhead, DayAhead .+ Day(1))
tarray_power = TimeArray(tstamps, hydro_max_power)
tarray_cap = TimeArray(tstamps, hydro_max_cap)

PSY.add_time_series!(
    sys,
    hy_pump,
    PSY.SingleTimeSeries("max_active_power", tarray_power),
)
PSY.add_time_series!(
    sys,
    hy_pump,
    PSY.SingleTimeSeries("capacity", tarray_cap),
)
remove_time_series!(sys, Deterministic)
transform_single_time_series!(sys, Hour(24), Hour(24))
```

## Decision Model
```
template = ProblemTemplate(CopperPlatePowerModel)
model = DecisionModel(CopperPlatePowerModel, sys)
```

## Exploring Results

Results can be explored using:

```@repl op_problem
res = OptimizationProblemResults(model)
```
