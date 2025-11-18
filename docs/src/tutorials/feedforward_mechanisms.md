# [Feedforward Mechanisms for Multi-Stage Optimization](@id feedforward_tutorial)

This tutorial explains how to use feedforward mechanisms in `HydroPowerSimulations.jl` to implement multi-stage (hierarchical) optimization. Feedforwards allow you to pass decisions or constraints from one optimization stage to another.

!!! note

    Feedforwards are an advanced feature for coordinating multiple optimization models. Users should be familiar with [PowerSimulations.jl simulation concepts](https://nrel-sienna.github.io/PowerSimulations.jl/latest/tutorials/pcm_simulation/) before using this feature.

## What are Feedforwards?

In multi-stage hydro optimization, decisions made at one time scale (e.g., weekly planning) need to inform operations at another time scale (e.g., daily scheduling). Feedforwards provide this linkage by:

1. Reading values from a "source" model (the higher-level/coarser problem)
2. Applying constraints or targets in the "destination" model (the lower-level/finer problem)

## Available Feedforward Types

HydroPowerSimulations provides four specialized feedforward types:

| Feedforward | Purpose | Constraint Type |
|------------|---------|-----------------|
| [`ReservoirTargetFeedforward`](@ref) | Enforce minimum reservoir level at specific time | Target with slack and penalty |
| [`ReservoirLimitFeedforward`](@ref) | Limit sum of variable over periods | Upper bound on integral |
| [`HydroUsageLimitFeedforward`](@ref) | Limit total hydro energy usage | Upper bound on sum |
| [`WaterLevelBudgetFeedforward`](@ref) | Budget constraints on water levels | Upper bound on sum |

## ReservoirTargetFeedforward

Enforces a minimum reservoir level target at a specific time step, with a slack variable and penalty cost for violations.

### Mathematical Formulation

```math
v_{\text{target}} + s^{\text{shortage}} \ge \text{TargetParameter}_{\text{target}}
```

Where:
- ``v_{\text{target}}`` is the reservoir volume at the target period
- ``s^{\text{shortage}}`` is a slack variable for below-target levels
- The slack variable has an associated penalty cost in the objective

### Usage Example

```julia
using PowerSimulations
using HydroPowerSimulations

# Define the feedforward
ff_target = ReservoirTargetFeedforward(
    component_type = HydroReservoir,
    source = HydroReservoirVolumeVariable,  # Source of target values
    affected_values = [HydroReservoirVolumeVariable],  # Variables to constrain
    target_period = 24,  # Apply target at hour 24
    penalty_cost = 1000.0,  # Penalty for violations
)

# Add to device model
reservoir_model = DeviceModel(
    HydroReservoir,
    HydroWaterModelReservoir,
)
add_feedforward!(reservoir_model, ff_target)
```

### Use Cases

- **Weekly-to-daily coordination**: Weekly model sets end-of-week targets that daily model must achieve
- **Multi-horizon planning**: Long-term model sets intermediate checkpoints for medium-term model

## ReservoirLimitFeedforward

Limits the sum of a variable over specified periods to values from a source model.

### Mathematical Formulation

```math
\sum_{t \in \text{period}_i} v_t \le \sum_{t \in \text{period}_i} \text{LimitParameter}_t, \quad \forall i \in \{1, \dots, N_{\text{periods}}\}
```

The horizon is divided into ``N_{\text{periods}}`` intervals, and the sum over each interval is constrained.

### Usage Example

```julia
# Limit reservoir volume sum over 12-hour periods
ff_limit = ReservoirLimitFeedforward(
    component_type = HydroReservoir,
    source = HydroReservoirVolumeVariable,
    affected_values = [HydroReservoirVolumeVariable],
    number_of_periods = 12,  # Creates constraints for each 12-hour block
)

# For a 24-hour horizon, this creates 2 constraints:
# - Sum over hours 1-12 <= limit
# - Sum over hours 13-24 <= limit
```

### Use Cases

- **Periodic constraints**: Enforce limits on different parts of the day
- **Block scheduling**: Coordinate operations within time blocks

## HydroUsageLimitFeedforward

Limits the total energy production from hydro units based on higher-level decisions.

### Mathematical Formulation

```math
\sum_{t=1}^{T} p_t^{\text{hy}} \le \sum_{t=1}^{T} \text{UsageLimitParameter}_t
```

### Usage Example

```julia
ff_usage = HydroUsageLimitFeedforward(
    component_type = HydroTurbine,
    source = HydroEnergyOutput,  # Energy output from source model
    affected_values = [ActivePowerVariable],
    number_of_periods = 24,  # Full horizon
)
```

### Use Cases

- **Energy budget allocation**: Higher-level model allocates weekly energy budget, daily model respects it
- **Water value coordination**: Ensure short-term operations respect long-term water value decisions

## WaterLevelBudgetFeedforward

Enforces water level budget constraints across the optimization horizon.

### Usage Example

```julia
ff_budget = WaterLevelBudgetFeedforward(
    component_type = HydroReservoir,
    source = HydroReservoirVolumeVariable,
    affected_values = [HydroReservoirVolumeVariable],
    number_of_periods = 24,
)
```

## Implementing Multi-Stage Optimization

Here's a complete example of setting up a two-stage optimization with feedforwards:

### Stage 1: Weekly Planning Model

```julia
# Weekly planning template
weekly_template = ProblemTemplate(CopperPlatePowerModel)
set_device_model!(weekly_template, ThermalStandard, ThermalBasicDispatch)
set_device_model!(weekly_template, HydroTurbine, HydroTurbineBilinearDispatch)

weekly_reservoir_model = DeviceModel(HydroReservoir, HydroWaterModelReservoir)
set_device_model!(weekly_template, HydroReservoir, weekly_reservoir_model)

# Build weekly model
weekly_model = DecisionModel(
    weekly_template,
    sys_weekly;
    optimizer = optimizer,
    horizon = 168,  # One week hourly
)
```

### Stage 2: Daily Model with Feedforward

```julia
# Daily scheduling template
daily_template = ProblemTemplate(CopperPlatePowerModel)
set_device_model!(daily_template, ThermalStandard, ThermalBasicDispatch)
set_device_model!(daily_template, HydroTurbine, HydroTurbineBilinearDispatch)

# Reservoir model with feedforward
daily_reservoir_model = DeviceModel(HydroReservoir, HydroWaterModelReservoir)

# Add target feedforward from weekly model
ff = ReservoirTargetFeedforward(
    component_type = HydroReservoir,
    source = HydroReservoirVolumeVariable,
    affected_values = [HydroReservoirVolumeVariable],
    target_period = 24,  # End of day
    penalty_cost = 1000.0,
)
add_feedforward!(daily_reservoir_model, ff)

set_device_model!(daily_template, HydroReservoir, daily_reservoir_model)
```

### Running the Simulation

```julia
using PowerSimulations

# Create simulation sequence
models = SimulationModels(
    decision_models = [
        DecisionModel(
            weekly_template,
            sys;
            name = "weekly",
            optimizer = optimizer,
        ),
        DecisionModel(
            daily_template,
            sys;
            name = "daily",
            optimizer = optimizer,
        ),
    ],
)

# Define sequence with feedforward mapping
sequence = SimulationSequence(
    models = models,
    feedforwards = Dict(
        "daily" => [
            SemiContinuousFeedforward(
                source = :weekly,
                affected_values = [HydroReservoirVolumeVariable],
            ),
        ],
    ),
    ini_cond_chronology = InterProblemChronology(),
)

# Build and run simulation
sim = Simulation(
    name = "hydro_multistage",
    steps = 52,  # 52 weeks
    models = models,
    sequence = sequence,
    simulation_folder = mktempdir(),
)

build!(sim)
execute!(sim)
```

## Tips for Using Feedforwards

1. **Penalty costs**: Choose penalty costs carefully. Too low allows excessive violations; too high can cause numerical issues.

2. **Period alignment**: Ensure `number_of_periods` divides evenly into your horizon length.

3. **Source variables**: The source variable must exist in the higher-level model you're feeding from.

4. **Feasibility**: Feedforwards add constraints that might make problems infeasible. Monitor slack usage.

5. **Debugging**: If the model is infeasible, temporarily remove feedforwards to isolate the issue.

## See Also

- [`ReservoirTargetFeedforward`](@ref) - API documentation
- [`ReservoirLimitFeedforward`](@ref) - API documentation
- [`HydroUsageLimitFeedforward`](@ref) - API documentation
- [`WaterLevelBudgetFeedforward`](@ref) - API documentation
- [PowerSimulations Simulation](https://nrel-sienna.github.io/PowerSimulations.jl/latest/tutorials/pcm_simulation/) - Multi-stage simulation concepts
- [Medium-Term Hydro Planning](@ref medium_term_planning) - Decision model for planning
