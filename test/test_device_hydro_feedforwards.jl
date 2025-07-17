@testset "Test HydroUsageLimitFeedforward with HydroDispatch" begin
    sys = new_c_sys5_hyd_dispatch(; with_reserves = true)
    sys_ed = deepcopy(sys)

    for s in [sys, sys_ed]
        regup = first(get_components(VariableReserve{ReserveUp}, s))
        regdn = first(get_components(VariableReserve{ReserveDown}, s))
        set_deployed_fraction!(regup, 0.4)
        set_requirement!(regup, 0.1)
        set_deployed_fraction!(regdn, 0.3)
        set_requirement!(regdn, 0.1)
    end

    template = ProblemTemplate(NetworkModel(CopperPlatePowerModel))
    set_device_model!(template, ThermalStandard, ThermalDispatchNoMin)
    set_device_model!(template, PowerLoad, StaticPowerLoad)
    set_device_model!(template, HydroDispatch, HydroDispatchRunOfRiver)
    set_service_model!(template, VariableReserve{ReserveUp}, RangeReserve)
    set_service_model!(template, VariableReserve{ReserveDown}, RangeReserve)

    template_ed = ProblemTemplate(NetworkModel(CopperPlatePowerModel))
    set_device_model!(template_ed, ThermalStandard, ThermalDispatchNoMin)
    set_device_model!(template_ed, PowerLoad, StaticPowerLoad)
    set_device_model!(template_ed, HydroDispatch, HydroDispatchRunOfRiver)
    set_service_model!(template_ed, VariableReserve{ReserveUp}, RangeReserve)
    set_service_model!(template_ed, VariableReserve{ReserveDown}, RangeReserve)

    for hydro in get_components(HydroDispatch, sys)
        op_cost = get_operation_cost(hydro)
        new_opcost = HydroGenerationCost(;
            variable = CostCurve(;
                # make hydro expensive in UC to limit usage
                # keep hydro cheap in ED
                value_curve = LinearCurve(
                    16.0,
                    0.0,
                ),
                power_units = UnitSystem.NATURAL_UNITS,
            ),
            fixed = op_cost.fixed,
        )
        set_operation_cost!(hydro, new_opcost)
    end

    # Set up Simulation
    models = SimulationModels(;
        decision_models = [
            DecisionModel(
                template,
                sys;
                name = "UC",
                optimizer = HiGHS.Optimizer,
                system_to_file = false,
                initialize_model = true,
                optimizer_solve_log_print = false,
                direct_mode_optimizer = true,
                rebuild_model = false,
                store_variable_names = true,
                #check_numerical_bounds=false,
            ),
            DecisionModel(
                template_ed,
                sys_ed;
                name = "ED",
                optimizer = HiGHS.Optimizer,
                system_to_file = false,
                initialize_model = true,
                optimizer_solve_log_print = false,
                check_numerical_bounds = false,
                rebuild_model = false,
                calculate_conflict = true,
                store_variable_names = true,
                #export_pwl_vars = true,
            ),
        ],
    )

    sequence = SimulationSequence(;
        models = models,
        feedforwards = Dict(
            "ED" => [
                HydroUsageLimitFeedforward(;
                    component_type = HydroDispatch,
                    source = HydroEnergyOutput,
                    affected_values = [HydroUsageLimitParameter],
                ),
            ],
        ),
        ini_cond_chronology = InterProblemChronology(),
    )

    using Dates
    sim = Simulation(;
        name = "HydroTest",
        steps = 2,
        models = models,
        sequence = sequence,
        initial_time = DateTime("2024-01-01T00:00:00"),
        simulation_folder = mktempdir(; cleanup = true),
    )

    @test build!(sim; serialize = false) == PSI.SimulationBuildStatus.BUILT
    @test execute!(sim; enable_progress_bar = false) == PSI.RunStatus.SUCCESSFULLY_FINALIZED

    results = SimulationResults(sim)
    r_ed = get_decision_problem_results(results, "ED")
    r_uc = get_decision_problem_results(results, "UC")

    uc_p_hy =
        read_realized_variable(r_uc, "ActivePowerVariable__HydroDispatch")[!, 2]
    uc_energy_hy =
        read_realized_aux_variable(r_uc, "HydroEnergyOutput__HydroDispatch")[!, 2]
    uc_hy_regup = read_realized_variable(
        r_uc,
        "ActivePowerReserveVariable__VariableReserve__ReserveUp__Reserve5",
    )[
        !,
        2,
    ]
    uc_hy_regdn = read_realized_variable(
        r_uc,
        "ActivePowerReserveVariable__VariableReserve__ReserveDown__Reserve6",
    )[
        !,
        2,
    ]
    ed_energy_hy =
        read_realized_aux_variable(r_ed, "HydroEnergyOutput__HydroDispatch")[!, 2]
    # Test HydroUsage match with the AuxVar
    @test isapprox(uc_energy_hy * 100.0, uc_p_hy + 0.4 * uc_hy_regup - 0.3 * uc_hy_regdn)
    # Test HydroUsage in ED is bounded by UC
    @test cumsum(ed_energy_hy)[end] <= cumsum(uc_energy_hy)[end]
