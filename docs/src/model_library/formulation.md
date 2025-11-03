# `HydroPowerSimulations` Formulations

Hydro generation formulations define the optimization models that describe hydro units mathematical model in different operational settings, such as economic dispatch and unit commitment.

    The use of reactive power variables and constraints will depend on the network model used, i.e., whether it uses (or does not use) reactive power. If the network model is purely active power-based,  reactive power variables and related constraints are not created.


    Reserve variables for services are not included in the formulation, albeit their inclusion change the variables, expressions, constraints and objective functions created. A detailed description of the implications in the optimization models is described in the [Service formulation](https://nrel-sienna.github.io/PowerSimulations.jl/latest/formulation_library/Service/) in the [PowerSimulations documentation](https://nrel-sienna.github.io/PowerSimulations.jl/latest/).

### Table of Contents

 1. [`HydroDispatchRunOfRiver`](#HydroDispatchRunOfRiver)
 2. [`HydroDispatchRunOfRiverBudget`](#HydroDispatchRunOfRiverBudget)
 3. [`HydroCommitmentRunOfRiver`](#HydroCommitmentRunOfRiver)
 4. [`HydroTurbineEnergyDispatch`](#HydroTurbineEnergyDispatch)
 4. [`HydroEnergyBlockOptimization`](#HydroEnergyBlockOptimization)

## `HydroDispatchRunOfRiver`

Formulation type to add injection variables constrained by a maximum injection time series for [`PowerSystems.HydroGen`](@extref)

```@docs; canonical=false
HydroDispatchRunOfRiver
```

**Variables:**

  - [`PowerSimulations.ActivePowerVariable`](@extref):
    
      + Bounds: [0.0, ]
      + Symbol: $p^\text{hy}$

  - [`PowerSimulations.ReactivePowerVariable`](@extref):
    
      + Bounds: [0.0, ]
      + Symbol: $q^\text{hy}$

**Auxiliary Variables:**

  - [`HydroEnergyOutput`](@ref):
    
      + Symbol: $E^\text{hy,out}$

The [`HydroEnergyOutput`](@ref) is computed as the energy used at each time step from the hydro, computed simply as $E^\text{hy,out} \cdot \Delta T$, where $\Delta T$ is the duration (in hours) of each time step.

**Static Parameters:**

  - $P^\text{hy,min}$ = `PowerSystems.get_active_power_limits(device).min`
  - $P^\text{hy,max}$ = `PowerSystems.get_active_power_limits(device).max`
  - $Q^\text{hy,min}$ = `PowerSystems.get_reactive_power_limits(device).min`
  - $Q^\text{hy,max}$ = `PowerSystems.get_reactive_power_limits(device).max`

**Time Series Parameters:**

Uses the `max_active_power` timeseries parameter to limit the available active power at each time-step. If the timeseries parameter is not included, the power is limited by $P^\text{th,max}$.

**Objective:**

Add a cost to the objective function depending on the defined cost structure of the hydro unit by adding it to its `ProductionCostExpression`.

**Expressions:**

Adds $p^\text{hy}$ to the `PowerSimulations.ActivePowerBalance` expression and $q^\text{hy}$ to the `PowerSimulations.ReactivePowerBalance`, to be used in the supply-balance constraint depending on the network model used.

Adds $p^\text{hy}$ to `HydroServedReserveUpExpression`/`HydroServedReserveDownExpression` expressions to keep track of served reserve up/down for energy calculations.

**Constraints:**

For each hydro unit creates the range constraints for its active and reactive power depending on its static parameters.

```math
\begin{align*}
&  P^\text{hy,min} \le p^\text{hy}_t \le \text{ActivePowerTimeSeriesParameter}_t, \quad \forall t\in \{1, \dots, T\} \\
&  Q^\text{hy,min} \le q^\text{hy}_t \le Q^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} 
\end{align*}
```

* * *

## `HydroDispatchRunOfRiverBudget`

TODO

* * *

## `HydroCommitmentRunOfRiver`

```@docs; canonical=false
HydroCommitmentRunOfRiver
```

**Variables:**

  - [`PowerSimulations.ActivePowerVariable`](@extref):
    
      + Bounds: [0.0, ]
      + Symbol: ``p^\text{hy}``

  - [`PowerSimulations.ReactivePowerVariable`](@extref):
    
      + Bounds: [0.0, ]
      + Symbol: ``q^\text{hy}``
  - [`PowerSimulations.OnVariable`](@extref):
    
      + Bounds: ``\{0, 1\}``
      + Symbol: ``u^\text{hy}``

**Auxiliary Variables:**

  - [`HydroEnergyOutput`](@ref):
    
      + Symbol: ``E^\text{hy,out}``

The [`HydroEnergyOutput`](@ref) is computed as the energy used at each time step from the hydro, computed simply as ``E^\text{hy,out} \cdot \Delta T``, where ``\Delta T`` is the duration (in hours) of each time step.

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

Adds ``p^\text{hy}`` to the `PowerSimulations.ActivePowerBalance` expression and ``q^\text{hy}`` to the `PowerSimulations.ReactivePowerBalance`, to be used in the supply-balance constraint depending on the network model used.

**Constraints:**

For each hydro unit creates the range constraints for its active and reactive power depending on its static parameters.

```math
\begin{align*}
&  u_t^\text{hy} P^\text{hy,min} \le p^\text{hy}_t \le u_t^\text{hy} \text{ActivePowerTimeSeriesParameter}_t, \quad \forall t\in \{1, \dots, T\} \\
& u_t^\text{hy} Q^\text{hy,min} \le q^\text{hy}_t \le u_t^\text{hy} Q^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} 
\end{align*}
```

* * *

## `HydroTurbineEnergyDispatch`

```@docs; canonical=false
HydroTurbineEnergyDispatch
```

**Variables:**

  - [`PowerSimulations.ActivePowerVariable`](@extref):
    
      + Bounds: [0.0, ]
      + Symbol: ``p^\text{hy}``

  - [`PowerSimulations.ReactivePowerVariable`](@extref):
    
      + Bounds: [0.0, ]
      + Symbol: ``q^\text{hy}``

**Auxiliary Variables:**

  - [`HydroEnergyOutput`](@ref):
    
      + Symbol: ``E^\text{hy,out}``

The [`HydroEnergyOutput`](@ref) is computed as the energy used at each time step from the hydro turbine, computed simply as ``E^\text{hy,out} = p^\text{hy} \cdot \Delta T``, where ``\Delta T`` is the duration (in hours) of each time step.

**Static Parameters:**

  - $P^\text{hy,min}$ = `PowerSystems.get_active_power_limits(device).min`
  - $P^\text{hy,max}$ = `PowerSystems.get_active_power_limits(device).max`
  - $Q^\text{hy,min}$ = `PowerSystems.get_reactive_power_limits(device).min`
  - $Q^\text{hy,max}$ = `PowerSystems.get_reactive_power_limits(device).max`

**Objective:**

Add a cost to the objective function depending on the defined cost structure of the hydro turbine by adding it to its `ProductionCostExpression`.

**Expressions:**

Adds $p^\text{hy}$ to the `PowerSimulations.ActivePowerBalance` expression and $q^\text{hy}$ to the `PowerSimulations.ReactivePowerBalance`, to be used in the supply-balance constraint depending on the network model used.

**Constraints:**

For each hydro turbine creates the range constraints for its active and reactive power depending on its static parameters, and energy balance constraints for the reservoir.

```math
\begin{align*}
&  P^\text{hy,min} \le p^\text{hy}_t \le P^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} \\
&  Q^\text{hy,min} \le q^\text{hy}_t \le Q^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} 
\end{align*}
```

## `HydroEnergyBlockOptimization`

Formulation type to constrain hydropower production with an energy block optimization representation of the energy storage capacity and water inflow time series of a reservoir for [`PowerSystems.HydroGen`]

```@docs; canonical=false
HydroEnergyBlockOptimization
```

**Initial Conditions:**

**Variables:**

**Auxiliary Variables:**

**Static Parameters:**

  - $\eta$:  Turbine efficiency
  - $\rho$:  water density = $1000 kg/m^3$
  - $g$: Gravitional constant = $9.81 m/s^2$
  - $K$: Energy block constant =  $\eta \rho g$
  - $h2v$: Head to volume conversion factor.

**Time Series Parameters:**

Uses the `InflowTimeSeriesParameter` and `OutflowTimeSeriesParameter` for track the water inflow and outflow at each time-step.

**Objective:**

Add a cost to the objective function depending on the defined cost structure of the hydro unit by adding it to its `ProductionCostExpression`.

**Expressions:**

**Constraints:**

  - $p^\text{hy}_1 = K \times f^{out}_{hy, 1} (h2v \times v_{res, 0} + H^{elevation}_{hy}), \quad \forall hy, t >1$
  - $p^\text{hy}_t = K \times f^{out}_{hy, t} (0.5 \times h2v (v_{res, t-1} + v_{res, t} + H^{elevation}_{hy}), \quad \forall hy, t >1$

* * *
