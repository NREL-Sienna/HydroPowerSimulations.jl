function _make_deterministic_ts(
    name::String,
    ini_val::Union{Number, Tuple},
    res_incr::Number,
    interval_incr::Number,
    init_time::DateTime,
    horizon::TimePeriod,
    interval::TimePeriod,
    window_count::Int,
    resolution::TimePeriod,
)
    horizon_count = IS.get_horizon_count(horizon, resolution)
    ts_data = OrderedDict{DateTime, Vector{Float64}}()
    for i in 0:(window_count - 1)
        series = ini_val .+ res_incr .* (0:(horizon_count - 1)) .+ i * interval_incr
        ts_data[init_time + i * interval] = series
    end
    return Deterministic(;
        name = name,
        data = ts_data,
        resolution = resolution,
        interval = interval,
    )
end

__initial_time(ts::DeterministicSingleTimeSeries) = IS.get_initial_timestamp(ts)
__initial_time(ts::Deterministic) = first(IS.get_initial_times(ts))

"""
Create a deterministic time series as above, with the same horizon, count, and interval as an existing time series.
"""
function _make_deterministic_ts(
    name::String,
    ini_val::Union{Number, Tuple},
    res_incr::Number,
    interval_incr::Number,
    model_ts::Union{DeterministicSingleTimeSeries, Deterministic},
)
    return _make_deterministic_ts(
        name,
        ini_val,
        res_incr,
        interval_incr,
        __initial_time(model_ts),
        IS.get_horizon(model_ts),
        IS.get_interval(model_ts),
        IS.get_count(model_ts),
        IS.get_resolution(model_ts),
    )
end

"""
Create a deterministic time series with increments to the initial values, breakpoints, and slopes.
Here, the elements of `incrs_x` and `incrs_y` are tuples of three values, corresponding to:

`tranche_incr`: increment between tranche breakpoints.
`res_incr`: increment within the forecast horizon window.
`interval_incr`: increment in baseline, between horizon windows.

`override_min_x`: if provided, overrides the minimum x value in all piecewise curves.
`create_extra_tranches`: if true, split the first tranche of the first timestep into two;
                                split the last tranche of the last timestep of into three.
"""
function _make_deterministic_ts(
    name::String,
    ini_val::PiecewiseStepData,
    incrs_x::NTuple{3, Float64},
    incrs_y::NTuple{3, Float64},
    init_time::DateTime,
    horizon::TimePeriod,
    interval::TimePeriod,
    count::Int,
    resolution::TimePeriod;
    override_min_x = nothing,
    create_extra_tranches = false,
)
    (tranche_incr_x, res_incr_x, interval_incr_x) = incrs_x
    (tranche_incr_y, res_incr_y, interval_incr_y) = incrs_y

    horizon_count = IS.get_horizon_count(horizon, resolution)

    # Perturb the baseline curves by the tranche increments
    xs1, ys1 = deepcopy(get_x_coords(ini_val)), deepcopy(get_y_coords(ini_val))
    xs1 .+= [i * tranche_incr_x for i in 0:(length(xs1) - 1)]
    ys1 .+= [i * tranche_incr_y for i in 0:(length(ys1) - 1)]

    ts_data = OrderedDict{DateTime, Vector{PiecewiseStepData}}()
    for i in 0:(count - 1)
        xs = [deepcopy(xs1) .+ i * interval_incr_x for _ in 1:horizon_count]
        ys = [deepcopy(ys1) .+ i * interval_incr_y for _ in 1:horizon_count]
        for j in 1:horizon_count
            xs[j] .+= (j - 1) * res_incr_x
            ys[j] .+= (j - 1) * res_incr_y
        end
        if !isnothing(override_min_x)
            for j in 1:horizon_count
                xs[j][1] = override_min_x
            end
        end
        if i == 0 && create_extra_tranches
            xs[1] = [xs[1][1], (xs[1][1] + xs[1][2]) / 2, xs[1][2:end]...]
            ys[1] = [ys[1][1], ys[1][1], ys[1][2:end]...]
        elseif i == count - 1 && create_extra_tranches
            xs[end] = [
                xs[end][1:(end - 1)]...,
                (2 * xs[end][end - 1] + xs[end][end]) / 3,
                (xs[end][end - 1] + 2 * xs[end][end]) / 3,
                xs[end][end],
            ]
            ys[end] = [ys[end][1:(end - 1)]..., ys[end][end], ys[end][end], ys[end][end]]
        end
        ts_data[init_time + i * interval] = PiecewiseStepData.(xs, ys)
    end

    return Deterministic(;
        name = name,
        data = ts_data,
        resolution = resolution,
        interval = interval,
    )
end