end

@testset "Test HydroUsageLimitFeedforward with HydroTurbine" begin
    sys = new_c_sys5_hyd(; with_reserves = true)
    sys_ed = deepcopy(sys)

    for s in [sys, sys_ed]
        regup = first(get_components(VariableReserve{ReserveUp}, s))
        regdn = first(get_components(VariableReserve{ReserveDown}, s))
        set_deployed_fraction!(regup, 0.4)
        set_requirement!(regup, 0.1)
        set_deployed_fraction!(regdn, 0.3)
        set_requirement!(regdn, 0.1)
    end

    template = ProblemTemplate(NetworkModel(CopperPlatePowerModel))
    set_device_model!(template, ThermalStandard, ThermalDispatchNoMin)
    set_device_model!(template, PowerLoad, StaticPowerLoad)
    set_device_model!(template, HydroTurbine, HydroTurbineEnergyDispatch)
    set_device_model!(template, HydroReservoir, HydroEnergyModelReservoir)
    set_service_model!(template, VariableReserve{ReserveUp}, RangeReserve)
    set_service_model!(template, VariableReserve{ReserveDown}, RangeReserve)

    template_ed = ProblemTemplate(NetworkModel(CopperPlatePowerModel))
    set_device_model!(template_ed, ThermalStandard, ThermalDispatchNoMin)
    set_device_model!(template_ed, PowerLoad, StaticPowerLoad)
    set_device_model!(template_ed, HydroTurbine, HydroTurbineEnergyDispatch)
    set_device_model!(template_ed, HydroReservoir, HydroEnergyModelReservoir)
    set_service_model!(template_ed, VariableReserve{ReserveUp}, RangeReserve)
    set_service_model!(template_ed, VariableReserve{ReserveDown}, RangeReserve)

    for hydro in get_components(HydroDispatch, sys)
        op_cost = get_operation_cost(hydro)
        new_opcost = HydroGenerationCost(;
            variable = CostCurve(;
                # make hydro expensive in UC to limit usage
                # keep hydro cheap in ED
                value_curve = LinearCurve(
                    16.0,
                    0.0,
                ),
                power_units = UnitSystem.NATURAL_UNITS,
            ),
            fixed = op_cost.fixed,
        )
        set_operation_cost!(hydro, new_opcost)
    end

    # Set up Simulation
    models = SimulationModels(;
        decision_models = [
            DecisionModel(
                template,
                sys;
                name = "UC",
                optimizer = HiGHS.Optimizer,
                system_to_file = false,
                initialize_model = true,
                optimizer_solve_log_print = false,
                direct_mode_optimizer = true,
                rebuild_model = false,
                store_variable_names = true,
                #check_numerical_bounds=false,
            ),
            DecisionModel(
                template_ed,
                sys_ed;
                name = "ED",
                optimizer = HiGHS.Optimizer,
                system_to_file = false,
                initialize_model = true,
                optimizer_solve_log_print = false,
                check_numerical_bounds = false,
                rebuild_model = false,
                calculate_conflict = true,
                store_variable_names = true,
                #export_pwl_vars = true,
            ),
        ],
    )

    sequence = SimulationSequence(;
        models = models,
        feedforwards = Dict(
            "ED" => [
                HydroUsageLimitFeedforward(;
                    component_type = HydroTurbine,
                    source = HydroEnergyOutput,
                    affected_values = [HydroUsageLimitParameter],
                ),
            ],
        ),
        ini_cond_chronology = InterProblemChronology(),
    )

    using Dates
    sim = Simulation(;
        name = "HydroTest",
        steps = 2,
        models = models,
        sequence = sequence,
        initial_time = DateTime("2024-01-01T00:00:00"),
        simulation_folder = mktempdir(; cleanup = true),
    )

    @test build!(sim; serialize = false) == PSI.SimulationBuildStatus.BUILT
    @test execute!(sim; enable_progress_bar = false) == PSI.RunStatus.SUCCESSFULLY_FINALIZED

    results = SimulationResults(sim)
    r_ed = get_decision_problem_results(results, "ED")
    r_uc = get_decision_problem_results(results, "UC")

    uc_p_hy =
        read_realized_variable(r_uc, "ActivePowerVariable__HydroTurbine")[!, 2]
    uc_energy_hy =
        read_realized_aux_variable(r_uc, "HydroEnergyOutput__HydroTurbine")[!, 2]
    uc_hy_regup = read_realized_variable(
        r_uc,
        "ActivePowerReserveVariable__VariableReserve__ReserveUp__Reserve5",
    )[
        !,
        2,
    ]
    uc_hy_regdn = read_realized_variable(
        r_uc,
        "ActivePowerReserveVariable__VariableReserve__ReserveDown__Reserve6",
    )[
        !,
        2,
    ]
    ed_energy_hy =
        read_realized_aux_variable(r_ed, "HydroEnergyOutput__HydroTurbine")[!, 2]
    # Test HydroUsage match with the AuxVar
    @test isapprox(uc_energy_hy * 100.0, uc_p_hy + 0.4 * uc_hy_regup - 0.3 * uc_hy_regdn)
    # Test HydroUsage in ED is bounded by UC
    @test cumsum(ed_energy_hy)[end] <= cumsum(uc_energy_hy)[end]
