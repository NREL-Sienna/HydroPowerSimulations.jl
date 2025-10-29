# copy-paste of PSI's test_market_bid_cost.jl
test_path = mktempdir()
const TIME1 = DateTime("2024-01-01T00:00:00")
const SEL_INCR = make_selector(ThermalStandard, "Test Unit1")
const SEL_DECR = make_selector(InterruptiblePowerLoad, "IloadBus4")
const SEL_MULTISTART = make_selector(ThermalMultiStart, "115_STEAM_1")
const DEFAULT_DEVICE_TO_MODEL =
    Dict{Type{<:PSY.Device}, Type{<:PSI.AbstractDeviceFormulation}}(
        ThermalStandard => ThermalBasicUnitCommitment,
        ThermalMultiStart => ThermalMultiStartUnitCommitment,
        PowerLoad => StaticPowerLoad,
        RenewableDispatch => RenewableFullDispatch,
        HydroDispatch => HydroCommitmentRunOfRiver,
    )

function transfer_mbc_time_series!(
    new_comp::PSY.Device,
    old_comp::PSY.Device,
    sys::PSY.System,
)
    mbc = get_operation_cost(old_comp)
    @assert mbc isa PSY.MarketBidCost
    for field in fieldnames(PSY.MarketBidCost)
        val = getfield(mbc, field)
        if val isa IS.TimeSeriesKey
            ts = PSY.get_time_series(old_comp, val)
            add_time_series!(sys, new_comp, ts)
        end
    end
    return
end

"Set the no_load_cost to `nothing` and the initial_input to the old no_load_cost. Not designed for time series"
function no_load_to_initial_input!(comp::Generator)
    cost = get_operation_cost(comp)::MarketBidCost
    no_load = PSY.get_no_load_cost(cost)
    old_fd = get_function_data(
        get_value_curve(get_incremental_offer_curves(get_operation_cost(comp))),
    )::IS.PiecewiseStepData
    new_vc = PiecewiseIncrementalCurve(old_fd, no_load, nothing)
    set_incremental_offer_curves!(get_operation_cost(comp), CostCurve(new_vc))
    set_no_load_cost!(get_operation_cost(comp), nothing)
    return
end

no_load_to_initial_input!(
    sys::PSY.System,
    sel = make_selector(x -> get_operation_cost(x) isa MarketBidCost, Generator),
) = no_load_to_initial_input!.(get_components(sel, sys))

"Set all MBC thermal unit min active powers to their min breakpoints"
function adjust_min_power!(sys)
    for comp in get_components(Union{ThermalStandard, ThermalMultiStart}, sys)
        op_cost = get_operation_cost(comp)
        op_cost isa MarketBidCost || continue
        cost_curve = get_incremental_offer_curves(op_cost)::CostCurve
        baseline = get_value_curve(cost_curve)::PiecewiseIncrementalCurve
        x_coords = get_x_coords(get_function_data(baseline))
        with_units_base(sys, UnitSystem.NATURAL_UNITS) do
            set_active_power_limits!(comp, (min = first(x_coords), max = last(x_coords)))
        end
    end
end

function load_and_fix_system(args...; kwargs...)
    sys = Logging.with_logger(Logging.NullLogger()) do
        build_system(args...; kwargs...)
    end
    no_load_to_initial_input!(sys)
    adjust_min_power!(sys)
    return sys
end

# Layer of indirection to upgrade problem results to look like simulation results
_maybe_upgrade_to_dict(input::AbstractDict) = input
_maybe_upgrade_to_dict(input::DataFrame) =
    SortedDict{DateTime, DataFrame}(first(input[!, :DateTime]) => input)

read_variable_dict(
    res::IS.Results,
    var_name::Type{<:PSI.VariableType},
    comp_type::Type{<:PSY.Component},
) =
    _maybe_upgrade_to_dict(read_variable(res, var_name, comp_type))
read_parameter_dict(
    res::IS.Results,
    par_name::Type{<:PSI.ParameterType},
    comp_type::Type{<:PSY.Component},
) =
    _maybe_upgrade_to_dict(read_parameter(res, par_name, comp_type))

