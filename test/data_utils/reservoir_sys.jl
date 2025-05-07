function get_test_reservoir_turbine_sys(modeling_horizon)
    sys_rts = build_system(PSISystems, "modified_RTS_GMLC_DA_sys_noForecast")
    reservoir_data = joinpath(dirname(@__FILE__), "reservoir_data.csv")

    ### Start Creating Structs for 5-bus System ####
    sys = PSB.build_system(PSITestSystems, "c_sys5_hy_ems_ed")
    remove_time_series!(sys, Deterministic)

    solitude = get_component(ThermalStandard, sys, "Solitude")
    alta = get_component(ThermalStandard, sys, "Alta")

    turbine_solitude = HydroTurbine(;
        name = "Solitude",
        available = true,
        bus = get_bus(solitude),
        active_power = 0.0,
        reactive_power = 0.0,
        rating = get_rating(solitude),
        active_power_limits = (min = 0.0, max = solitude.active_power_limits.max),
        reactive_power_limits = get_reactive_power_limits(solitude),
        outflow_limits = nothing,
        ramp_limits = nothing,
        time_limits = nothing,
        base_power = get_base_power(solitude),
        powerhouse_elevation = 0.0,
    )

    turbine_alta = HydroTurbine(;
        name = "Alta",
        available = true,
        bus = get_bus(alta),
        active_power = 0.0,
        reactive_power = 0.0,
        rating = get_rating(alta),
        active_power_limits = (min = 0.0, max = alta.active_power_limits.max),
        reactive_power_limits = get_reactive_power_limits(alta),
        outflow_limits = nothing,
        ramp_limits = nothing,
        time_limits = nothing,
        base_power = get_base_power(solitude),
        powerhouse_elevation = 0.0,
    )

    reservoir = HydroReservoir(;
        name = "Reservoir",
        available = true,
        initial_level = 0.95,
        storage_level_limits = (min = 0.0, max = 1.0), # 0.9
        spillage_limits = nothing,
        inflow = 0.0,
        outflow = 0.0,
        level_targets = 0.15,
        travel_time = nothing,
        head_to_volume_factor = 1.0,
        intake_elevation = 100.0,
    )

    # Add turbines and reservoirs
    add_component!(sys, turbine_solitude)
    add_component!(sys, turbine_alta)
    add_component!(sys, reservoir)

    # Remove Thermals
    remove_component!(sys, get_component(ThermalStandard, sys, "Solitude"))
    remove_component!(sys, get_component(ThermalStandard, sys, "Alta"))

    # Update Reservoir and turbines
    set_reservoirs!(turbine_solitude, [reservoir])
    set_reservoirs!(turbine_alta, [reservoir])

    # Update Reservoir Time Series
    df = CSV.read(reservoir_data, DataFrame)
    inflow_data = df[!, 2][1:364]
    max_volume = maximum(df[!, 3])
    target_volume = 0.95 * max_volume
    PSY.set_storage_level_limits!(reservoir, (min = 0.0, max = max_volume))

    ## Add hourly data into Time Series
    load_rts_names = ["Alber", "Baker", "Carter"]
    load_5bus_names = ["Bus2", "Bus3", "Bus4"]
    for (ix, load_name) in enumerate(load_rts_names)
        load = get_component(PowerLoad, sys_rts, load_name)
        ts_ld = get_time_series_array(
            SingleTimeSeries,
            load,
            "max_active_power";
            ignore_scaling_factors = true,
        )
        tstamps = timestamp(ts_ld)[1:(52 * 24 * 7)] # 52 weeks in a year, 7 days a week, 24 hours in a day
        ld_vals = values(ts_ld)[1:(52 * 24 * 7)]
        ld_new_ts = SingleTimeSeries(;
            name = "max_active_power",
            data = TimeArray(tstamps, ld_vals),
            scaling_factor_multiplier = get_max_active_power,
        )
        load_5bus = get_component(PowerLoad, sys, load_5bus_names[ix])
        add_time_series!(sys, load_5bus, ld_new_ts)
    end
    ## Add hourly data for Renewables
    ren_rts_names = ["122_WIND_1", "303_WIND_1", "309_WIND_1"]
    ren_5bus_names = ["WindBusA", "WindBusB", "WindBusC"]
    for (ix, ren_name) in enumerate(ren_rts_names)
        ren = get_component(RenewableDispatch, sys_rts, ren_name)
        ts_ren = get_time_series_array(
            SingleTimeSeries,
            ren,
            "max_active_power";
            ignore_scaling_factors = true,
        )
        tstamps = timestamp(ts_ren)[1:(52 * 24 * 7)] # 52 weeks in a year, 7 days a week, 24 hours in a day
        ren_vals = values(ts_ren)[1:(52 * 24 * 7)]
        ren_new_ts = SingleTimeSeries(;
            name = "max_active_power",
            data = TimeArray(tstamps, ren_vals),
            scaling_factor_multiplier = get_max_active_power,
        )
        ren_5bus = get_component(RenewableDispatch, sys, ren_5bus_names[ix])
        add_time_series!(sys, ren_5bus, ren_new_ts)
    end

    # Add Hourly Inflow
    load_region1 = get_component(PowerLoad, sys_rts, "Alber")
    ts_ld1 = get_time_series_array(
        SingleTimeSeries,
        load_region1,
        "max_active_power";
        ignore_scaling_factors = true,
    )
    tstamps = timestamp(ts_ld1)[1:(52 * 24 * 7)] # 52 weeks in a year, 7 days a week, 24 hours in a day
    inflow_data_hourly = repeat(inflow_data; inner = 24)
    inflow_hourly_ts =
        SingleTimeSeries(; name = "inflow", data = TimeArray(tstamps, inflow_data_hourly))

    ## Add load time series to 5-bus sys:
    reservoir_hourly = only(get_components(HydroReservoir, sys))
    key = add_time_series!(sys, reservoir_hourly, inflow_hourly_ts)
    set_inflow!(reservoir_hourly, key)

    transform_single_time_series!(sys, Hour(modeling_horizon), Hour(24))
    return sys
end
