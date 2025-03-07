@testset "Single-stage Hydro Pumped Simulation" begin
    output_dir = mktempdir(; cleanup = true)
    sys_ed = PSB.build_system(PSITestSystems, "c_sys5_phes_ed")

    template_ed = ProblemTemplate(CopperPlatePowerModel)
    set_device_model!(template_ed, PowerLoad, StaticPowerLoad)
    set_device_model!(template_ed, ThermalStandard, ThermalBasicUnitCommitment)
    set_device_model!(template_ed, HydroPumpedStorage, HydroDispatchPumpedStorage)

    model = DecisionModel(
        template_ed,
        sys_ed;
        name = "ED",
        optimizer = HiGHS_optimizer,
        optimizer_solve_log_print = true,
        store_variable_names = true,
    )

    @test build!(model; output_dir = output_dir) == PSI.ModelBuildStatus.BUILT
    @test solve!(model; optimizer = HiGHS_optimizer, output_dir = output_dir) ==
          IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED

    results = OptimizationProblemResults(model)
    variables = read_variables(results)

    # Assert that the water level of the up reservoir level is zero at
    # the last simulation step.
    reservoir_up_level = "HydroEnergyVariableUp__HydroPumpedStorage"
    last_value = last(variables[reservoir_up_level])["HydroPumpedStorage"]
    @test isapprox(last_value, 0, atol = 1e-5)
end

@testset "Multi-Stage Hydro Simulation Build" begin
    sys_md = PSB.build_system(PSISystems, "5_bus_hydro_wk_sys")

    sys_uc = PSB.build_system(PSISystems, "5_bus_hydro_uc_sys")
    transform_single_time_series!(sys_uc, Hour(24), Dates.Hour(24))

    sys_ed = PSB.build_system(PSISystems, "5_bus_hydro_ed_sys")
    transform_single_time_series!(sys_ed, Hour(12), Dates.Hour(1))

    template = ProblemTemplate(CopperPlatePowerModel)
    set_device_model!(template, ThermalStandard, ThermalBasicUnitCommitment)
    set_device_model!(template, PowerLoad, StaticPowerLoad)
    set_device_model!(template, HydroEnergyReservoir, HydroDispatchReservoirBudget)

    template_uc = ProblemTemplate(CopperPlatePowerModel)
    set_device_model!(template_uc, ThermalStandard, ThermalBasicUnitCommitment)
    set_device_model!(template_uc, PowerLoad, StaticPowerLoad)
    set_device_model!(template_uc, HydroEnergyReservoir, HydroDispatchRunOfRiver)

    template_ed = ProblemTemplate(CopperPlatePowerModel)
    set_device_model!(template_ed, ThermalStandard, ThermalBasicUnitCommitment)
    set_device_model!(template_ed, PowerLoad, StaticPowerLoad)
    set_device_model!(template_ed, HydroEnergyReservoir, HydroDispatchRunOfRiver)

    models = SimulationModels([
        DecisionModel(
            template,
            sys_md;
            name = "MD",
            initialize_model = false,
            system_to_file = false,
            optimizer = HiGHS_optimizer,
        ),
        DecisionModel(
            template_uc,
            sys_uc;
            name = "UC",
            initialize_model = false,
            system_to_file = false,
            optimizer = HiGHS_optimizer,
        ),
        DecisionModel(
            template_ed,
            sys_ed;
            name = "ED",
            initialize_model = false,
            system_to_file = false,
            optimizer = HiGHS_optimizer,
        ),
    ])

    feedforwards = Dict(
        "UC" => [
            ReservoirLimitFeedforward(;
                source = PSI.ActivePowerVariable,
                affected_values = [PSI.ActivePowerVariable],
                component_type = HydroEnergyReservoir,
                number_of_periods = 24,
            ),
        ],
        "ED" => [
            ReservoirLimitFeedforward(;
                source = PSI.ActivePowerVariable,
                affected_values = [PSI.ActivePowerVariable],
                component_type = HydroEnergyReservoir,
                number_of_periods = 12,
            ),
        ],
    )

    test_sequence = SimulationSequence(;
        models = models,
        ini_cond_chronology = InterProblemChronology(),
        feedforwards = feedforwards,
    )

    sim = Simulation(;
        name = "test_md",
        steps = 2,
        models = models,
        sequence = test_sequence,
        simulation_folder = mktempdir(; cleanup = true),
    )
    @test build!(sim; serialize = false) == PSI.SimulationBuildStatus.BUILT
end

