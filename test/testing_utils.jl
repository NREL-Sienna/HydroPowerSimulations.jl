function replace_with_hydro_dispatch!(
    sys::PSY.System,
    unit1::PSY.Generator,
)
    hydro = PSY.HydroDispatch(;
        name = "HD1",
        available = true,
        bus = get_bus(unit1),
        active_power = get_active_power(unit1),
        reactive_power = get_reactive_power(unit1),
        rating = get_rating(unit1),
        prime_mover_type = PSY.PrimeMovers.HA,
        active_power_limits = get_active_power_limits(unit1),
        reactive_power_limits = get_reactive_power_limits(unit1),
        ramp_limits = nothing,
        time_limits = nothing,
        base_power = get_base_power(unit1),
        status = true,
        operation_cost = get_operation_cost(unit1),
    )
    add_component!(sys, hydro)
    transfer_mbc!(hydro, unit1, sys)
    remove_component!(sys, unit1)

    # add a max_active_power time series to the component
    load = first(PSY.get_components(PSY.PowerLoad, sys))
    load_ts = get_time_series(Deterministic, load, "max_active_power")
    num_windows = length(get_data(load_ts))
    num_forecast_steps =
        floor(Int, get_horizon(load_ts) / get_interval(load_ts))
    total_steps = num_windows + num_forecast_steps - 1
    dates = range(
        get_initial_timestamp(load_ts);
        step = get_interval(load_ts),
        length = total_steps,
    )
    magnitude = get_active_power_limits(unit1).max
    hydro_data = fill(magnitude, total_steps)
    hydro_ts = SingleTimeSeries("max_active_power", TimeArray(dates, hydro_data))
    add_time_series!(sys, hydro, hydro_ts)
    transform_single_time_series!(
        sys,
        get_horizon(load_ts),
        get_interval(load_ts),
    )

    return hydro
end

# currently unused.
function replace_with_hydro_turbine!(
    sys::PSY.System,
    unit1::PSY.Generator,
)
    hydro = PSY.HydroTurbine(;
        name = "HT1",
        available = true,
        bus = get_bus(unit1),
        active_power = get_active_power(unit1),
        reactive_power = get_reactive_power(unit1),
        rating = get_rating(unit1),
        active_power_limits = get_active_power_limits(unit1),
        reactive_power_limits = get_reactive_power_limits(unit1),
        base_power = get_base_power(unit1),
        operation_cost = get_operation_cost(unit1),
        powerhouse_elevation = 100.0,
    )
    add_component!(sys, hydro)
    transfer_mbc!(hydro, unit1, sys)
    remove_component!(sys, unit1)

    reservoir = PSY.HydroReservoir(;
        name = "R1",
        available = true,
        storage_level_limits = (min = 0.0, max = 100.0),
        initial_level = 50.0,
        inflow = 5.0,
    )
    reservoirs = get_reservoirs(hydro)
    push!(reservoirs, PSY.ReservoirRef("R1"))
    # add a max_active_power time series to the component
    load = first(PSY.get_components(PSY.PowerLoad, sys))
    load_ts = get_time_series(Deterministic, load, "max_active_power")
    num_windows = length(get_data(load_ts))
    num_forecast_steps =
        floor(Int, get_horizon(load_ts) / get_interval(load_ts))
    total_steps = num_windows + num_forecast_steps - 1
    dates = range(
        get_initial_timestamp(load_ts);
        step = get_interval(load_ts),
        length = total_steps,
    )
    magnitude = get_active_power_limits(unit1).max
    hydro_data = fill(magnitude, total_steps)
    hydro_ts = SingleTimeSeries("max_active_power", TimeArray(dates, hydro_data))
    add_time_series!(sys, hydro, hydro_ts)
    transform_single_time_series!(
        sys,
        get_horizon(load_ts),
        get_interval(load_ts),
    )

    # add a reservoir to the hydro turbine
    #=
    res_capacity = 10.0 * magnitude
    reservoir = PSY.Reservoir(;
        name = "R1",
        max_storage = res_capacity,
        min_storage = 0.0,
        initial_storage = 0.5 * res_capacity,
        max_inflow = 2.0 * magnitude,
    )=#
end

# functions for adjusting power/cost curves and manipulating time series
"""Moves inflow time series from each turbine to its upstream reservoir."""
function copy_inflow_time_series!(sys)
    for turb in get_components(HydroTurbine, sys)
        res = only(get_connected_head_reservoirs(sys, turb))
        name_map = Dict((PSY.get_name(turb), "inflow") => "inflow")
        copy_time_series!(res, turb; name_mapping = name_map)
    end
end

function load_sys_hydro()
    sys = load_sys_incr()
    replace_with_hydro_dispatch!(sys, get_component(SEL_INCR, sys))
    hd1 = get_component(PSY.HydroDispatch, sys, "HD1")
    zero_out_startup_shutdown_costs!(hd1)
    # zero_out_thermal_costs!(sys)
    # set the cost at minimum generation to 0.0.
    op_cost = get_operation_cost(hd1)
    old_curve = get_value_curve(get_incremental_offer_curves(op_cost))
    new_curve = PowerSystems.PiecewiseIncrementalCurve(
        0.0,
        get_x_coords(old_curve),
        get_slopes(old_curve),
    )
    set_incremental_offer_curves!(op_cost, CostCurve(new_curve))
    remove_thermal_mbcs!(sys)
    return sys
end

function build_sys_hydro(
    initial_varies::Bool,
    breakpoints_vary::Bool,
    slopes_vary::Bool;
    modify_baseline_pwl = nothing,
    do_override_min_x = true,
    create_extra_tranches = false,
    initial_input_names_vary = false,
    variable_cost_names_vary = false,
)
    sys = load_sys_hydro()
    @assert !initial_varies "Hydro components should have min gen cost of 0.0"

    extend_mbc!(
        sys,
        make_selector(PSY.HydroDispatch, "HD1"), ;
        initial_varies = initial_varies,
        breakpoints_vary = breakpoints_vary,
        slopes_vary = slopes_vary,
        modify_baseline_pwl = modify_baseline_pwl,
        do_override_min_x = do_override_min_x,
        create_extra_tranches = create_extra_tranches,
        initial_input_names_vary = initial_input_names_vary,
        variable_cost_names_vary = variable_cost_names_vary,
    )
    return sys
end