end

@testset "Test SemiContinuousFeedforward to HydroDispatch with HydroDispatchRunOfRiver model" begin
    device_model = PSI.DeviceModel(HydroDispatch, HydroDispatchRunOfRiver)
    ff_sc = SemiContinuousFeedforward(;
        component_type = HydroDispatch,
        source = PSI.OnVariable,
        affected_values = [PSI.ActivePowerVariable],
    )

    PSI.attach_feedforward!(device_model, ff_sc)
    c_sys5_hy = PSB.build_system(PSITestSystems, "c_sys5_hy")
    model = DecisionModel(MockOperationProblem, DCPPowerModel, c_sys5_hy)
    mock_construct_device!(model, device_model; built_for_recurrent_solves = true)
    moi_tests(model, 72, 0, 48, 24, 0, false)
end

@testset "Test UpperBoundFeedforward to HydroDispatch with HydroCommitmentRunOfRiver model" begin
    device_model = PSI.DeviceModel(HydroDispatch, HydroCommitmentRunOfRiver)
    ff_ub = UpperBoundFeedforward(;
        component_type = HydroDispatch,
        source = PSI.ActivePowerVariable,
        affected_values = [PSI.ActivePowerVariable],
    )
    PSI.attach_feedforward!(device_model, ff_ub)
    c_sys5_hy = PSB.build_system(PSITestSystems, "c_sys5_hy")
    model = DecisionModel(MockOperationProblem, DCPPowerModel, c_sys5_hy)
    mock_construct_device!(model, device_model; built_for_recurrent_solves = true)
    moi_tests(model, 96, 0, 72, 24, 0, true)
end

