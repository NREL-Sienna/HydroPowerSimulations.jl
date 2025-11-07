# Difference between Energy Models and Water Models

`HydroPowerSimulations.jl` allow setting energy targets or hydro budgets in the models formulation. Based on the available data and the desired formulation, the corresponding constraints are added to the [`DeviceModel`](@extref PowerSimulations.DeviceModel).

  - Currently, the following formulations allow setting energy targets:
    
      + [`HydroEnergyModelReservoir`](@ref)
      + [`HydroPumpEnergyDispatch`](@ref)
      + [`HydroTurbineEnergyDispatch`](@ref)

  - The following energy-based models accept passing the [`EnergyBudgetTimeSeriesParameter`](@ref):
    
      + [`HydroDispatchRunOfRiverBudget`](@ref)
      + [`HydroEnergyModelReservoir`](@ref)
  - The following energy-based models accept passing the [`EnergyTargetTimeSeriesParameter`](@ref):
    
      + [`HydroEnergyModelReservoir`](@ref)
  - The following device data models accept passing the [`EnergyBudgetTimeSeriesParameter`](@ref):
    
      + [`HydroGen`](@extref PowerSystems.HydroGen)
      + [`HydroReservoir`](@extref PowerSystems.HydroReservoir)