function test_2_stage_decision_models_with_feedforwards(in_memory)
    template_uc = get_template_basic_uc_simulation()
    template_ed = get_template_nomin_ed_simulation()
    set_device_model!(template_ed, InterruptiblePowerLoad, StaticPowerLoad)
    set_device_model!(template_ed, HydroEnergyReservoir, HydroDispatchReservoirBudget)
    set_network_model!(template_uc, PSI.NetworkModel(
        CopperPlatePowerModel,
        # MILP "duals" not supported with free solvers
        # duals = [CopperPlateBalanceConstraint],
    ))
    set_network_model!(
        template_ed,
        PSI.NetworkModel(
            CopperPlatePowerModel;
            duals = [CopperPlateBalanceConstraint],
            use_slacks = true,
        ),
    )
    c_sys5_hy_uc = PSB.build_system(PSITestSystems, "c_sys5_hy_uc")
    c_sys5_hy_ed = PSB.build_system(PSITestSystems, "c_sys5_hy_ed")
    models = SimulationModels(;
        decision_models = [
            DecisionModel(
                template_uc,
                c_sys5_hy_uc;
                name = "UC",
                optimizer = HiGHS_optimizer,
            ),
            DecisionModel(
                template_ed,
                c_sys5_hy_ed;
                name = "ED",
                optimizer = HiGHS_optimizer,
            ),
        ],
    )

    sequence = SimulationSequence(;
        models = models,
        feedforwards = Dict(
            "ED" => [
                SemiContinuousFeedforward(;
                    component_type = ThermalStandard,
                    source = PSI.OnVariable,
                    affected_values = [PSI.ActivePowerVariable],
                ),
                ReservoirLimitFeedforward(;
                    component_type = HydroEnergyReservoir,
                    source = PSI.ActivePowerVariable,
                    affected_values = [PSI.ActivePowerVariable],
                    number_of_periods = 12,
                ),
            ],
        ),
        ini_cond_chronology = InterProblemChronology(),
    )
    sim = Simulation(;
        name = "no_cache",
        steps = 2,
        models = models,
        sequence = sequence,
        simulation_folder = mktempdir(; cleanup = true),
    )

    build_out = build!(sim; console_level = Logging.Error)
    @test build_out == PSI.SimulationBuildStatus.BUILT
    execute_out = execute!(sim; in_memory = in_memory)
    @test execute_out == PSI.RunStatus.SUCCESSFULLY_FINALIZED
end

@testset "2-Stage Decision Models with FeedForwards" begin
    for in_memory in (true, false)
        test_2_stage_decision_models_with_feedforwards(in_memory)
    end
end

@testset "HydroPumpedStorage desicion model with Reserves" begin
    output_dir = mktempdir(; cleanup = true)
    sys = PSB.build_system(PSITestSystems, "c_sys5_phes_ed"; add_reserves = true)
    res5 = only(get_components(VariableReserve{ReserveUp}, sys))
    set_requirement!(res5, 0.1)

    res6 = only(get_components(VariableReserve{ReserveDown}, sys))
    set_requirement!(res6, 0.1)
    template = ProblemTemplate(CopperPlatePowerModel)
    set_device_model!(template, PowerLoad, StaticPowerLoad)
    set_device_model!(
        template,
        DeviceModel(
            HydroPumpedStorage,
            HydroDispatchPumpedStorage;
            attributes = Dict{String, Any}("reservation" => false),
        ),
    )
    set_device_model!(template, ThermalStandard, ThermalBasicUnitCommitment)
    set_service_model!(template, ServiceModel(VariableReserve{ReserveUp}, RangeReserve))
    set_service_model!(template, ServiceModel(VariableReserve{ReserveDown}, RangeReserve))

    model = DecisionModel(
        template,
        sys;
        name = "ED",
        optimizer = HiGHS_optimizer,
        optimizer_solve_log_print = true,
        store_variable_names = true,
    )
    @test build!(model; output_dir = output_dir) == PSI.ModelBuildStatus.BUILT
    @test solve!(model; optimizer = HiGHS_optimizer, output_dir = output_dir) ==
          IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED

    set_device_model!(
        template,
        DeviceModel(
            HydroPumpedStorage,
            HydroDispatchPumpedStorage;
            attributes = Dict{String, Any}("reservation" => true),
        ),
    )

    model = DecisionModel(
        template,
        sys;
        name = "ED",
        optimizer = HiGHS_optimizer,
        optimizer_solve_log_print = true,
        store_variable_names = true,
    )
    @test build!(model; output_dir = output_dir) == PSI.ModelBuildStatus.BUILT
    @test solve!(model; optimizer = HiGHS_optimizer, output_dir = output_dir) ==
          IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED
end

@testset "Single stage HydroPumpedStorage simulation with Reserves" begin
    output_dir = mktempdir(; cleanup = true)
    sys = PSB.build_system(PSITestSystems, "c_sys5_phes_ed"; add_reserves = true)
    res5 = only(get_components(VariableReserve{ReserveUp}, sys))
    set_requirement!(res5, 0.1)

    res6 = only(get_components(VariableReserve{ReserveDown}, sys))
    set_requirement!(res6, 0.1)
    transform_single_time_series!(sys, Hour(12), Dates.Hour(1))
    template = ProblemTemplate(CopperPlatePowerModel)
    set_device_model!(template, PowerLoad, StaticPowerLoad)
    set_device_model!(
        template,
        DeviceModel(
            HydroPumpedStorage,
            HydroDispatchPumpedStorage;
            attributes = Dict{String, Any}("reservation" => true),
        ),
    )
    set_device_model!(template, ThermalStandard, ThermalBasicUnitCommitment)
    set_service_model!(template, ServiceModel(VariableReserve{ReserveUp}, RangeReserve))
    set_service_model!(template, ServiceModel(VariableReserve{ReserveDown}, RangeReserve))

    models = SimulationModels(;
        decision_models = [
            DecisionModel(
                template,
                sys;
                name = "UC",
                optimizer = HiGHS_optimizer,
                initialize_model = true,
                optimizer_solve_log_print = true,
                direct_mode_optimizer = true,
                check_numerical_bounds = false,
                calculate_conflict = true,
                rebuild_model = true,
            ),
        ],
    )
    sequence = SimulationSequence(;
        models = models,
        ini_cond_chronology = InterProblemChronology(),
    )

    sim = Simulation(;
        name = "test",
        steps = 2,
        models = models,
        sequence = sequence,
        initial_time = DateTime("2024-01-01T00:00:00"),
        simulation_folder = mktempdir(; cleanup = true),
    )
    @test build!(sim) == IS.Simulation.SimulationBuildStatus.BUILT
    @test execute!(sim) == IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED
end