function load_sys_incr()
    # NOTE we are using the fixed one so we can add time series ourselves
    sys = load_and_fix_system(
        PSITestSystems,
        "c_fixed_market_bid_cost",
    )
    tweak_system!(sys, 1.05, 1.0, 1.0)
    get_y_coords(
        get_function_data(
            get_value_curve(
                get_incremental_offer_curves(
                    get_operation_cost(get_component(ThermalStandard, sys, "Test Unit2")),
                ),
            ),
        ),
    )[1] *= 0.9
    return sys
end

function load_sys_decr()
    sys = load_and_fix_system(PSITestSystems, "c_sys5_il")
    return sys
end

"""
Create a system with initial input and variable cost time series. Lots of options:

# Arguments:
  - `initial_varies`: whether the initial input time series should have values that vary
    over time (as opposed to a time series with constant values over time)
  - `breakpoints_vary`: whether the breakpoints in the variable cost time series should vary
    over time
  - `slopes_vary`: whether the slopes of the variable cost time series should vary over time
  - `modify_baseline_pwl`: optional, a function to modify the baseline piecewise linear cost
    `FunctionData` from which the variable cost time series is calculated
  - `do_override_min_x`: whether to override the P1 to be equal to the minimum power in all
    time steps
  - `create_extra_tranches`: whether to create extra tranches in some time steps by
    splitting one tranche into two
  - `active_components`: a `ComponentSelector` specifying which components should get time
    series
  - `initial_input_names_vary`: whether the initial input time series names should vary over
    components
  - `variable_cost_names_vary`: whether the variable cost time series names should vary over
    components
"""
function build_sys_incr(
    initial_varies::Bool,
    breakpoints_vary::Bool,
    slopes_vary::Bool;
    modify_baseline_pwl = nothing,
    do_override_min_x = true,
    create_extra_tranches = false,
    active_components = SEL_INCR,
    initial_input_names_vary = false,
    variable_cost_names_vary = false,
)
    sys = load_sys_incr()
    extend_mbc!(
        sys,
        active_components;
        initial_varies = initial_varies,
        breakpoints_vary = breakpoints_vary,
        slopes_vary = slopes_vary,
        initial_input_names_vary = initial_input_names_vary,
        variable_cost_names_vary = variable_cost_names_vary,
    )
    return sys
end

_read_one_value(res, var_name, gentype, unit_name) =
    combine(
        vcat(values(read_variable_dict(res, var_name, gentype))...),
        unit_name .=> sum,
    )[
        1,
        1,
    ]

function build_generic_mbc_model(sys::System;
    multistart::Bool = false,
    device_to_model::Dict{Type{<:PSY.Device}, Type{<:PSI.AbstractDeviceFormulation}} =
    Dict{Type{<:PSY.Device}, Type{<:PSI.AbstractDeviceFormulation}}(),
)
    template = ProblemTemplate(
        NetworkModel(
            CopperPlatePowerModel;
            duals = [CopperPlateBalanceConstraint],
        ),
    )
    for (device, model) in device_to_model
        if !isempty(get_components(device, sys))
            set_device_model!(template, device, model)
        end
    end
    for (device, model) in DEFAULT_DEVICE_TO_MODEL
        if !haskey(device_to_model, device) &&
           !isempty(get_components(device, sys))
            set_device_model!(template, device, model)
        end
    end
    model = DecisionModel(
        template,
        sys;
        name = "UC",
        store_variable_names = true,
        optimizer = HiGHS_optimizer,
        system_to_file = false,
    )
    return model
end

function run_generic_mbc_prob(sys::System;
    device_to_model = Dict{Type{<:PSY.Device}, Type{<:PSI.AbstractDeviceFormulation}}(),
    multistart::Bool = false,
    test_success = true,
)
    model = build_generic_mbc_model(
        sys;
        device_to_model = device_to_model,
        multistart = multistart,
    )
    build_result = build!(model; output_dir = test_path)
    test_success && @test build_result == PSI.ModelBuildStatus.BUILT
    solve_result = solve!(model)
    test_success && @test solve_result == PSI.RunStatus.SUCCESSFULLY_FINALIZED
    res = OptimizationProblemResults(model)
    return model, res
end

