# [Multi-Reservoir Cascade Operations](@id cascade_tutorial)

This tutorial demonstrates how to model cascading reservoir systems where multiple reservoirs are connected in series, with upstream reservoirs feeding downstream ones through turbines and spillways.

!!! note

    Cascading reservoir systems require careful attention to the physical connectivity between reservoirs and turbines. This tutorial shows how to set up these connections using PowerSystems data structures.

## Understanding Cascade Systems

In a cascade system:

1. **Upstream reservoirs** release water through turbines or spillways
2. **Water flows** to downstream reservoirs
3. **Each turbine** connects an upstream reservoir to a downstream location
4. **Spillage** from upstream reservoirs also flows downstream

The package automatically tracks water flows between connected components using expressions like `TotalHydroFlowRateReservoirIncoming` and `TotalHydroFlowRateReservoirOutgoing`.

## System Topology

A typical cascade might look like:

```
[Reservoir A] → [Turbine 1] → [Reservoir B] → [Turbine 2] → [River/Ocean]
     ↓                             ↓
 (spillage)                    (spillage)
     ↓                             ↓
[Reservoir B] ←←←←←←←←←←←←←←←←←←←←←
```

## Load Packages

```@repl cascade
using PowerSystems
using PowerSimulations
using HydroPowerSimulations
using Dates
using Ipopt # Required for nonlinear formulations
```

## Setting Up a Cascade System

### Step 1: Create the System

```@repl cascade
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
```

### Step 2: Create the Upper Reservoir

```@repl cascade
upper_reservoir = HydroReservoir(
    name = "UpperReservoir",
    available = true,
    bus = bus,
    active_power = 0.0,
    reactive_power = 0.0,
    rating = 1.0,
    base_power = 100.0,
    prime_mover_type = PrimeMovers.HY,
    storage_level_limits = (min = 1000.0, max = 10000.0),  # m³
    spillage_limits = (min = 0.0, max = 100.0),  # m³/s
    initial_level = 8000.0,  # m³
    level_data_type = ReservoirDataType.HEAD,
    head_to_volume_factor = 1000.0,  # m³/m
    intake_elevation = 500.0,  # meters
    level_targets = 0.8,  # Target 80% of max at end
)
add_component!(sys, upper_reservoir)
```

### Step 3: Create the Lower Reservoir

```@repl cascade
lower_reservoir = HydroReservoir(
    name = "LowerReservoir",
    available = true,
    bus = bus,
    active_power = 0.0,
    reactive_power = 0.0,
    rating = 1.0,
    base_power = 100.0,
    prime_mover_type = PrimeMovers.HY,
    storage_level_limits = (min = 500.0, max = 5000.0),  # m³
    spillage_limits = (min = 0.0, max = 50.0),  # m³/s
    initial_level = 3000.0,  # m³
    level_data_type = ReservoirDataType.HEAD,
    head_to_volume_factor = 500.0,  # m³/m
    intake_elevation = 200.0,  # meters
    level_targets = 0.7,  # Target 70% of max at end
)
add_component!(sys, lower_reservoir)
```

### Step 4: Create the Turbine Connecting Reservoirs

The turbine connects the upper reservoir to the lower reservoir:

```@repl cascade
turbine = HydroTurbine(
    name = "Turbine1",
    available = true,
    bus = bus,
    active_power = 0.5,
    reactive_power = 0.0,
    rating = 1.0,
    base_power = 100.0,
    prime_mover_type = PrimeMovers.HY,
    active_power_limits = (min = 0.0, max = 1.0),
    reactive_power_limits = (min = -0.3, max = 0.3),
    powerhouse_elevation = 210.0,  # meters (below upper reservoir intake)
    outflow_limits = (min = 0.0, max = 50.0),  # m³/s
    efficiency = 0.85,
    operation_cost = HydroGenerationCost(nothing),
)
add_component!(sys, turbine)
```

### Step 5: Connect Components

Use `Arc` components to define the flow connectivity:

```@repl cascade
# Connect upper reservoir to turbine (upstream connection)
arc_up = Arc(
    name = "UpperRes_to_Turbine",
    source = upper_reservoir,
    sink = turbine,
)
add_component!(sys, arc_up)

# Connect turbine to lower reservoir (downstream connection)
arc_down = Arc(
    name = "Turbine_to_LowerRes",
    source = turbine,
    sink = lower_reservoir,
)
add_component!(sys, arc_down)
```

### Step 6: Add Time Series

Add inflow time series to the upper reservoir:

```@repl cascade
resolution = Hour(1)
dates = range(DateTime("2020-01-01"); length = 24, step = resolution)
inflow_data = [10.0 + 5.0 * sin(2π * i / 24) for i in 1:24]  # m³/s

inflow_ts = SingleTimeSeries(
    name = "inflow",
    data = TimeArray(dates, inflow_data),
    scaling_factor_multiplier = nothing,
)
add_time_series!(sys, upper_reservoir, inflow_ts)
```