@testset "Test LowerBoundFeedforward to HydroDispatch with HydroCommitmentRunOfRiver model" begin
    device_model = PSI.DeviceModel(HydroDispatch, HydroCommitmentRunOfRiver)
    ff_ub = LowerBoundFeedforward(;
        component_type = HydroDispatch,
        source = PSI.ActivePowerVariable,
        affected_values = [PSI.ActivePowerVariable],
    )
    PSI.attach_feedforward!(device_model, ff_ub)
    c_sys5_hy = PSB.build_system(PSITestSystems, "c_sys5_hy")
    model = DecisionModel(MockOperationProblem, DCPPowerModel, c_sys5_hy)
    mock_construct_device!(model, device_model; built_for_recurrent_solves = true)
    moi_tests(model, 96, 0, 48, 48, 0, true)
end

@testset "Test UpperBoundFeedforward to HydroDispatch with HydroDispatchRunOfRiver model" begin
    device_model = PSI.DeviceModel(HydroDispatch, HydroDispatchRunOfRiver)

    ff_ub = UpperBoundFeedforward(;
        component_type = HydroDispatch,
        source = PSI.ActivePowerVariable,
        affected_values = [PSI.ActivePowerVariable],
    )

    PSI.attach_feedforward!(device_model, ff_ub)
    c_sys5_hy = PSB.build_system(PSITestSystems, "c_sys5_hy")
    model = DecisionModel(MockOperationProblem, DCPPowerModel, c_sys5_hy)
    mock_construct_device!(model, device_model; built_for_recurrent_solves = true)
    moi_tests(model, 72, 0, 72, 24, 0, false)
end

@testset "Test LowerBoundFeedforward to HydroDispatch with HydroDispatchRunOfRiver model" begin
    device_model = PSI.DeviceModel(HydroDispatch, HydroDispatchRunOfRiver)

    ff_ub = LowerBoundFeedforward(;
        component_type = HydroDispatch,
        source = PSI.ActivePowerVariable,
        affected_values = [PSI.ActivePowerVariable],
    )

    PSI.attach_feedforward!(device_model, ff_ub)
    c_sys5_hy = PSB.build_system(PSITestSystems, "c_sys5_hy")
    model = DecisionModel(MockOperationProblem, DCPPowerModel, c_sys5_hy)
    mock_construct_device!(model, device_model; built_for_recurrent_solves = true)
    moi_tests(model, 72, 0, 48, 48, 0, false)
end

@testset "Test ReservoirLimitFeedforward to HydroTurbine with HydroTurbineEnergyDispatch model" begin
    device_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyDispatch)
    ff_il = ReservoirLimitFeedforward(;
        component_type = HydroTurbine,
        source = PSI.ActivePowerVariable,
        affected_values = [PSI.ActivePowerVariable],
        number_of_periods = 12,
    )

    PSI.attach_feedforward!(device_model, ff_il)
    c_sys5_hy = new_c_sys5_hyd()
    model = DecisionModel(MockOperationProblem, DCPPowerModel, c_sys5_hy)
    mock_construct_device!(model, device_model; built_for_recurrent_solves = true)
    moi_tests(model, 48, 0, 26, 24, 0, false)
end

@testset "Test LowerBoundFeedforward to HydroTurbine with HydroTurbineEnergyDispatch model" begin
    device_model = PSI.DeviceModel(HydroEnergyReservoir, HydroDispatchReservoirStorage)
    ff_il = LowerBoundFeedforward(;
        component_type = HydroEnergyReservoir,
        source = PSI.ActivePowerVariable,
        affected_values = [PSI.ActivePowerVariable],
    )

    PSI.attach_feedforward!(device_model, ff_il)
    c_sys5_hy = PSB.build_system(PSITestSystems, "c_sys5_hyd_ems")
    model = DecisionModel(MockOperationProblem, DCPPowerModel, c_sys5_hy)
    mock_construct_device!(model, device_model; built_for_recurrent_solves = true)
    moi_tests(model, 193, 0, 24, 48, 48, false)
end