function run_generic_mbc_sim(sys::System;
    device_to_model = Dict{Type{<:PSY.Device}, Type{<:PSI.AbstractDeviceFormulation}}(),
    multistart::Bool = false,
)
    model = build_generic_mbc_model(
        sys;
        device_to_model = device_to_model,
        multistart = multistart,
    )
    models = SimulationModels(;
        decision_models = [
            model,
        ],
    )
    sequence = SimulationSequence(;
        models = models,
        feedforwards = Dict(
        ),
        ini_cond_chronology = InterProblemChronology(),
    )

    sim = Simulation(;
        name = "compact_sim",
        steps = 2,
        models = models,
        sequence = sequence,
        initial_time = TIME1,
        simulation_folder = mktempdir(),
    )

    build!(sim; serialize = false)
    execute!(sim; enable_progress_bar = true)

    sim_res = SimulationResults(sim)
    res = get_decision_problem_results(sim_res, "UC")
    return model, res
end

"""
Run a simple simulation with the system and return information useful for testing
time-varying startup and shutdown functionality. Pass `simulation = false` to use a single
decision model, `true` for a full simulation.
"""
function run_startup_shutdown_test(sys::System; multistart::Bool = false, simulation = true)
    model, res = if simulation
        run_generic_mbc_sim(sys; multistart = multistart)
    else
        run_generic_mbc_prob(sys; multistart = multistart)
    end

    # Test correctness of written shutdown cost parameters
    # TODO test startup too once we are able to write those
    gentype = multistart ? ThermalMultiStart : ThermalStandard
    genname = multistart ? "115_STEAM_1" : "Test Unit1"
    sh_param = read_parameter_dict(res, PSI.ShutdownCostParameter, gentype)
    for (step_dt, step_df) in pairs(sh_param)
        for gen_name in names(DataFrames.select(step_df, Not(:DateTime)))
            comp = get_component(gentype, sys, gen_name)
            fc_comp =
                get_shut_down(comp, PSY.get_operation_cost(comp); start_time = step_dt)
            @test all(step_df[!, :DateTime] .== TimeSeries.timestamp(fc_comp))
            @test all(isapprox.(step_df[!, gen_name], TimeSeries.values(fc_comp)))
        end
    end

    decisions = if multistart
        (
            _read_one_value(res, PSI.HotStartVariable, gentype, genname),
            _read_one_value(res, PSI.WarmStartVariable, gentype, genname),
            _read_one_value(res, PSI.ColdStartVariable, gentype, genname),
            _read_one_value(res, PSI.StopVariable, gentype, genname),
        )
    else
        (
            _read_one_value(res, PSI.StartVariable, gentype, genname),
            _read_one_value(res, PSI.StopVariable, gentype, genname),
        )
    end
    return model, res, decisions
end

"""
Run a simple simulation with the system and return information useful for testing
time-varying startup and shutdown functionality.  Pass `simulation = false` to use a single
decision model, `true` for a full simulation.
"""
function run_mbc_sim(sys::System; is_decremental::Bool = false, simulation = true)
    model, res = if simulation
        run_generic_mbc_sim(sys)
    else
        run_generic_mbc_prob(sys)
    end

    # TODO test slopes, breakpoints too once we are able to write those
    ii_param = read_parameter_dict(res, PSI.IncrementalCostAtMinParameter, ThermalStandard)
    for (step_dt, step_df) in pairs(ii_param)
        for gen_name in names(DataFrames.select(step_df, Not(:DateTime)))
            comp = get_component(ThermalStandard, sys, gen_name)
            ii_comp = get_incremental_initial_input(
                comp,
                PSY.get_operation_cost(comp);
                start_time = step_dt,
            )
            @test all(step_df[!, :DateTime] .== TimeSeries.timestamp(ii_comp))
            @test all(isapprox.(step_df[!, gen_name], TimeSeries.values(ii_comp)))
        end
    end

    # NOTE this could be rewritten nicely using PowerAnalytics
    comp = get_component(is_decremental ? SEL_DECR : SEL_INCR, sys)
    gentype, genname = typeof(comp), get_name(comp)
    decisions = (
        _read_one_value(res, PSI.OnVariable, gentype, genname),
        _read_one_value(res, PSI.ActivePowerVariable, gentype, genname),
    )
    return model, res, decisions
end

