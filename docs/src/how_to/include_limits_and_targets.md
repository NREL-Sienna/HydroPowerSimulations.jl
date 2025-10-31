

# How to include budget limits for `HydroReservoir`

- `HydroEnergyModelReservoir`: The budget limits are enabled in the `DeviceModel` by setting the `hydro_budget` key to `true` in the `attributes` Dict. For example: 

```
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

## Setting a budget for `HydroEnergyModelReservoir`
- If the `hydro_budget` attribute is enabled for the `HydroEnergyModelReservoir`, the `EnergyBudgetConstraint` will be added to limit the sum of active power budget to be less than or equal to the sum of the energy budget (`EnergyBudgetTimeSeriesParameter`) for all time steps:  [(instructions on setting hydro budget)](../how_to/include_limits_and_targets.md#-How-to-include-budget-limits-for-`HydroReservoir`) 

```math
\begin{align*}
\sum p^\text{hy}_t <= \sum EnergyBudget_t
\end{align*}
```


# How to include storage target for `HydroReservoir`

- `HydroEnergyModelReservoir`: The storage targets are enabled in the `DeviceModel` by setting the `energy_target` key to `true` in the `attributes` Dict. For example: 

```
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

## Setting a target for `HydroEnergyModelReservoir`
- If the `energy_target` attribute is enabled for the `HydroEnergyModelReservoir`, the `EnergyTargetConstraint` will be added  (`EnergyTargetTimeSeriesParameter`) at every timestep:  [(instructions on setting energy budget)](../how_to/include_limits_and_targets.md#-How-to-include-storage-targe-for-`HydroReservoir`)  

```math
\begin{align*}
energy_t + shortage_t + surplus_t =  EnergyTarget_t, \forall t
\end{align*}
```