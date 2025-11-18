# [Medium-Term Hydro Planning](@id medium_term_planning)

This tutorial demonstrates how to use the `MediumTermHydroPlanning` decision model for coordinating hydro reservoir operations with thermal and renewable generation over medium-term horizons (weeks to months).

!!! note

    The `MediumTermHydroPlanning` model is designed for system-wide energy planning with simplified network representation. It optimizes reservoir levels, turbine operations, and thermal dispatch to minimize total system costs.

## When to Use MediumTermHydroPlanning

This decision model is appropriate when:

- Planning hydro operations over weeks or months
- Coordinating multiple reservoirs with thermal and renewable generation
- Using simplified (copper plate) network representation
- Focusing on energy balance rather than detailed power flow

## Key Features

- **Integrated optimization**: Jointly optimizes hydro reservoirs, turbines, thermals, and renewables
- **Water balance tracking**: Tracks reservoir volumes with inflow/outflow time series
- **Level targets**: Enforces reservoir level targets at end of horizon
- **Energy balance**: Uses copper plate network model for energy balance
- **Slack variables**: Includes system balance slack for feasibility

## Load Packages

```@repl medium_term
using PowerSystems
using PowerSimulations
using HydroPowerSimulations
using Dates
using HiGHS
```

## System Setup

For medium-term planning, you need a system with:
- `HydroTurbine` devices connected to `HydroReservoir` devices
- `ThermalStandard` generators
- `RenewableDispatch` generators (optional)
- `PowerLoad` demands
- Time series for loads, renewables, and reservoir inflows

```@repl medium_term
# Create a simple test system
sys = System(100.0)  # 100 MVA base

# Add a bus
bus = ACBus(
    number = 1,
    name = "Bus1",
    bustype = ACBusTypes.REF,
    angle = 0.0,
    magnitude = 1.0,
    voltage_limits = (min = 0.9, max = 1.1),
    base_voltage = 230.0,
)
add_component!(sys, bus)

# Add thermal generator
thermal = ThermalStandard(
    name = "Thermal1",
    available = true,
    status = true,
    bus = bus,
    active_power = 0.5,
    reactive_power = 0.0,
    rating = 1.0,
    active_power_limits = (min = 0.1, max = 1.0),
    reactive_power_limits = (min = -0.5, max = 0.5),
    ramp_limits = nothing,
    operation_cost = ThermalGenerationCost(
        variable = CostCurve(LinearCurve(50.0)),
        fixed = 0.0,
        start_up = 0.0,
        shut_down = 0.0,
    ),
    base_power = 100.0,
    time_limits = nothing,
    prime_mover_type = PrimeMovers.ST,
    fuel = ThermalFuels.COAL,
)
add_component!(sys, thermal)
```

## Template Setup

The `MediumTermHydroPlanning` model requires specific device models in the template:

```@repl medium_term
template = ProblemTemplate(CopperPlatePowerModel)

# Thermal generators
set_device_model!(template, ThermalStandard, ThermalBasicDispatch)

# Renewable generators (if present)
set_device_model!(template, RenewableDispatch, RenewableFullDispatch)

# Loads
set_device_model!(template, PowerLoad, StaticPowerLoad)

# Hydro turbines with water-based formulation
set_device_model!(template, HydroTurbine, HydroTurbineBilinearDispatch)

# Hydro reservoirs with water model
set_device_model!(template, HydroReservoir, HydroWaterModelReservoir)
```

## Building the Model

Create the decision model using the `MediumTermHydroPlanning` problem type:

```julia
model = DecisionModel(
    MediumTermHydroPlanning,
    template,
    sys;
    optimizer = HiGHS.Optimizer,
    horizon = 168,  # One week hourly
    resolution = Hour(1),
)

build!(model; output_dir = mktempdir())
```

## Model Components

The `MediumTermHydroPlanning` model automatically creates:

### Variables

- **Thermal power**: `ActivePowerVariable` for each `ThermalStandard`
- **Renewable power**: `ActivePowerVariable` for each `RenewableDispatch`
- **Turbine power**: `ActivePowerVariable` for each `HydroTurbine`
- **Reservoir head**: `HydroReservoirHeadVariable` for each `HydroReservoir`
- **Reservoir volume**: `HydroReservoirVolumeVariable` for each `HydroReservoir`
- **Spillage**: `WaterSpillageVariable` for each `HydroReservoir`
- **Turbine flow**: `HydroTurbineFlowRateVariable` for turbine-reservoir pairs
- **Balance slacks**: System balance slack variables for feasibility

### Parameters

- **Load time series**: `ActivePowerTimeSeriesParameter` for demands
- **Renewable time series**: `ActivePowerTimeSeriesParameter` for renewables
- **Inflow time series**: `InflowTimeSeriesParameter` for reservoirs
- **Outflow time series**: `OutflowTimeSeriesParameter` (optional)

### Constraints

- **Energy balance**: System-wide energy balance at each time step
- **Power limits**: Active power bounds for all generators
- **Reservoir inventory**: Water balance tracking for reservoirs
- **Level limits**: Reservoir volume/head bounds
- **Level targets**: End-of-horizon reservoir level requirements
- **Head-to-volume**: Relationship between head and volume
- **Turbine power**: Power output as function of flow and head

### Objective Function

The objective minimizes:
1. **Thermal costs**: Variable generation costs
2. **Slack penalties**: High penalty for unserved energy
3. **Spillage penalties**: Penalty for wasted water

## Solving and Results

```julia
solve!(model)

# Get results
res = OptimizationProblemResults(model)

# Read thermal generation
thermal_gen = read_variable(res, "ActivePowerVariable__ThermalStandard")

# Read turbine power
turbine_power = read_variable(res, "ActivePowerVariable__HydroTurbine")

# Read reservoir volumes
reservoir_vol = read_variable(res, "HydroReservoirVolumeVariable__HydroReservoir")

# Read spillage
spillage = read_variable(res, "WaterSpillageVariable__HydroReservoir")
```

## Integration with Feedforwards

The `MediumTermHydroPlanning` model supports feedforwards for multi-stage optimization:

```julia
# Example: Pass reservoir targets to lower-level models
ff = ReservoirTargetFeedforward(
    component_type = HydroReservoir,
    source = HydroReservoirVolumeVariable,
    affected_values = [HydroReservoirVolumeVariable],
    target_period = 168,  # End of horizon
    penalty_cost = 1000.0,
)
```

This enables hierarchical optimization where medium-term plans inform short-term operations.

## Tips for Medium-Term Planning

1. **Time resolution**: Use hourly or multi-hour resolution for computational efficiency over long horizons.

2. **Inflow forecasts**: Provide realistic inflow time series that capture seasonal patterns.

3. **Level targets**: Set appropriate end-of-horizon reservoir targets to maintain long-term water management.

4. **Thermal costs**: Ensure thermal generators have realistic variable costs to drive hydro optimization.

5. **Slack penalties**: The model uses high slack penalties. Persistent slack usage indicates infeasibility in the original problem.

## See Also

- [`HydroWaterModelReservoir`](@ref) - Water-based reservoir formulation
- [`HydroTurbineBilinearDispatch`](@ref) - Turbine formulation with head variation
- [Feedforward Mechanisms](@ref feedforward_tutorial) - Multi-stage optimization
- [PowerSimulations Decision Models](https://nrel-sienna.github.io/PowerSimulations.jl/latest/tutorials/decision_problem/) - General decision model concepts