"Read the relevant startup variables: no multistart case"
_read_start_vars(::Val{false}, res::IS.Results) =
    read_variable_dict(res, PSI.StartVariable, ThermalStandard)

"Read the relevant startup variables: yes multistart case"
function _read_start_vars(::Val{true}, res::IS.Results)
    hot_vars =
        read_variable_dict(res, PSI.HotStartVariable, ThermalMultiStart)
    warm_vars =
        read_variable_dict(res, PSI.WarmStartVariable, ThermalMultiStart)
    cold_vars =
        read_variable_dict(res, PSI.ColdStartVariable, ThermalMultiStart)

    @assert all(keys(hot_vars) .== keys(warm_vars))
    @assert all(keys(hot_vars) .== keys(cold_vars))
    @assert all(
        all(hot_vars[k][!, :DateTime] .== warm_vars[k][!, :DateTime]) for
        k in keys(hot_vars)
    )
    @assert all(
        all(hot_vars[k][!, :DateTime] .== cold_vars[k][!, :DateTime]) for
        k in keys(hot_vars)
    )
    # Make a dictionary of combined dataframes where the entries are (hot, warm, cold)
    combined_vars = Dict(
        k => DataFrame(
            "DateTime" => hot_vars[k][!, :DateTime],
            [
                gen_name => [
                    (hot, warm, cold) for (hot, warm, cold) in zip(
                        hot_vars[k][!, gen_name],
                        warm_vars[k][!, gen_name],
                        cold_vars[k][!, gen_name],
                    )
                ] for gen_name in names(select(hot_vars[k], Not(:DateTime)))
            ]...,
        ) for k in keys(hot_vars)
    )
    return combined_vars
end

"""
Read startup and shutdown cost time series from a `System` and multiply by relevant start
and stop variables in the `IS.Results` to determine the cost that should have been incurred
by time-varying `MarketBidCost` startup and shutdown costs. Must run separately for
multistart vs. not.
"""
function cost_due_to_time_varying_startup_shutdown(
    sys::System,
    res::IS.Results;
    multistart = false,
)
    gentype = multistart ? ThermalMultiStart : ThermalStandard
    start_vars = _read_start_vars(Val(multistart), res)
    stop_vars = read_variable_dict(res, PSI.StopVariable, gentype)
    result = SortedDict{DateTime, DataFrame}()
    @assert all(keys(start_vars) .== keys(stop_vars))  # doesn't work with IS.@assert_op
    for step_dt in keys(start_vars)
        start_df = start_vars[step_dt]
        stop_df = stop_vars[step_dt]
        @assert names(start_df) == names(stop_df)
        @assert start_df[!, :DateTime] == stop_df[!, :DateTime]
        result[step_dt] = DataFrame(:DateTime => start_df[!, :DateTime])
        for gen_name in names(DataFrames.select(start_df, Not(:DateTime)))
            comp = get_component(gentype, sys, gen_name)
            cost = PSY.get_operation_cost(comp)
            (cost isa PSY.MarketBidCost) || continue
            PSI.is_time_variant(get_start_up(cost)) || continue
            @assert PSI.is_time_variant(get_shut_down(cost))
            startup_ts = get_start_up(comp, cost; start_time = step_dt)
            shutdown_ts = get_shut_down(comp, cost; start_time = step_dt)

            @assert all(start_df[!, :DateTime] .== TimeSeries.timestamp(startup_ts))
            @assert all(start_df[!, :DateTime] .== TimeSeries.timestamp(shutdown_ts))
            startup_values = if multistart
                TimeSeries.values(startup_ts)
            else
                getproperty.(TimeSeries.values(startup_ts), :hot)
            end
            result[step_dt][!, gen_name] =
                LinearAlgebra.dot.(start_df[!, gen_name], startup_values) .+
                stop_df[!, gen_name] .* TimeSeries.values(shutdown_ts)
        end
    end
    return result
end

