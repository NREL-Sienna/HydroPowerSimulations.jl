function new_c_sys5_hyd()
    sys = PSB.build_system(PSITestSystems, "c_sys5_hyd")

    hy_res = first(PSY.get_components(HydroEnergyReservoir, sys))

    turbine_res = HydroTurbine(;
        name = "$(get_name(hy_res))_turbine",
        available = true,
        bus = get_bus(hy_res),
        active_power = 0.0,
        reactive_power = 0.0,
        rating = hy_res.rating,
        active_power_limits = (
            min = hy_res.active_power_limits.min,
            max = hy_res.active_power_limits.max,
        ),
        reactive_power_limits = (
            min = hy_res.reactive_power_limits.min,
            max = hy_res.reactive_power_limits.max,
        ),
        outflow_limits = nothing,
        ramp_limits = nothing,
        time_limits = nothing,
        base_power = 100.0,
        powerhouse_elevation = 0.0,
        operation_cost = get_operation_cost(hy_res),
    )

    reservoir_res = HydroReservoir(;
        name = "$(get_name(hy_res))_reservoir",
        available = true,
        initial_level = hy_res.initial_storage,
        storage_level_limits = (
            min = 0.0,
            max = hy_res.storage_capacity * get_base_power(hy_res),
        ),
        spillage_limits = nothing,
        inflow = hy_res.inflow,
        outflow = 0.0,
        level_targets = hy_res.storage_target,
        travel_time = nothing,
        head_to_volume_factor = 0.0,
        intake_elevation = 0.0,
        level_data_type = PowerSystems.ReservoirDataType.ENERGY,
    )

    add_component!(sys, turbine_res)
    add_component!(sys, reservoir_res)
    set_reservoirs!(turbine_res, [reservoir_res])

    copy_time_series!(reservoir_res, hy_res)
    return sys
end
