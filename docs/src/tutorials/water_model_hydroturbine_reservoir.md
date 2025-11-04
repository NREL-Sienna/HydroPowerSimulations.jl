# HydroTurbine + Reservoir for WaterModel

!!! note
    
    `HydroPowerSimulations.jl` is an extension library of [`PowerSimulations.jl`](https://nrel-sienna.github.io/PowerSimulations.jl/latest/) for modeling hydro units. Users are encouraged to review the [single-step tutorial in `PowerSimulations.jl`](https://nrel-sienna.github.io/PowerSimulations.jl/latest/tutorials/decision_problem/) before this tutorial.

## Load packages

```@repl op_problem
using PowerSystems
using PowerSimulations
using HydroPowerSimulations
using PowerSystemCaseBuilder

using JuMP
using HiGHS # solver


const PSY = PowerSystems
const PSB = PowerSystemCaseBuilder
```

## Data

!!! note
    
    `PowerSystemCaseBuilder.jl` is a helper library that makes it easier to reproduce examples in the documentation and tutorials. Normally you would pass your local files to create the system data instead of calling the function `build_system`.
    For more details visit [PowerSystemCaseBuilder README](https://github.com/NREL-Sienna/PowerSystemCaseBuilder.jl/blob/main/README.md)

```@repl op_problem
sys = PSB.build_system(PSITestSystems, "c_sys5_hy")
```

With a single [`PowerSystems.HydroDispatch`](@extref):

```@repl op_problem

HiGHS_optimizer = JuMP.optimizer_with_attributes(
    HiGHS.Optimizer,
    "time_limit" => 300.0,
    "log_to_console" => false,
    "mip_abs_gap" => 1e-1,
    "mip_rel_gap" => 1e-1,
)

hydro_budget = 24

hy = only(get_components(HydroDispatch, sys))
max_power = get_max_active_power(hy)
resolution = Dates.Hour(1)
tstamp = range(DateTime("2024-01-01T00:00:00"); step = resolution, length = 48)
data = ones(length(tstamp)) / (get_base_power(sys) * max_power)
ts = SingleTimeSeries("hydro_budget", TimeArray(tstamp, data))
add_time_series!(sys, hy, ts)
remove_time_series!(sys, Deterministic)
transform_single_time_series!(sys, Hour(24), Hour(24))
```

## Decision Model

```@repl op_problem
template_uc = ProblemTemplate()
set_device_model!(template_uc, ThermalStandard, ThermalBasicUnitCommitment)
set_device_model!(template_uc, RenewableDispatch, RenewableFullDispatch)
set_device_model!(template_uc, PowerLoad, StaticPowerLoad)
set_device_model!(template_uc, RenewableNonDispatch, FixedOutput)

set_device_model!(
    template_uc,
    DeviceModel(HydroDispatch, HydroDispatchRunOfRiverBudget;
        attributes = Dict("hydro_budget_interval" => Hour(hydro_budget))),
)
model = DecisionModel(
    template_uc,
    c_sys5_hy;
    optimizer = HiGHS_optimizer,
    store_variable_names = true,
)

output_dir = mktempdir(; cleanup = true)
build!(model; output_dir = output_dir) 
solve!(model; output_dir = output_dir)


```

## Exploring Results

Results can be explored using:

```@repl op_problem
res = OptimizationProblemResults(model)
```

Use [`read_variable`](@ref InfrastructureSystems.Optimization.read_variable) to read in the dispatch variable results for the hydro:

```@repl op_problem
var = read_variable(res, "ActivePowerVariable__HydroDispatch")
```

## EnergyBlock Model


``` @repl op_problem

Ipopt_optimizer = JuMP.optimizer_with_attributes(
    Ipopt.Optimizer,
    "max_cpu_time" => 300.0,
    "print_level" => 0,
)

sys = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")
res = first(PSY.get_components(HydroReservoir, sys))

set_head_to_volume_factor!(res, LinearCurve(1.0))
template_ed = ProblemTemplate(
    NetworkModel(
        CopperPlatePowerModel;
    ),
)
set_device_model!(template_ed, PowerLoad, StaticPowerLoad)
set_device_model!(template_ed, ThermalStandard, ThermalDispatchNoMin)
set_device_model!(template_ed, HydroReservoir, HydroEnergyBlockOptimization)
set_device_model!(template_ed, HydroTurbine, HydroEnergyBlockOptimization)

model = DecisionModel(
    template_ed,
    sys;
    name = "ED",
    optimizer = Ipopt_optimizer,
    optimizer_solve_log_print = true,
    store_variable_names = true,
    system_to_file = true,
    horizon = Hour(24),
)

build!(model; output_dir = output_dir)
solve!(model; optimizer = Ipopt_optimizer, output_dir = output_dir)


```