function cost_due_to_time_varying_mbc(
    sys::System,
    res::IS.Results;
    is_decremental = false,
)
    is_decremental && throw(IS.NotImplementedError("TODO implement for decremental"))
    gentype = ThermalStandard
    on_vars = read_variable_dict(res, PSI.OnVariable, gentype)
    power_vars = read_variable_dict(res, PSI.ActivePowerVariable, gentype)
    result = SortedDict{DateTime, DataFrame}()
    @assert all(keys(on_vars) .== keys(power_vars))
    for step_dt in keys(on_vars)
        on_df = on_vars[step_dt]
        power_df = power_vars[step_dt]
        @assert names(on_df) == names(power_df)
        @assert on_df[!, :DateTime] == power_df[!, :DateTime]
        result[step_dt] = DataFrame(:DateTime => on_df[!, :DateTime])
        for gen_name in names(DataFrames.select(on_df, Not(:DateTime)))
            comp = get_component(gentype, sys, gen_name)
            cost = PSY.get_operation_cost(comp)
            (cost isa MarketBidCost) || continue
            result[step_dt][!, gen_name] .= 0.0
            if PSI.is_time_variant(get_incremental_initial_input(cost))
                ii_ts = get_incremental_initial_input(comp, cost; start_time = step_dt)
                @assert all(on_df[!, :DateTime] .== TimeSeries.timestamp(ii_ts))
                result[step_dt][!, gen_name] .+=
                    on_df[!, gen_name] .* TimeSeries.values(ii_ts)
            end
            # TODO decremental
            if PSI.is_time_variant(get_incremental_offer_curves(cost))
                vc_ts = get_incremental_offer_curves(comp, cost; start_time = step_dt)
                @assert all(power_df[!, :DateTime] .== TimeSeries.timestamp(vc_ts))
                result[step_dt][!, gen_name] .+=
                    _calc_pwi_cost.(power_df[!, gen_name], TimeSeries.values(vc_ts))
            end
        end
    end
    return result
end

"""
Helper function to tweak load powers, non-MBC generator powers, and non-MBC generator costs
to exercise the generators we want to test.

Multiplies {} for {} by {}:
- max active power, all loads, load_pow_mult
- active power limits, non-MBC ThermalStandard, therm_pow_mult
- operational costs, non-MBC ThermalStandard, therm_price_mult
"""
function tweak_system!(sys::System, load_pow_mult, therm_pow_mult, therm_price_mult)
    for load in get_components(PowerLoad, sys)
        set_max_active_power!(load, get_max_active_power(load) * load_pow_mult)
    end
    # replace with type of component?
    for therm in get_components(ThermalStandard, sys)
        op_cost = get_operation_cost(therm)
        op_cost isa MarketBidCost && continue
        with_units_base(sys, UnitSystem.DEVICE_BASE) do
            old_limits = get_active_power_limits(therm)
            new_limits = (min = old_limits.min, max = old_limits.max * therm_pow_mult)
            set_active_power_limits!(therm, new_limits)
        end
        prop = get_proportional_term(get_value_curve(get_variable(op_cost)))
        set_variable!(op_cost, CostCurve(LinearCurve(prop * therm_price_mult)))
    end
end

# See run_startup_shutdown_obj_fun_test for explanation
function _obj_fun_test_helper(ground_truth_1, ground_truth_2, res1, res2)
    @assert all(keys(ground_truth_1) .== keys(ground_truth_2))

    # Sum across components, time periods to get one value per step
    total1 = [
        only(sum(eachcol(combine(val, Not(:DateTime) .=> sum)))) for
        val in values(ground_truth_1)
    ]
    total2 = [
        only(sum(eachcol(combine(val, Not(:DateTime) .=> sum)))) for
        val in values(ground_truth_2)
    ]
    ground_truth_diff = total2 .- total1  # How much did the cost increase between simulation 1 and simulation 2 for each step

    obj1 = PSI.read_optimizer_stats(res1)[!, "objective_value"]
    obj2 = PSI.read_optimizer_stats(res2)[!, "objective_value"]
    obj_diff = obj2 .- obj1

    # Make sure there is some real difference between the two scenarios
    @assert !any(isapprox.(ground_truth_diff, 0.0; atol = 0.0001))
    # Make sure the difference is reflected correctly in the objective value
    @test all(isapprox.(obj_diff, ground_truth_diff; atol = 0.0001))
end

