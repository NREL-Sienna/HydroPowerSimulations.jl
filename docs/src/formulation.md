# `HydroPowerSimulations` Formulations

Hydro generation formulations define the optimization models that describe hydro units mathematical model in different operational settings, such as economic dispatch and unit commitment.

!!! note
    
    The use of reactive power variables and constraints will depend on the network model used, i.e., whether it uses (or does not use) reactive power. If the network model is purely active power-based,  reactive power variables and related constraints are not created.

!!! note
    
    Reserve variables for services are not included in the formulation, albeit their inclusion change the variables, expressions, constraints and objective functions created. A detailed description of the implications in the optimization models is described in the [Service formulation](https://nrel-sienna.github.io/PowerSimulations.jl/latest/formulation_library/Service/) in the [PowerSimulations documentation](https://nrel-sienna.github.io/PowerSimulations.jl/latest/).

### Table of Contents

 1. [`HydroDispatchRunOfRiver`](#HydroDispatchRunOfRiver)
 2. [`HydroDispatchReservoirBudget`](#HydroDispatchReservoirBudget)
 3. [`HydroDispatchReservoirStorage`](#HydroDispatchReservoirStorage)
 4. [`HydroDispatchPumpedStorage`](#HydroDispatchPumpedStorage)
 5. [`HydroCommitmentRunOfRiver`](#HydroCommitmentRunOfRiver)
 6. [`HydroCommitmentReservoirBudget`](#HydroCommitmentReservoirBudget)
 7. [`HydroCommitmentReservoirStorage`](#HydroCommitmentReservoirStorage)

## `HydroDispatchRunOfRiver`

```@docs
HydroDispatchRunOfRiver
```

**Variables:**

  - `ActivePowerVariable`:
    
      + Bounds: [0.0, ]
      + Symbol: ``p^\text{hy}``

  - `ReactivePowerVariable`:
    
      + Bounds: [0.0, ]
      + Symbol: ``q^\text{hy}``

**Auxiliary Variables:**

  - [`HydroEnergyOutput`](@ref):
    
      + Symbol: ``E^\text{hy,out}``

The `HydroEnergyOutput` is computed as the energy used at each time step from the hydro, computed simply as ``E^\text{hy,out} \cdot \Delta T``, where ``\Delta T`` is the duration (in hours) of each time step.

**Static Parameters:**

  - ``P^\text{hy,min}`` = `PowerSystems.get_active_power_limits(device).min`
  - ``P^\text{hy,max}`` = `PowerSystems.get_active_power_limits(device).max`
  - ``Q^\text{hy,min}`` = `PowerSystems.get_reactive_power_limits(device).min`
  - ``Q^\text{hy,max}`` = `PowerSystems.get_reactive_power_limits(device).max`

**Time Series Parameters:**

Uses the `max_active_power` timeseries parameter to limit the available active power at each time-step. If the timeseries parameter is not included, the power is limited by ``P^\text{th,max}``.

**Objective:**

Add a cost to the objective function depending on the defined cost structure of the hydro unit by adding it to its `ProductionCostExpression`.

**Expressions:**

Adds ``p^\text{hy}`` to the `ActivePowerBalance` expression and ``q^\text{hy}`` to the `ReactivePowerBalance`, to be used in the supply-balance constraint depending on the network model used.

**Constraints:**

For each hydro unit creates the range constraints for its active and reactive power depending on its static parameters.

```math
\begin{align*}
&  P^\text{hy,min} \le p^\text{hy}_t \le \text{ActivePowerTimeSeriesParameter}_t, \quad \forall t\in \{1, \dots, T\} \\
&  Q^\text{hy,min} \le q^\text{hy}_t \le Q^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} 
\end{align*}
```

* * *

## `HydroDispatchReservoirBudget`

```@docs
HydroDispatchReservoirBudget
```

**Variables:**

  - `ActivePowerVariable`:
    
      + Bounds: [0.0, ]
      + Symbol: ``p^\text{hy}``

  - `ReactivePowerVariable`:
    
      + Bounds: [0.0, ]
      + Symbol: ``q^\text{hy}``

**Auxiliary Variables:**

  - [`HydroEnergyOutput`](@ref):
    
      + Symbol: ``E^\text{hy,out}``

The `HydroEnergyOutput` is computed as the energy used at each time step from the hydro, computed simply as ``E^\text{hy,out} \cdot \Delta T``, where ``\Delta T`` is the duration (in hours) of each time step.

**Static Parameters:**

  - ``P^\text{hy,min}`` = `PowerSystems.get_active_power_limits(device).min`
  - ``P^\text{hy,max}`` = `PowerSystems.get_active_power_limits(device).max`
  - ``Q^\text{hy,min}`` = `PowerSystems.get_reactive_power_limits(device).min`
  - ``Q^\text{hy,max}`` = `PowerSystems.get_reactive_power_limits(device).max`

**Time Series Parameters:**

Uses the `hydro_budget` timeseries parameter to limit the active power usage throughout all the time steps.

**Objective:**

Add a cost to the objective function depending on the defined cost structure of the hydro unit by adding it to its `ProductionCostExpression`.

**Expressions:**

Adds ``p^\text{hy}`` to the `ActivePowerBalance` expression and ``q^\text{hy}`` to the `ReactivePowerBalance`, to be used in the supply-balance constraint depending on the network model used.

**Constraints:**

For each hydro unit creates the range constraints for its active and reactive power depending on its static parameters.

```math
\begin{align*}
&  P^\text{hy,min} \le p^\text{hy}_t \le P^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} \\
&  Q^\text{hy,min} \le q^\text{hy}_t \le Q^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} \\
& \sum_{t=1}^T p^\text{hy}_t \le \sum_{t=1}^T \text{EnergyBudgetTimeSeriesParameter}_t,
\end{align*}
```

* * *

## `HydroDispatchReservoirStorage`

```@docs
HydroDispatchReservoirStorage
```

**Variables:**

  - `ActivePowerVariable`:
    
      + Bounds: [0.0, ]
      + Symbol: ``p^\text{hy}``

  - `ReactivePowerVariable`:
    
      + Bounds: [0.0, ]
      + Symbol: ``q^\text{hy}``
  - `EnergyVariable`:
    
      + Bounds: ``[0.0, E^\text{max}]``
      + Symbol: ``e``
  - [`WaterSpillageVariable`](@ref):
    
      + Bounds: [0.0, ]
      + Symbol: ``s``
  - [`HydroEnergySurplusVariable`](@ref):
    
      + Bounds: ``[-E^\text{max}, 0.0]``
      + Symbol: ``e^\text{surplus}``
  - [`HydroEnergyShortageVariable`](@ref):
    
      + Bounds: ``[0.0, E^\text{max}]``
      + Symbol: ``e^\text{shortage}``

**Auxiliary Variables:**

  - [`HydroEnergyOutput`](@ref):
    
      + Symbol: ``E^\text{hy,out}``

The `HydroEnergyOutput` is computed as the energy used at each time step from the hydro, computed simply as ``E^\text{hy,out} \cdot \Delta T``, where ``\Delta T`` is the duration (in hours) of each time step.

**Static Parameters:**

  - ``P^\text{hy,min}`` = `PowerSystems.get_active_power_limits(device).min`
  - ``P^\text{hy,max}`` = `PowerSystems.get_active_power_limits(device).max`
  - ``Q^\text{hy,min}`` = `PowerSystems.get_reactive_power_limits(device).min`
  - ``Q^\text{hy,max}`` = `PowerSystems.get_reactive_power_limits(device).max`
  - ``E^\text{max}`` = `PowerSystems.get_storage_capacity(device)`

**Initial Conditions:**

The `PowerSimulations.InitialEnergyLevel`: ``e_0`` is used as the initial condition for the energy level of the reservoir.

**Time Series Parameters:**

Uses the `storage_target` timeseries parameter to set a storage target of the reservoir and the `inflow` timeseries parameter to obtain the inflow to the reservoir.

**Objective:**

Add a cost to the objective function depending on the defined cost structure of the hydro unit by adding it to its `ProductionCostExpression`. This model has shortage costs for the energy target that are also added to the objective function. In case of no shortage cost are specified, the model will turn-off the shortage variable to avoid infeasible/unbounded problems.

**Expressions:**

Adds ``p^\text{hy}`` to the `ActivePowerBalance` expression and ``q^\text{hy}`` to the `ReactivePowerBalance`, to be used in the supply-balance constraint depending on the network model used.

**Constraints:**

For each hydro unit creates the range constraints for its active and reactive power depending on its static parameters.

```math
\begin{align*}
&  P^\text{hy,min} \le p^\text{hy}_t \le P^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} \\
&  Q^\text{hy,min} \le q^\text{hy}_t \le Q^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} \\
& e_{t} = e_{t-1} - \Delta T (p^\text{hy}_t - s_t) + \text{InflowTimeSeriesParameter}_t, \quad \forall t\in \{1, \dots, T\} \\
& e_t + e^\text{shortage} + e^\text{surplus} = \text{EnergyTargetTimeSeriesParameter}_t, \quad \forall t\in \{1, \dots, T\}
\end{align*}
```

* * *

## HydroDispatchPumpedStorage

This formulation is not available with reactive power. This formulation must be used with `PowerSystems.HydroPumpedStorage` component.

```@docs
HydroDispatchPumpedStorage
```

**Variables:**

  - `ActivePowerOutVariable`:
    
      + Bounds: [0.0, ]
      + Symbol: ``p^\text{hy,out}``

  - `ActivePowerInVariable`:
    
      + Bounds: [0.0, ]
      + Symbol: ``p^\text{hy,in}``
  - [`HydroEnergyVariableUp`](@ref):
    
      + Bounds: ``[0.0, E^\text{max,up}]``
      + Symbol: ``e^\text{up}``
  - [`HydroEnergyVariableDown`](@ref):
    
      + Bounds: ``[0.0, E^\text{max,dn}]``
      + Symbol: ``e^\text{dn}``
  - [`WaterSpillageVariable`](@ref):
    
      + Bounds: [0.0, ]
      + Symbol: ``s``

If the attribute `reservation` is set to true, the following variable is created:

  - `ReservationVariable`:
    
      + Bounds: ``\{0,1\}``
      + Symbol: ``ss^\text{hy}``

If `reservation` is set to false (default), then the hydro pumped storage is allowed to pump and discharge simultaneously at each time step.

**Static Parameters:**

  - ``P^\text{out,min}`` = `PowerSystems.get_active_power_limits(device).min`
  - ``P^\text{out,max}`` = `PowerSystems.get_active_power_limits(device).max`
  - ``P^\text{in,min}`` = `PowerSystems.get_active_power_limits_pump(device).min`
  - ``P^\text{in,max}`` = `PowerSystems.get_active_power_limits_pump(device).max`
  - ``E^\text{max,up}`` = `PowerSystems.get_storage_capacity(device).up`
  - ``E^\text{max,dn}`` = `PowerSystems.get_storage_capacity(device).down`
  - ``\eta^\text{pump}`` = `PowerSystems.get_pump_efficiency(device)`

**Initial Conditions:**

The `InitialHydroEnergyLevelUp`: ``e_0^\text{up}`` is used as the initial condition for the energy level of the upper reservoir, while `InitialHydroEnergyLevelDown`: ``e_0^\text{dn}`` is used as the initial condition for the energy level of the lower reservoir.

**Time Series Parameters:**

Uses the `inflow` and `outflow` timeseries to obtain the inflow and outflow to the reservoir. `inflow` corresponds to the inflow into the upper (up) reservoir, while `outflow` corresponds to the outflow from the lower (down) reservoir.

**Objective:**

Add a cost to the objective function depending on the defined cost structure of the hydro unit by adding it to its `ProductionCostExpression`.

**Expressions:**

Adds ``(p^\text{hy,out} - p^\text{hy,in})`` to the `ActivePowerBalance` to be used in the supply-balance constraint depending on the network model used.

**Constraints:**

If `reservation = true`, the limits are given by:

```math
\begin{align*}
& ss_t^\text{hy} P^\text{out,min} \le p^\text{hy,out}_t \le ss_t^\text{hy} P^\text{out,max}, \quad \forall t\in \{1, \dots, T\} \\
& (1-ss_t^\text{hy}) P^\text{in,min} \le p^\text{hy,in}_t \le (1 - ss_t^\text{hy}) P^\text{in,max}, \quad \forall t\in \{1, \dots, T\} 
\end{align*}
```

If `reservation = false`, then:

```math
\begin{align*}
& P^\text{out,min} \le p^\text{hy,out}_t \le P^\text{out,max}, \quad \forall t\in \{1, \dots, T\} \\
& P^\text{in,min} \le p^\text{hy,in}_t \le  P^\text{in,max}, \quad \forall t\in \{1, \dots, T\} 
\end{align*}
```

The remaining constraints are:

```math
\begin{align*}
e_{t}^\text{up} = e_{t-1}^\text{up} + \left (p_t^\text{hy,in} - \frac{p_t^\text{hy,out} + s_t}{\eta^\text{pump}} \right) \Delta T + \text{InflowTimeSeriesParameter}_t, \quad \forall t\in \{1, \dots, T\} \\
e_{t}^\text{dn} = e_{t-1}^\text{dn} + \left (p_t^\text{hy,out} + s_t - \frac{p_t^\text{hy,in}}{\eta^\text{pump}} \right) \Delta T - \text{OutflowTimeSeriesParameter}_t, \quad \forall t\in \{1, \dots, T\}  
\end{align*}
```

* * *

## `HydroCommitmentRunOfRiver`

```@docs
HydroCommitmentRunOfRiver
```

**Variables:**

  - `ActivePowerVariable`:
    
      + Bounds: [0.0, ]
      + Symbol: ``p^\text{hy}``

  - `ReactivePowerVariable`:
    
      + Bounds: [0.0, ]
      + Symbol: ``q^\text{hy}``
  - `OnVariable`:
    
      + Bounds: ``\{0, 1\}``
      + Symbol: ``u^\text{hy}``

**Auxiliary Variables:**

  - [`HydroEnergyOutput`](@ref):
    
      + Symbol: ``E^\text{hy,out}``

The `HydroEnergyOutput` is computed as the energy used at each time step from the hydro, computed simply as ``E^\text{hy,out} \cdot \Delta T``, where ``\Delta T`` is the duration (in hours) of each time step.

**Static Parameters:**

  - ``P^\text{hy,min}`` = `PowerSystems.get_active_power_limits(device).min`
  - ``P^\text{hy,max}`` = `PowerSystems.get_active_power_limits(device).max`
  - ``Q^\text{hy,min}`` = `PowerSystems.get_reactive_power_limits(device).min`
  - ``Q^\text{hy,max}`` = `PowerSystems.get_reactive_power_limits(device).max`

**Time Series Parameters:**

Uses the `max_active_power` timeseries parameter to limit the available active power at each time-step. If the timeseries parameter is not included, the power is limited by ``P^\text{th,max}``.

**Objective:**

Add a cost to the objective function depending on the defined cost structure of the hydro unit by adding it to its `ProductionCostExpression`.

**Expressions:**

Adds ``p^\text{hy}`` to the `ActivePowerBalance` expression and ``q^\text{hy}`` to the `ReactivePowerBalance`, to be used in the supply-balance constraint depending on the network model used.

**Constraints:**

For each hydro unit creates the range constraints for its active and reactive power depending on its static parameters.

```math
\begin{align*}
&  u_t^\text{hy} P^\text{hy,min} \le p^\text{hy}_t \le u_t^\text{hy} \text{ActivePowerTimeSeriesParameter}_t, \quad \forall t\in \{1, \dots, T\} \\
& u_t^\text{hy} Q^\text{hy,min} \le q^\text{hy}_t \le u_t^\text{hy} Q^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} 
\end{align*}
```

* * *

## `HydroCommitmentReservoirBudget`

```@docs
HydroCommitmentReservoirBudget
```

**Variables:**

  - `ActivePowerVariable`:
    
      + Bounds: [0.0, ]
      + Symbol: ``p^\text{hy}``

  - `ReactivePowerVariable`:
    
      + Bounds: [0.0, ]
      + Symbol: ``q^\text{hy}``
  - `OnVariable`:
    
      + Bounds: ``\{0, 1\}``
      + Symbol: ``u^\text{hy}``

**Auxiliary Variables:**

  - [`HydroEnergyOutput`](@ref):
    
      + Symbol: ``E^\text{hy,out}``

The `HydroEnergyOutput` is computed as the energy used at each time step from the hydro, computed simply as ``E^\text{hy,out} \cdot \Delta T``, where ``\Delta T`` is the duration (in hours) of each time step.

**Static Parameters:**

  - ``P^\text{hy,min}`` = `PowerSystems.get_active_power_limits(device).min`
  - ``P^\text{hy,max}`` = `PowerSystems.get_active_power_limits(device).max`
  - ``Q^\text{hy,min}`` = `PowerSystems.get_reactive_power_limits(device).min`
  - ``Q^\text{hy,max}`` = `PowerSystems.get_reactive_power_limits(device).max`

**Time Series Parameters:**

Uses the `hydro_budget` timeseries parameter to limit the active power usage throughout all the time steps.

**Objective:**

Add a cost to the objective function depending on the defined cost structure of the hydro unit by adding it to its `ProductionCostExpression`.

**Expressions:**

Adds ``p^\text{hy}`` to the `ActivePowerBalance` expression and ``q^\text{hy}`` to the `ReactivePowerBalance`, to be used in the supply-balance constraint depending on the network model used.

**Constraints:**

For each hydro unit creates the range constraints for its active and reactive power depending on its static parameters.

```math
\begin{align*}
&  u_t^\text{hy} P^\text{hy,min} \le p^\text{hy}_t \le u_t^\text{hy} P^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} \\
&  u_t^\text{hy} Q^\text{hy,min} \le q^\text{hy}_t \le u_t^\text{hy} Q^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} \\
& \sum_{t=1}^T p^\text{hy}_t \le \sum_{t=1}^T \text{EnergyBudgetTimeSeriesParameter}_t,
\end{align*}
```

* * *

## `HydroDispatchReservoirStorage`

```@docs
HydroCommitmentReservoirStorage
```

**Variables:**

  - `ActivePowerVariable`:
    
      + Bounds: [0.0, ]
      + Symbol: ``p^\text{hy}``

  - `ReactivePowerVariable`:
    
      + Bounds: [0.0, ]
      + Symbol: ``q^\text{hy}``
  - `OnVariable`:
    
      + Bounds: ``\{0, 1\}``
      + Symbol: ``u^\text{hy}``
  - `EnergyVariable`:
    
      + Bounds: ``[0.0, E^\text{max}]``
      + Symbol: ``e``
  - [`WaterSpillageVariable`](@ref):
    
      + Bounds: [0.0, ]
      + Symbol: ``s``
  - [`HydroEnergySurplusVariable`](@ref):
    
      + Bounds: ``[-E^\text{max}, 0.0]``
      + Symbol: ``e^\text{surplus}``
  - [`HydroEnergyShortageVariable`](@ref):
    
      + Bounds: ``[0.0, E^\text{max}]``
      + Symbol: ``e^\text{shortage}``

**Auxiliary Variables:**

  - [`HydroEnergyOutput`](@ref):
    
      + Symbol: ``E^\text{hy,out}``

The `HydroEnergyOutput` is computed as the energy used at each time step from the hydro, computed simply as ``E^\text{hy,out} \cdot \Delta T``, where ``\Delta T`` is the duration (in hours) of each time step.

**Static Parameters:**

  - ``P^\text{hy,min}`` = `PowerSystems.get_active_power_limits(device).min`
  - ``P^\text{hy,max}`` = `PowerSystems.get_active_power_limits(device).max`
  - ``Q^\text{hy,min}`` = `PowerSystems.get_reactive_power_limits(device).min`
  - ``Q^\text{hy,max}`` = `PowerSystems.get_reactive_power_limits(device).max`
  - ``E^\text{max}`` = `PowerSystems.get_storage_capacity(device)`

**Initial Conditions:**

The `PowerSimulations.InitialEnergyLevel`: ``e_0`` is used as the initial condition for the energy level of the reservoir.

**Time Series Parameters:**

Uses the `storage_target` timeseries parameter to set a storage target of the reservoir and the `inflow` timeseries parameter to obtain the inflow to the reservoir.

**Objective:**

Add a cost to the objective function depending on the defined cost structure of the hydro unit by adding it to its `ProductionCostExpression`. This model has shortage costs for the energy target that are also added to the objective function. In case of no shortage cost are specified, the model will turn-off the shortage variable to avoid infeasible/unbounded problems.

**Expressions:**

Adds ``p^\text{hy}`` to the `ActivePowerBalance` expression and ``q^\text{hy}`` to the `ReactivePowerBalance`, to be used in the supply-balance constraint depending on the network model used.

**Constraints:**

For each hydro unit creates the range constraints for its active and reactive power depending on its static parameters.

```math
\begin{align*}
&  u_t^\text{hy} P^\text{hy,min} \le p^\text{hy}_t \le u_t^\text{hy} P^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} \\
&  u_t^\text{hy} Q^\text{hy,min} \le q^\text{hy}_t \le u_t^\text{hy} Q^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} \\
& e_{t} = e_{t-1} - \Delta T (p^\text{hy}_t - s_t) + \text{InflowTimeSeriesParameter}_t, \quad \forall t\in \{1, \dots, T\} \\
& e_t + e^\text{shortage} + e^\text{surplus} = \text{EnergyTargetTimeSeriesParameter}_t, \quad \forall t\in \{1, \dots, T\}
\end{align*}
```
