@testset "HydroDispatch outage" begin
    dates_ts = collect(
        DateTime("2024-01-01T00:00:00"):Hour(1):DateTime("2024-01-02T23:00:00"),
    )
    outage_data = fill!(Vector{Int64}(undef, 48), 0)
    outage_data[10:15] .= 1
    outage_timeseries = TimeArray(dates_ts, outage_data)
    _, res = run_fixed_forced_outage_sim_with_timeseries(;
        sys = build_system(
            PSITestSystems,
            "c_sys5_hy_uc";
            add_single_time_series = true,
            add_forecasts = false,
        ),
        networks = repeat([PSI.CopperPlatePowerModel], 3),
        optimizers = repeat([HiGHS_optimizer], 3),
        outage_status_timeseries = outage_timeseries,
        device_type = HydroDispatch,
        device_names = ["HydroDispatch"],
        renewable_formulation = RenewableFullDispatch,
    )
    em = get_emulation_problem_results(res)
    status = read_realized_variable(
        em,
        "AvailableStatusParameter__HydroDispatch";
        table_format = TableFormat.WIDE,
    )
    ap = read_realized_variable(
        em,
        "ActivePowerVariable__HydroDispatch";
        table_format = TableFormat.WIDE,
    )
    for (ix, x) in enumerate(outage_data[1:24])
        @test x != Int64(status[!, "HydroDispatch"][ix])
        if Int64(status[!, "HydroDispatch"][ix]) == 0.0
            @test ap[!, "HydroDispatch"][ix] == 0.0
        end
    end
end

@testset "HydroTurbine outage" begin
    dates_ts = collect(
        DateTime("2024-01-01T00:00:00"):Hour(1):DateTime("2024-01-02T23:00:00"),
    )
    outage_data = fill!(Vector{Int64}(undef, 48), 0)
    outage_data[10:15] .= 1
    outage_timeseries = TimeArray(dates_ts, outage_data)
    _, res = run_fixed_forced_outage_sim_with_timeseries(;
        sys = build_system(
            PSITestSystems,
            "c_sys5_hy_uc";
            add_single_time_series = true,
            add_forecasts = false,
        ),
        networks = repeat([PSI.CopperPlatePowerModel], 3),
        optimizers = repeat([HiGHS_optimizer], 3),
        outage_status_timeseries = outage_timeseries,
        device_type = HydroTurbine,
        device_names = ["HydroEnergyReservoirTurbine"],
        renewable_formulation = RenewableFullDispatch,
    )
    em = get_emulation_problem_results(res)
    status = read_realized_variable(
        em,
        "AvailableStatusParameter__HydroTurbine";
        table_format = TableFormat.WIDE,
    )
    ap = read_realized_variable(
        em,
        "ActivePowerVariable__HydroTurbine";
        table_format = TableFormat.WIDE,
    )
    for (ix, x) in enumerate(outage_data[1:24])
        @test x != Int64(status[!, "HydroEnergyReservoirTurbine"][ix])
        if Int64(status[!, "HydroEnergyReservoirTurbine"][ix]) == 0.0
            @test ap[!, "HydroEnergyReservoirTurbine"][ix] == 0.0
        end
    end
end

@testset "HydroPumpTurbine outage" begin
    dates_ts = collect(
        DateTime("2024-01-01T00:00:00"):Hour(1):DateTime("2024-01-02T23:00:00"),
    )
    outage_data = fill!(Vector{Int64}(undef, 48), 0)
    outage_data[2:4] .= 1
    outage_timeseries = TimeArray(dates_ts, outage_data)
    sim, res = run_fixed_forced_outage_sim_with_timeseries(;
        sys = build_system(
            PSITestSystems,
            "c_sys5_hydro_pump_energy";
            add_single_time_series = true,
            add_forecasts = false,
        ),
        networks = repeat([PSI.CopperPlatePowerModel], 3),
        optimizers = repeat([HiGHS_optimizer], 3),
        outage_status_timeseries = outage_timeseries,
        device_type = HydroPumpTurbine,
        device_names = ["Bat_pump"],
        renewable_formulation = RenewableFullDispatch,
    )
    # Test outage constraints are built for both ActivePowerVariable and ActivePowerPumpVariable:
    model = first(PSI.get_decision_models(PSI.get_models(sim)))
    event_constraint_keys = [
        PSI.ConstraintKey{PSI.ActivePowerOutageConstraint, HydroPumpTurbine}(""),
        PSI.ConstraintKey{HPS.ActivePowerPumpOutageConstraint, HydroPumpTurbine}(""),
    ]
    psi_constraint_test(model, event_constraint_keys)

    em = get_emulation_problem_results(res)
    status = read_realized_variable(
        em,
        "AvailableStatusParameter__HydroPumpTurbine";
        table_format = TableFormat.WIDE,
    )
    ap = read_realized_variable(
        em,
        "ActivePowerVariable__HydroPumpTurbine";
        table_format = TableFormat.WIDE,
    )
    ap_pump = read_realized_variable(
        em,
        "ActivePowerPumpVariable__HydroPumpTurbine";
        table_format = TableFormat.WIDE,
    )
    # TODO - this test could be improved if the pump variable solution was non-zero without an outage
    for (ix, x) in enumerate(outage_data[1:24])
        @test x != Int64(status[!, "Bat_pump"][ix])
        if Int64(status[!, "Bat_pump"][ix]) == 0.0
            @test ap[!, "Bat_pump"][ix] == 0.0
            @test ap_pump[!, "Bat_pump"][ix] == 0.0
        end
    end
end