"""
The methodology here is: run a model or simulation where the startup and shutdown time
series have constant values through time, then run a nearly identical model/simulation where
the values vary very slightly through time, not enough to affect the decisions but enough to
affect the objective value, then compare the size of the objective value change to an
expectation computed manually.

Pass `simulation = false` to use a single decision model, `true` for a full simulation.
"""
function run_startup_shutdown_obj_fun_test(
    sys1,
    sys2;
    multistart::Bool = false,
    simulation = true,
)
    _, res1, decisions1 =
        run_startup_shutdown_test(sys1; multistart = multistart, simulation = simulation)
    _, res2, decisions2 =
        run_startup_shutdown_test(sys2; multistart = multistart, simulation = simulation)

    ground_truth_1 =
        cost_due_to_time_varying_startup_shutdown(sys1, res1; multistart = multistart)
    ground_truth_2 =
        cost_due_to_time_varying_startup_shutdown(sys2, res2; multistart = multistart)

    _obj_fun_test_helper(ground_truth_1, ground_truth_2, res1, res2)
    return decisions1, decisions2
end

# See run_startup_shutdown_obj_fun_test for explanation
function run_mbc_obj_fun_test(sys1, sys2; is_decremental::Bool = false, simulation = true)
    _, res1, decisions1 =
        run_mbc_sim(sys1; is_decremental = is_decremental, simulation = simulation)
    _, res2, decisions2 =
        run_mbc_sim(sys2; is_decremental = is_decremental, simulation = simulation)

    ground_truth_1 =
        cost_due_to_time_varying_mbc(sys1, res1; is_decremental = is_decremental)
    ground_truth_2 =
        cost_due_to_time_varying_mbc(sys2, res2; is_decremental = is_decremental)

    _obj_fun_test_helper(ground_truth_1, ground_truth_2, res1, res2)
    return decisions1, decisions2
end

function tweak_for_startup_shutdown!(sys::System)
    tweak_system!(sys::System, 0.8, 1.0, 1.0)
end

function _calc_pwi_cost(active_power::Float64, pwi::PiecewiseStepData)
    isapprox(active_power, 0.0) && return 0.0
    breakpoints = get_x_coords(pwi)
    slopes = get_y_coords(pwi)
    @assert active_power >= first(breakpoints) && active_power <= last(breakpoints)
    i_leq = findlast(<=(active_power), breakpoints)
    cost =
        sum(slopes[1:(i_leq - 1)] .* (breakpoints[2:i_leq] .- breakpoints[1:(i_leq - 1)]))
    (active_power > breakpoints[i_leq]) &&
        (cost += slopes[i_leq] * (active_power - breakpoints[i_leq]))
    return cost
end

"Test that the two systems (typically one without time series and one with constant time series) simulate the same"
function test_generic_mbc_equivalence(sys0, sys1; kwargs...)
    for runner in (run_generic_mbc_prob, run_generic_mbc_sim)  # test with both a single problem and a full simulation
        _, res0 = runner(sys0; kwargs...)
        _, res1 = runner(sys1; kwargs...)
        obj_val_0 = PSI.read_optimizer_stats(res0)[!, "objective_value"]
        obj_val_1 = PSI.read_optimizer_stats(res1)[!, "objective_value"]
        @test isapprox(obj_val_0, obj_val_1; atol = 0.0001)
    end
end

approx_geq_1(x; kwargs...) = (x >= 1.0) || isapprox(x, 1.0; kwargs...)

# end copy-paste from PSI's test_market_bid_cost.jl

