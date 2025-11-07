# `HydroPowerSimulations` Formulations

Hydro generation formulations define the optimization models that describe hydro units mathematical model in different operational settings, such as economic dispatch and unit commitment.

!!! note
    
    The use of reactive power variables and constraints will depend on the network model used, i.e., whether it uses (or does not use) reactive power. If the network model is purely active power-based,  reactive power variables and related constraints are not created.

!!! note
    
    Reserve variables for services are not included in the formulation, albeit their inclusion change the variables, expressions, constraints and objective functions created. A detailed description of the implications in the optimization models is described in the [Service formulation](https://nrel-sienna.github.io/PowerSimulations.jl/latest/formulation_library/Service/) in the [PowerSimulations documentation](https://nrel-sienna.github.io/PowerSimulations.jl/latest/).

### Table of Contents

 1. [`HydroDispatchRunOfRiver`](#HydroDispatchRunOfRiver)
 2. [`HydroDispatchRunOfRiverBudget`](#HydroDispatchRunOfRiverBudget)
 3. [`HydroCommitmentRunOfRiver`](#HydroCommitmentRunOfRiver)
 4. [`HydroTurbineEnergyDispatch`](#HydroTurbineEnergyDispatch)
 5. [`HydroTurbineBilinearDispatch`](#HydroTurbineBilinearDispatch)
 6. [`HydroEnergyModelReservoir`](#HydroEnergyModelReservoir)
 7. [`HydroWaterModelReservoir`](#HydroWaterModelReservoir)
 8. [`HydroEnergyBlockOptimization`](#HydroEnergyBlockOptimization)

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

  - ``P^\text{hy,min}`` = `PowerSystems.get_active_power_limits(device).min`
  - ``P^\text{hy,max}`` = `PowerSystems.get_active_power_limits(device).max`
  - ``Q^\text{hy,min}`` = `PowerSystems.get_reactive_power_limits(device).min`
  - ``Q^\text{hy,max}`` = `PowerSystems.get_reactive_power_limits(device).max`

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

Formulation type to add injection variables constrained by a maximum injection time series and a budget time series for [`PowerSystems.HydroGen`](@extref). This formulation is equivalent than [`HydroDispatchRunOfRiver`](@ref), but with the option to include a time series with a budget.

```@docs; canonical=false
HydroDispatchRunOfRiverBudget
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

  - ``P^\text{hy,min}`` = `PowerSystems.get_active_power_limits(device).min`
  - ``P^\text{hy,max}`` = `PowerSystems.get_active_power_limits(device).max`
  - ``Q^\text{hy,min}`` = `PowerSystems.get_reactive_power_limits(device).min`
  - ``Q^\text{hy,max}`` = `PowerSystems.get_reactive_power_limits(device).max`

**Time Series Parameters:**

Uses the `max_active_power` timeseries parameter to limit the available active power at each time-step. If the timeseries parameter is not included, the power is limited by $P^\text{th,max}$.

Uses the `hydro_budget` timeseries parameter to limit the sum of available active power throughout the horizon. An attribute `hydro_budget_interval` can be used to also limit the sum during a specified interval (smaller than the horizon) during a simulation.

**Attributes:**

During the model setup, the attribute `hydro_budget_interval` can be used to set-up a budget constraint with smaller interval than the full horizon of the simulation. For example if a problem has an horizon of `Hour(48)`, with an hourly resolution, the attribute `hydro_budget_interval = Hour(24)` can be used to also impose a budget constraint in the first 24 hours (in addition of the full 48 hours constraint).

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
&  Q^\text{hy,min} \le q^\text{hy}_t \le Q^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} \\
& \sum_{t = 1}^T p^\text{hy}_t \le \sum_{t = 1}^T  \text{EnergyBudgetTimeSeriesParameter}_t, \\
& \sum_{t = 1}^{T_\text{interval}} p^\text{hy}_t \le \sum_{t = 1}^{T_\text{interval}}  \text{EnergyBudgetTimeSeriesParameter}_t, \quad \text{if }T_\text{interval}\text{ is specified}
\end{align*}
```

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

  - ``P^\text{hy,min}`` = `PowerSystems.get_active_power_limits(device).min`
  - ``P^\text{hy,max}`` = `PowerSystems.get_active_power_limits(device).max`
  - ``Q^\text{hy,min}`` = `PowerSystems.get_reactive_power_limits(device).min`
  - ``Q^\text{hy,max}`` = `PowerSystems.get_reactive_power_limits(device).max`

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

* * *

## `HydroTurbineBilinearDispatch`

```@docs; canonical=false
HydroTurbineBilinearDispatch
```

**Variables:**

  - [`PowerSimulations.ActivePowerVariable`](@extref):
    
      + Bounds: [0.0, ]
      + Symbol: ``p^\text{hy}``

  - [`PowerSimulations.ReactivePowerVariable`](@extref):
    
      + Bounds: [0.0, ]
      + Symbol: ``q^\text{hy}``
  - [`HydroTurbineFlowRateVariable`](@ref):
    
      + Bounds: [0.0, ]
      + Symbol: ``f^\text{hy}``

**Expressions added:**

  - [`TotalHydroFlowRateTurbineOutgoing`](@ref):
    
      + Symbol: ``f^\text{hy,out}``

The [`TotalHydroFlowRateTurbineOutgoing`](@ref) is computed as the total water flow outgoing of a turbine. This is helpful if the turbine is feed by multiple upstream reservoirs.

**Static Parameters:**

  - ``P^\text{hy,min}`` = `PowerSystems.get_active_power_limits(device).min`
  - ``P^\text{hy,max}`` = `PowerSystems.get_active_power_limits(device).max`
  - ``Q^\text{hy,min}`` = `PowerSystems.get_reactive_power_limits(device).min`
  - ``Q^\text{hy,max}`` = `PowerSystems.get_reactive_power_limits(device).max`
  - ``F^\text{hy, max}`` = `PowerSystems.get_outflow_limits(device).max`
  - ``F^\text{hy, min}`` = `PowerSystems.get_outflow_limits(device).min`
  - ``\text{powH}`` = `PowerSystems.get_powerhouse_elevation(device)`

**Objective:**

Add a cost to the objective function depending on the defined cost structure of the hydro turbine by adding it to its `ProductionCostExpression`.

**Expressions:**

Adds $p^\text{hy}$ to the `PowerSimulations.ActivePowerBalance` expression and $q^\text{hy}$ to the `PowerSimulations.ReactivePowerBalance`, to be used in the supply-balance constraint depending on the network model used.

**Constraints:**

For each hydro turbine creates the range constraints for its active, reactive power and water flow depending on its static parameters. By defining the set ``\mathcal{R}^{up}`` as the set of upstream reservoirs connected to the turbine, the turbine power output relationship can be added.

```math
\begin{align*}
&  P^\text{hy,min} \le p^\text{hy}_t \le P^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} \\
&  Q^\text{hy,min} \le q^\text{hy}_t \le Q^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} \\
&  F^\text{hy,min} \le f^\text{hy}_t \le F^\text{hy,max}, \quad \forall t\in \{1, \dots, T\} \\
&  p^\text{hy} = 10^{-6} \cdot \text{SysBasePower}^{-1} \cdot \rho g \sum_{r \in \mathcal{R}^{up}} f^\text{hy}_{r,t} \left(h_{r,t} + \text{inH} - \text{powH} \right) 
\end{align*}
```

where ``h`` is the effective hydraulic head (above the intake), the ``\text{inH}`` is the intake elevation (in meters above the sea level), ``\text{powH}`` is the powerhouse elevation (in meters above the sea level), ``g = 9.81~ \text{m/s}^2`` is the gravitational constant, and ``\rho = 1000~ \text{kg/m}^3`` is the water density. Finally, the term ``10^{-6} \cdot \text{SysBasePower}^{-1}`` is used to transform the power in Watts into per-unit.

* * *

## `HydroEnergyModelReservoir`

```@docs; canonical=false
HydroEnergyModelReservoir
```

**Variables:**

  - [`PowerSimulations.EnergyVariable`](@extref):
    
      + Bounds: ``[E^\text{min}, E^\text{max}]``
      + Symbol: ``e^\text{hy}``

  - [`WaterSpillageVariable`](@ref):
    
      + Bounds: ``[S^\text{min}, S^\text{max}]``
      + Symbol: ``s``
  - [`HydroEnergySurplusVariable`](@ref):
    
      + Bounds: ``[-E^\text{max}, 0.0]``
      + Symbol: ``e^\text{surplus}``
  - [`HydroEnergyShortageVariable`](@ref):
    
      + Bounds: ``[0.0, E^\text{max}]``
      + Symbol: ``e^\text{shortage}``

**Expressions added:**

  - [`TotalHydroPowerReservoirIncoming`](@ref):
    
      + Symbol: ``p^\text{hy,in}``

  - [`TotalHydroPowerReservoirOutgoing`](@ref):
    
      + Symbol: ``p^\text{hy,out}``
  - [`TotalSpillagePowerReservoirIncoming`](@ref):
    
      + Symbol: ``s^\text{in}``

**Static Parameters:**

  - ``E^\text{max}`` = `PowerSystems.get_storage_level_limits(device).max`
  - ``E^\text{min}`` = `PowerSystems.get_storage_level_limits(device).min`
  - ``E^\text{init}`` = `PowerSystems.get_initial_level(device)`
  - ``S^\text{max}`` = `PowerSystems.get_spillage_limits(device).max`
  - ``S^\text{min}`` = `PowerSystems.get_spillage_limits(device).min`

**Initial Conditions:**

The `PowerSimulations.InitialEnergyLevel`: ``e_0 = E^\text{init}`` is used as the initial condition for the energy level of the reservoir.

**Time Series Parameters:**

Uses the `storage_target` timeseries parameter to set a storage target of the reservoir, `hydro_budget` timeseries parameter to set a hydro budget of the reservoir and the `inflow` timeseries parameter to obtain the inflow to the reservoir.

**Objective:**

Add a cost to the objective function depending on the defined cost structure of the hydro reservoir by adding it to its `ProductionCostExpression`. This model has shortage costs for the energy target that are also added to the objective function. In case of no shortage cost are specified, the model will turn-off the shortage variable to avoid infeasible/unbounded problems.

**Expressions:**

In addition the incoming turbine power expression ``p^\text{hy,in}`` handles the total power coming from upstream turbines connected to this reservoir, the outgoing turbine power expression ``p^\text{hy,out}`` handles the total power going out to the downstream turbines from this reservoir. Finally, the incoming spillage expression ``s^\text{in}`` handles the power coming from upstream reservoirs that was spilled into this reservoir.

**Attributes:**

During the model setup, the attribute `hydro_budget = true` can be used to set-up a budget constraint with the full horizon of the simulation. The attribute `storage_target = true` can be used to set-up a storage target constraint at the end of the simulation horizon. It is not recommended to set both attributes to true simultaneously to avoid infeasibility issues.

**Constraints:**

For each hydro reservoir creates the constraints to track the energy storage.

```math
\begin{align*}
& e_{t}^\text{hy} = e_{t-1}^\text{hy} + \Delta T \left(p^\text{hy,in}_t + s^\text{in}_t + \text{InflowTimeSeriesParameter}_t - p^\text{hy,out} - s^\text{hy}\right), \quad \forall t\in \{1, \dots, T\} \\
& e_T^\text{hy} + e^\text{shortage} + e^\text{surplus} = \text{EnergyTargetTimeSeriesParameter}_T, \quad \text{ if storage_target true} \\
& \sum_{t=1}^T p^\text{hy}_t \le \sum_{t=1}^T \text{EnergyBudgetTimeSeriesParameter}_t, \quad \text{ if hydro_budget true}
\end{align*}
```

* * *

## `HydroWaterModelReservoir`

```@docs; canonical=false
HydroWaterModelReservoir
```

**Variables:**

  - [`HydroReservoirHeadVariable`](@ref):
    
      + Bounds: ``[L^\text{head, min}, L^\text{head, max}]``
      + Symbol: ``h^\text{hy}``

  - [`HydroReservoirVolumeVariable`](@ref):
    
      + Bounds: ``[L^\text{vol, min}, L^\text{vol, max}]``
      + Symbol: ``v^\text{hy}``
  - [`WaterSpillageVariable`](@ref):
    
      + Bounds: ``[S^\text{min}, S^\text{max}]``
      + Symbol: ``s``

**Expressions added:**

  - [`TotalHydroFlowRateReservoirIncoming`](@ref):
    
      + Symbol: ``f^\text{hy,in}``

  - [`TotalHydroFlowRateReservoirOutgoing`](@ref):
    
      + Symbol: ``f^\text{hy,out}``
  - [`TotalSpillageFlowRateReservoirIncoming`](@ref):
    
      + Symbol: ``s^\text{in}``

**Static Parameters:**

  - ``L^\text{max}`` = `PowerSystems.get_storage_level_limits(device).max`
  - ``L^\text{min}`` = `PowerSystems.get_storage_level_limits(device).min`
  - ``L^\text{init}`` = `PowerSystems.get_initial_level(device)`
  - ``S^\text{max}`` = `PowerSystems.get_spillage_limits(device).max`
  - ``S^\text{min}`` = `PowerSystems.get_spillage_limits(device).min`
  - ``\text{h2v}`` = `PowerSystems.get_head_to_volume_factor(device)`

The parameter ``L`` for level will be dependent on the `ReservoirDataType` provided in each reservoir, and can bound the hydraulic head or volume variable.

**Initial Conditions:**

The `InitialReservoirVolume`: ``l_0 = L^\text{init}`` is used as the initial condition for the volume level of the reservoir.

**Time Series Parameters:**

The `inflow` and `outflow` timeseries parameter are used to obtain the external inflow and outflow to the reservoir.

**Objective:**

Add a cost to the objective function depending on the defined cost structure of the hydro reservoir by adding it to its `ProductionCostExpression`.

**Expressions:**

The incoming turbine flow expression ``f^\text{hy,in}`` handles the total water flow coming from upstream turbines connected to this reservoir, the outgoing turbine flow expression ``f^\text{hy,out}`` handles the total water flow going out to the downstream turbines from this reservoir. Finally, the incoming spillage expression ``s^\text{in}`` handles the water flow coming from upstream reservoirs that was spilled into this reservoir.

**Attributes:**

During the model setup, the attribute `hydro_budget = true` can be used to set-up a budget constraint with the full horizon of the simulation. The attribute `storage_target = true` can be used to set-up a storage target constraint at the end of the simulation horizon. It is not recommended to set both attributes to true simultaneously to avoid infeasibility issues.

**Constraints:**

For each hydro reservoir creates the constraints to track the energy storage.

```math
\begin{align*}
& v_{t}^\text{hy} = v_{t-1}^\text{hy} + 3600\Delta T \left(f^\text{hy,in}_t + s^\text{in}_t + \text{InflowTimeSeriesParameter}_t - p^\text{hy,out} - s^\text{hy}- \text{OutflowTimeSeriesParameter}_t\right), \quad \forall t\in \{1, \dots, T\} \\
& v_t^\text{hy} = \text{h2v} \cdot  h_t^\text{hy}, \quad \forall t\in \{1, \dots, T\}  
\end{align*}
```

* * *

## `HydroEnergyBlockOptimization`

Formulation type to constrain hydropower production with an energy block optimization representation of the energy storage capacity and water inflow time series of a reservoir for [`PowerSystems.HydroGen`]

```@docs; canonical=false
HydroEnergyBlockOptimization
```

**Initial Conditions:**

**Variables:**

**Auxiliary Variables:**

**Static Parameters:**

  - ``\eta``:  Turbine efficiency
  - ``\rho``:  water density = ``1000 kg/m^3``
  - ``g``: Gravitational constant = ``9.81 m/s^2``
  - ``K``: Energy block constant =  ``\eta \rho g``
  - ``h2v``: Head to volume conversion factor.

**Time Series Parameters:**

Uses the `InflowTimeSeriesParameter` and `OutflowTimeSeriesParameter` for track the water inflow and outflow at each time-step.

**Objective:**

Add a cost to the objective function depending on the defined cost structure of the hydro unit by adding it to its `ProductionCostExpression`.

**Expressions:**

**Constraints:**

```math
\begin{align*}
  p^\text{hy}_1 = K \times f^\text{out}_{hy, 1} (h2v \times v_{res, 0} + H^\text{elevation}_{hy}), \quad \\
  p^\text{hy}_t = K \times f^\text{out}_{hy, t} (0.5 \times h2v (v_{res, t-1} + v_{res, t} + H^\text{elevation}_{hy}), \quad \forall t \in \{1, \dots T\}
\end{align*}
```

* * *
