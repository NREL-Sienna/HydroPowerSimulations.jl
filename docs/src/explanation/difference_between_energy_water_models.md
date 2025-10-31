# Difference between Energy Models and Water Models

`HydroPowerSimulations.jl` allow setting energy targets or hydro budgets in the models formulation. Based on the available data and the desired formulation, the corresponding constraints are added to the `DeviceModel`.

  - Currently, the following formulations allow setting energy targets:
    
      + `HydroEnergyModelReservoir`
      + `HydroPumpEnergyDispatch`
      + `HydroTurbineEnergyDispatch`

  - The following energy-based models accept passing the `EnergyBudgetTimeSeriesParameter`:
    
      + `HydroDispatchRunOfRiverBudget`
      + `HydroEnergyModelReservoir`
  - The following energy-based models accept passing the `EnergyTargetTimeSeriesParameter`:
    
      + `HydroEnergyModelReservoir`
  - The following device models accept passing the `EnergyBudgetTimeSeriesParameter`:
    
      + `PSY.HydroGen`
      + `PSY.HydroReservoir`