function replace_with_hydro_dispatch!(
    sys::PSY.System,
    unit1::PSY.Generator;
    magnitude::Float64 = 1.0,
    random_variation::Float64 = 0.1,
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
    transfer_mbc_time_series!(hydro, unit1, sys)
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
    hydro_data = magnitude .* ones(total_steps) .+ random_variation .* rand(total_steps)
    hydro_ts = SingleTimeSeries("max_active_power", TimeArray(dates, hydro_data))
    add_time_series!(sys, hydro, hydro_ts)
    transform_single_time_series!(
        sys,
        get_horizon(load_ts),
        get_interval(load_ts),
    )

    return hydro
end

function replace_with_hydro_turbine!(
    sys::PSY.System,
    unit1::PSY.Generator;
    magnitude::Float64 = 1.0,
    random_variation::Float64 = 0.1,
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
    transfer_mbc_time_series!(hydro, unit1, sys)
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
    hydro_data = magnitude .* ones(total_steps) .+ random_variation .* rand(total_steps)
    hydro_ts = SingleTimeSeries("max_active_power", TimeArray(dates, hydro_data))
    add_time_series!(sys, hydro, hydro_ts)
    transform_single_time_series!(
        sys,
        get_horizon(load_ts),
        get_interval(load_ts),
    )

    # add a reservoir to the hydro turbine
    res_capacity = 10.0 * magnitude
    reservoir = PSY.Reservoir(;
        name = "R1",
        max_storage = res_capacity,
        min_storage = 0.0,
        initial_storage = 0.5 * res_capacity,
        max_inflow = 2.0 * magnitude,
    )
end

@testset "MBC HydroDispatch: no time series versus constant time series" begin
    sys_no_ts = load_sys_incr()
    sys_constant_ts = build_sys_incr(false, false, false)
    for sys in (sys_no_ts, sys_constant_ts)
        unit1 = get_component(SEL_INCR, sys)
        replace_with_hydro_dispatch!(sys, unit1; magnitude = 2.0, random_variation = 0.2)
    end
    test_generic_mbc_equivalence(sys_no_ts, sys_constant_ts)
end

function copy_inflow_time_series!(sys)
    for turb in get_components(HydroTurbine, sys)
        res = only(get_connected_head_reservoirs(sys, turb))
        name_map = Dict((PSY.get_name(turb), "inflow") => "inflow")
        copy_time_series!(res, turb; name_mapping = name_map)
    end
end

@testset "MBC HydroTurbine: no time series" begin
    device_to_model = Dict{Type{<:PSY.Device}, Type{<:PSI.AbstractDeviceFormulation}}(
        PSY.HydroTurbine => HydroTurbineEnergyCommitment,
        PSY.HydroReservoir => HydroEnergyModelReservoir,
    )
    sys = build_system(PSITestSystems, "test_RTS_GMLC_sys"; force_build = true)
    # replace cost data at HydroTurbine with MarketBidCost
    ht1 = first(get_components(PSY.HydroTurbine, sys))
    incr_slopes = [0.3, 0.5, 0.7]
    x_coords = [0.1, 0.3, 0.6, 1.0]
    val_at_zero = 0.1
    initial_input = 0.2
    incr_curve = CostCurve(
        PiecewiseIncrementalCurve(val_at_zero, initial_input, x_coords, incr_slopes),
    )
    set_operation_cost!(
        ht1,
        MarketBidCost(;
            no_load_cost = 0.0,
            start_up = (hot = 0.0, warm = 0.0, cold = 0.0),
            shut_down = 0.0,
            incremental_offer_curves = incr_curve,
        ),
    )
    # RTS GMLC has the inflow time series attached to the HydroTurbine, but we need it on the reservoir.
    copy_inflow_time_series!(sys)
    # this takes about a minute, rather long for a test case.. is there a smaller system that works?
    run_generic_mbc_prob(sys; device_to_model = device_to_model)
end

@testset "MBC HydroTurbine: no time series versus constant time series" begin
    device_to_model = Dict{Type{<:PSY.Device}, Type{<:PSI.AbstractDeviceFormulation}}(
        PSY.HydroTurbine => HydroTurbineEnergyCommitment,
    )
    # option 1: use this system, and figure out how to add time series for reservoir and hydro unit.
    # option 2: use RTS GMLC system, and figure out how to add time-varying MarketBidCost to hydro unit.

    sys = build_system(PSITestSystems, "test_RTS_GMLC_sys"; force_build = true)
    copy_inflow_time_series!(sys)
    # easier to first attach a single MBC
    ht1 = first(get_components(PSY.HydroTurbine, sys))
    selector = make_selector(PSY.HydroTurbine, get_name(ht1))
    add_mbc!(sys,
        selector,
    )
    extend_mbc!(
        sys,
        selector;
        initial_varies = false,
        breakpoints_vary = false,
        slopes_vary = false,
        initial_input_names_vary = false,
        variable_cost_names_vary = false,
    )
    # can't run simulation bc interval is 0: only 1 day of data.
    # run_generic_mbc_sim(sys; device_to_model = device_to_model)
    run_generic_mbc_prob(sys; device_to_model = device_to_model)
end