"""
Create a deterministic time series as above, with the same horizon, count, and interval as an existing time series.
"""
function _make_deterministic_ts(
    name::String,
    ini_val::PiecewiseStepData,
    incrs_x::NTuple{3, Float64},
    incrs_y::NTuple{3, Float64},
    model_ts::Union{DeterministicSingleTimeSeries, Deterministic};
    override_min_x = nothing,
    create_extra_tranches = false,
)
    return _make_deterministic_ts(
        name,
        ini_val,
        incrs_x,
        incrs_y,
        __initial_time(model_ts),
        IS.get_horizon(model_ts),
        IS.get_interval(model_ts),
        IS.get_count(model_ts),
        IS.get_resolution(model_ts);
        override_min_x = override_min_x,
        create_extra_tranches = create_extra_tranches,
    )
end

function get_deterministic_ts(sys::PSY.System)
    for device in get_components(PSY.Device, sys)
        if has_time_series(device, Union{DeterministicSingleTimeSeries, Deterministic})
            for key in PSY.get_time_series_keys(device)
                ts = get_time_series(device, key)
                if ts isa DeterministicSingleTimeSeries || ts isa Deterministic
                    return ts
                end
            end
        end
    end
    @assert false "No Deterministic or DeterministicSingleTimeSeries found in system"
    return DeterministicSingleTimeSeries(nothing)
end

"""
Extend the MarketBidCost objects attached to the selected components such that they're determined by a time series.

# Arguments:
  - `initial_varies`: whether the initial input time series should have values that vary
    over time (as opposed to a time series with constant values over time)
  - `breakpoints_vary`: whether the breakpoints in the variable cost time series should vary
    over time
  - `slopes_vary`: whether the slopes of the variable cost time series should vary over time
  - `active_components`: a `ComponentSelector` specifying which components should get time
    series
  - `initial_input_names_vary`: whether the initial input time series names should vary over
    components
  - `variable_cost_names_vary`: whether the variable cost time series names should vary over
    components
"""
function extend_mbc!(
    sys::PSY.System,
    active_components::ComponentSelector;
    initial_varies::Bool = false,
    breakpoints_vary::Bool = false,
    slopes_vary::Bool = false,
    initial_input_names_vary::Bool = false,
    variable_cost_names_vary::Bool = false)
    @assert !isempty(get_components(active_components, sys)) "No components selected"
    # grab some Deterministic time series, so we know the horizon, count, and interval
    model_ts = get_deterministic_ts(sys)
    # TODO make this work with deterministic.
    # I really just need: horizon, count, interval, resolution, init_time.
    # looks like there's enough to make it work.
    for comp in get_components(active_components, sys)
        # extract the function data from the component
        # component -> op cost -> cost curve -> value curve -> function data
        op_cost = get_operation_cost(comp)
        @assert op_cost isa MarketBidCost
        cost_curve = get_incremental_offer_curves(op_cost)::CostCurve
        baseline = get_value_curve(cost_curve)::PiecewiseIncrementalCurve
        baseline_initial = get_initial_input(baseline)
        baseline_pwl = get_function_data(baseline)

        # primes for easier attribution
        incr_initial = initial_varies ? (0.11, 0.05) : (0.0, 0.0)
        incr_x = breakpoints_vary ? (0.02, 0.07, 0.03) : (0.0, 0.0, 0.0)
        incr_y = slopes_vary ? (0.02, 0.07, 0.03) : (0.0, 0.0, 0.0)

        name_modifier = "_$(replace(get_name(comp), " " => "_"))_"
        # this might have the wrong number of time steps, if system already has time series.
        my_initial_ts = _make_deterministic_ts(
            "initial_input" * (initial_input_names_vary ? name_modifier : ""),
            baseline_initial,
            incr_initial...,
            model_ts,
        )
        my_pwl_ts = _make_deterministic_ts(
            "variable_cost" * (variable_cost_names_vary ? name_modifier : ""),
            baseline_pwl,
            incr_x,
            incr_y,
            model_ts,
        )
        set_incremental_initial_input!(sys, comp, my_initial_ts)
        set_variable_cost!(sys, comp, my_pwl_ts, get_power_units(cost_curve))
    end
end

function add_mbc!(
    sys::PSY.System,
    active_components::ComponentSelector,
)
    incr_slopes = [0.3, 0.5, 0.7]
    x_coords = [0.1, 0.3, 0.6, 1.0]
    val_at_zero = 0.1
    initial_input = 0.2
    incr_curve = CostCurve(
        PiecewiseIncrementalCurve(val_at_zero, initial_input, x_coords, incr_slopes),
    )
    mbc = MarketBidCost(;
        no_load_cost = 0.0,
        start_up = (hot = 0.0, warm = 0.0, cold = 0.0),
        shut_down = 0.0,
        incremental_offer_curves = incr_curve,
    )
    for comp in get_components(active_components, sys)
        set_operation_cost!(comp, mbc)
    end
end
