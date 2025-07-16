function convert_to_hydropump!(d::EnergyReservoirStorage, sys::System)
    storage_capacity_MWh = d.storage_capacity * d.base_power
    reservoir_cost = HydroReservoirCost(
        level_shortage_cost = d.operation_cost.energy_shortage_cost,
        level_surplus_cost = d.operation_cost.energy_surplus_cost,
        spillage_cost = 0.0,
    )
    head_reservoir = HydroReservoir(
        name = "$(d.name)_head_reservoir",
        available = d.available,
        storage_level_limits = (min = storage_capacity_MWh * d.storage_level_limits.min, max = storage_capacity_MWh * d.storage_level_limits.max),
        initial_level = d.initial_storage_capacity_level,
        spillage_limits = nothing,
        inflow = 0.0,
        outflow = 0.0,
        level_targets = d.storage_target,
        travel_time = nothing,
        intake_elevation = 0.0,
        head_to_volume_factor = 0.0,
        operation_cost = reservoir_cost,
        level_data_type = ReservoirDataType.ENERGY,
    )
    tail_reservoir = HydroReservoir(nothing)
    set_name!(tail_reservoir, "$(d.name)_tail_reservoir")
    hpump = HydroPumpTurbine(
        name = "$(d.name)_pump",
        available = d.available,
        bus = d.bus,
        active_power = d.active_power,
        reactive_power = d.reactive_power,
        rating = d.rating,
        active_power_limits = d.output_active_power_limits,
        reactive_power_limits = d.reactive_power_limits,
        active_power_limits_pump = d.input_active_power_limits,
        outflow_limits = nothing,
        head_reservoir = head_reservoir,
        tail_reservoir = tail_reservoir,
        powerhouse_elevation = 0.0,
        ramp_limits = nothing,
        time_limits = nothing,
        base_power = d.base_power,
        operation_cost = HydroGenerationCost(
            variable = d.operation_cost.discharge_variable_cost,
            fixed = d.operation_cost.fixed,
        ),
        active_power_pump = 0.0,
        efficiency = (turbine = d.efficiency.out, pump = d.efficiency.in),
        prime_mover_type = d.prime_mover_type,
    )
    add_component!(sys, hpump)
    add_component!(sys, head_reservoir)
    add_component!(sys, tail_reservoir)
    for service in PSY.get_services(d)
        PSY.add_service!(hpump, service, sys)
    end    
    copy_time_series!(hpump, d)
end