## Template Setup for Cascade

Use water-based formulations that track physical flows:

```@repl cascade
template = ProblemTemplate(CopperPlatePowerModel)

# Use bilinear dispatch for turbines (accounts for head variation)
set_device_model!(template, HydroTurbine, HydroTurbineBilinearDispatch)

# Use water model for reservoirs (tracks m³)
set_device_model!(template, HydroReservoir, HydroWaterModelReservoir)

# Add other necessary models
set_device_model!(template, PowerLoad, StaticPowerLoad)
```

## Water Balance in Cascades

For each reservoir, HydroPowerSimulations automatically creates water balance constraints:

### Upper Reservoir Balance

```math
v_t^{\text{upper}} = v_{t-1}^{\text{upper}} + 3600 \cdot \Delta T \cdot (\text{inflow}_t - f_t^{\text{turbine}} - s_t^{\text{upper}})
```

### Lower Reservoir Balance

```math
v_t^{\text{lower}} = v_{t-1}^{\text{lower}} + 3600 \cdot \Delta T \cdot (f_t^{\text{turbine}} + s_t^{\text{upper}} + \text{inflow}_t^{\text{lower}} - f_t^{\text{out}} - s_t^{\text{lower}})
```

Where:
- ``v_t`` is reservoir volume at time ``t``
- ``f_t^{\text{turbine}}`` is turbine flow rate
- ``s_t`` is spillage
- The factor 3600 converts hours to seconds

## Building and Solving

```julia
model = DecisionModel(
    template,
    sys;
    optimizer = Ipopt.Optimizer,  # Nonlinear solver for bilinear terms
)

build!(model; output_dir = mktempdir())
solve!(model)
```

## Analyzing Cascade Results

```julia
res = OptimizationProblemResults(model)

# Read reservoir volumes
upper_vol = read_variable(res, "HydroReservoirVolumeVariable__HydroReservoir")
lower_vol = read_variable(res, "HydroReservoirVolumeVariable__HydroReservoir")

# Read turbine flows
turbine_flow = read_variable(res, "HydroTurbineFlowRateVariable__HydroTurbine")

# Read spillage
spillage = read_variable(res, "WaterSpillageVariable__HydroReservoir")

# Read power output
power = read_variable(res, "ActivePowerVariable__HydroTurbine")
```

## Key Expressions for Cascades

The following expressions track flows between components:

| Expression | Description |
|-----------|-------------|
| `TotalHydroFlowRateReservoirIncoming` | Total turbine inflow to reservoir |
| `TotalHydroFlowRateReservoirOutgoing` | Total turbine outflow from reservoir |
| `TotalSpillageFlowRateReservoirIncoming` | Spillage inflow from upstream reservoirs |
| `TotalHydroFlowRateTurbineOutgoing` | Total flow through turbine |

## Multi-Turbine Cascades

For systems with multiple turbines feeding into a single reservoir:

```julia
# Turbine 1: Upper reservoir A → Lower reservoir
turbine1 = HydroTurbine(name = "Turbine1", ...)

# Turbine 2: Upper reservoir B → Lower reservoir
turbine2 = HydroTurbine(name = "Turbine2", ...)

# Both connect to the same lower reservoir
arc1 = Arc(name = "T1_to_Lower", source = turbine1, sink = lower_reservoir)
arc2 = Arc(name = "T2_to_Lower", source = turbine2, sink = lower_reservoir)
```

The water balance for the lower reservoir will include flows from both turbines.

## Tips for Cascade Modeling

1. **Elevation consistency**: Ensure intake elevations decrease downstream. Upper reservoirs should be at higher elevations than lower ones.

2. **Head-to-volume factors**: These should be physically realistic for each reservoir's geometry.

3. **Spillage limits**: Set appropriate spillage limits to avoid unrealistic water discharge.

4. **Solver selection**: Use nonlinear solvers (Ipopt) for `HydroTurbineBilinearDispatch` or `HydroWaterModelReservoir` due to bilinear terms.

5. **Initial conditions**: Ensure initial reservoir levels sum to realistic total water in the system.

6. **Time series alignment**: Inflow time series for all reservoirs must have the same resolution and timestamps.

## Common Issues

### Infeasibility
- Check that there's enough water in the system to satisfy demand
- Verify spillage limits aren't too restrictive
- Ensure level targets are achievable given inflows

### Numerical Issues
- Nonlinear solvers may need tolerance adjustments
- Scale variables if volumes are very large (millions of m³)

## See Also

- [`HydroTurbineBilinearDispatch`](@ref) - Turbine formulation with head variation
- [`HydroWaterModelReservoir`](@ref) - Water-based reservoir model
- [Water Hydro Reservoir Operation](@ref water_hydro_reservoir) - Basic water model tutorial
- [Format Input Data](@ref format_data) - Data requirements for hydro models
