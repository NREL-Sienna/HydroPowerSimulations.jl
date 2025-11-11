## Including budget limits for `HydroDispatch`

  - [`HydroDispatch](@extref PowerSystems.HydroDispatch): can include budget limits if the [`HydroDispatchRunOfRiverBudget`](@ref) formulation is used. By adding a `hydro_budget`timeseries with values between 0 and 1, normalized by the`get_active_power_limits(hydro).max`, a single constraint is imposed as the budget during the simulation horizon:

```math
\begin{align*}
\sum_{t=1}^T p^\text{hy}_t \le \sum_{t=1}^T \text{EnergyBudgetTimeSeriesParameter}_t
\end{align*}
```

### Setting an interval budget for [`HydroDispatchRunOfRiverBudget`](@ref)

The attribute `hydro_budget_interval` can be used to set-up a budget constraint with smaller interval than the full horizon of the simulation. For example if a problem has an horizon of `Hour(48)`, with an hourly resolution, the attribute `hydro_budget_interval = Hour(24)` can be used to also impose a budget constraint in the first 24 hours (in addition of the full 48 hours constraint):

```julia
hydro_model = DeviceModel(
    HydroDispatch,
    HydroDispatchRunOfRiverBudget;
    attributes = Dict{String, Any}(
        "hydro_budget_interval" => Hour(24),
    ),
)

set_device_model!(template, hydro_model)
```

If no attribute is passed, only the horizon constraint is imposed.

## Including budget limits for [`HydroReservoir`](@extref PowerSystems.HydroReservoir)

  - [`HydroEnergyModelReservoir`](@ref): The budget limits are enabled in the [`DeviceModel`](@extref PowerSimulations.DeviceModel) by setting the `hydro_budget` key to `true` in the `attributes` Dict. For example:

```julia
reservoir_model = DeviceModel(
    HydroReservoir,
    HydroEnergyModelReservoir;
    attributes = Dict{String, Any}(
        "energy_target" => false,
        "hydro_budget" => true,
    ),
)

set_device_model!(template, reservoir_model)
```

### Setting a budget for [`HydroEnergyModelReservoir`](@ref)

  - If the `hydro_budget` attribute is enabled for the [`HydroEnergyModelReservoir`](@ref), the [`EnergyBudgetConstraint`](@ref) will be added to limit the sum of active power budget to be less than or equal to the sum of the energy budget [`EnergyBudgetTimeSeriesParameter`](@ref) for all time steps. See the article on [format data](@ref format_data) for more details.

```math
\begin{align*}
\sum_{t=1}^T p^\text{hy}_t \le \sum_{t=1}^T \text{EnergyBudgetTimeSeriesParameter}_t
\end{align*}
```

## Including storage target for [`HydroReservoir`](@extref PowerSystems.HydroReservoir)

  - [`HydroEnergyModelReservoir`](@ref): The storage targets are enabled in the [`DeviceModel`](@extref PowerSimulations.DeviceModel) by setting the `energy_target` key to `true` in the `attributes` Dict. For example:

```julia
reservoir_model = DeviceModel(
    HydroReservoir,
    HydroEnergyModelReservoir;
    attributes = Dict{String, Any}(
        "energy_target" => true,
        "hydro_budget" => false,
    ),
)

set_device_model!(template, reservoir_model)
```

### Setting a target for [`HydroEnergyModelReservoir`](@ref)

  - If the `energy_target` attribute is enabled for the [`HydroEnergyModelReservoir`](@ref), the [`EnergyTargetConstraint`](@ref) will be added  [`EnergyTargetTimeSeriesParameter`](@ref) at every timestep.  See the article on [format data](@ref format_data) for more details.

```math
\begin{align*}
\text{energy}_T + \text{shortage}_T + \text{surplus}_T =  \text{EnergyTargetTimeSeriesParameter}_T, 
\end{align*}
```
