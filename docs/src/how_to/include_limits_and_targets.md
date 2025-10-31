

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