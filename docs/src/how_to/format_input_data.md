# [Format input data for different turbine and reservoir models](@id format_data)

Many formulations require to properly specify the data models appropriately to be used correctly in the different available formulations

# Turbine Data

Docstring provide good information on how to include data for turbines.

```@repl data
using PowerSystems
@doc HydroTurbine
```

### Energy Models

Energy models are characterized by their data is specified in power units (MW and per-unit) and energy units (MWh and per-unit-h). For turbines this is usually set-up with providing data in per-unit dependent on its `base_power`. `powerhouse_elevation` and `outflow_limits` are only relevant for water models.

### TimeSeries data

Energy models for turbine such as [`HydroTurbineEnergyDispatch`](@ref) and [`HydroTurbineEnergyCommitment`](@ref) do not require time series input data.

### Water Models

Water models still have their data specified in power units, but the `powerhouse_elevation` must be specified in meters, and `outflow_limits` specified in m³/s, bounds the water flowing through the turbine.

### TimeSeries data

[`HydroTurbineBilinearDispatch`](@ref) and [`HydroWaterFactorModel`](@ref) models for turbine do not require time series input data.

# Reservoir Data

Docstring provide good information on how to include data for reservoirs.

```@repl data
using PowerSystems
@doc HydroReservoir
```

Reservoir store which turbines are upstream and downstream via their `upstream_turbines` and `downstream_turbines` field.

### Energy Models

To specify a reservoir to use data in energy format, on which their inflows/outflows are in MW, and their capacity is in MWh, the user must specify the `level_data_type = ReservoirDataType.ENERGY`. The field `storage_level_limits` must be added in MWh, while the inflow/outflow should be specified in system base per-unit. For example if the system base is 100 MW, and the inflow is 400 MW, then `set_inflow!(reservoir, 4.0)` will be set correctly the multiplier for the inflow timeseries.

### Timeseries data

The [`HydroEnergyModelReservoir`](@ref) can set-up three different timeseries:

  - The `inflow` timeseries is used as a fraction of the `inflow` field to add energy into the reservoir storage at every time step. The term ``\text{inflow} \cdot \text{inflowTimeSeries}_t \cdot \text{resolution in hours} \cdot \text{system basepower}`` represents how much MWh are added per time to the reservoir storage.

  - The `storage_target` timeseries is used as a fraction of the `level_targets • storage_level_limits.max` to include a target at any specified hour. The user must provide a timeseries for every hour, but the constraint is only generated for the last time step of the decision model.
  - The `hydro_budget` timeseries is used as a fraction of the `storage_level_limits.max` to specify an hourly energy budget at any specified hour. The user must provide a timeseries for every hour, but a single constraint is generated for the sum of all time steps of the decision model.

### Water Models

To specify a reservoir data in water format, on which their inflows/outflows are in m³/s, the user must must specify the `level_data_type` as the following options:

  - `ReservoirDataType.HEAD` if the data is provided for the hydraulic head in meters. The `storage_level_limits` must specify the minimum and maximum hydraulic head in meters above the sea level. The `intake_elevation` must be specified in meters, and the `head_to_volume_factor` must be specified to transform the head into the effective available volume for the reservoir in m³.

  - `ReservoirDataType.USABLE_VOLUME` if the data is provided in usable volume in cubic meters. The `storage_level_limits` must specify the minimum and maximum effective volume of the reservoir in cubic meters. Typically the usable volume is relative to the minimum allowed volume in the reservoir, such that that total volume is represented as a zero usable volume. The `intake_elevation` must be specified in meters, and the `head_to_volume_factor` must be specified to transform the effective usable volume for the reservoir in m³ into the absolute hydraulic head in meters.
  - `ReservoirDataType.TOTAL_VOLUME` if the data is provided in usable volume in cubic meters. The `storage_level_limits` must specify the minimum and maximum  volume of the reservoir in cubic meters. The total volume must specify the minimum volume in cubic meters for operation. The `intake_elevation` must be specified in meters, and the `head_to_volume_factor` must be specified to transform the total volume for the reservoir in m³ into the absolute hydraulic head in meters.

The inflow and outflow fields are not necessary to be specified since the mandatory timeseries data must be specified in m³/s.

### Timeseries data

As mentioned, the [`HydroWaterModelReservoir`](@ref) must set-up two different timeseries:

  - The `inflow` timeseries is added in average m³/s external water inflow. The term ``\text{inflowTimeSeries}_t \cdot \text{resolution in hours} \cdot \text{Seconds in 1 hour}`` represents how much m³ are added per time to the reservoir storage.

  - The `inflow` timeseries is added in average m³/s external water outflow. The term ``\text{outflowTimeSeries}_t \cdot \text{resolution in hours} \cdot \text{Seconds in 1 hour}`` represents how much m³ is lost per time to the reservoir storage. It is typically used to represent evaporation or filtration losses.
