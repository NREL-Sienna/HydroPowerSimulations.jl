# Difference between Energy Models and Water Models

`HydroPowerSimulations.jl` allow setting energy targets or hydro budgets in the models formulation. Based on the available data and the desired formulation, the corresponding constraints are added to the `DeviceModel`. 

## Energy Budget for `HydroEnergyModelReservoir`
- If the `energy_budget` attribute is enabled for the `HydroEnergyModelReservoir`, a constraint will be added to limit the sum of active power budget to be less than or equal to the sum of the energy budget (`EnergyBudgetTimeSeriesParameter`) at all time steps:  [(instructions on setting energy budget)](../how_to/include_limits_and_targets.md#-How-to-include-budget-limits-for-`HydroReservoir`) 

```math
\begin{align*}
\sum p^\text{hy}_t <= \sum EnergyBudget
\end{align*}
```

- Currently, the following formulations allow setting energy targets: 
    - `HydroEnergyModelReservoir`
    - `HydroPumpEnergyDispatch`
    - `HydroTurbineEnergyDispatch`

- The following energy-based models accept passing the `EnergyBudgetTimeSeriesParameter`: 
    - `HydroDispatchRunOfRiverBudget`
    - `HydroEnergyModelReservoir`

- The following energy-based models accept passing the `EnergyTargetTimeSeriesParameter`: 
    - `HydroEnergyModelReservoir`    

- The following device models accept passing the `EnergyBudgetTimeSeriesParameter`: 
    - `PSY.HydroGen`
    - `PSY.HydroReservoir`

