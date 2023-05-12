@testset "Multi-Stage Hydro Simulation Build" begin
    sys_md = PSB.build_system(PSISystems, "5_bus_hydro_wk_sys")

    sys_uc = PSB.build_system(PSISystems, "5_bus_hydro_uc_sys")
    transform_single_time_series!(sys_uc, 48, Hour(24))

    sys_ed = PSB.build_system(PSISystems, "5_bus_hydro_ed_sys")

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
            EnergyLimitFeedforward(;
                source = ActivePowerVariable,
                affected_values = [ActivePowerVariable],
                component_type = HydroEnergyReservoir,
                number_of_periods = 24,
            ),
        ],
        "ED" => [
            EnergyLimitFeedforward(;
                source = ActivePowerVariable,
                affected_values = [ActivePowerVariable],
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
    @test build!(sim; serialize = false) == PSI.BuildStatus.BUILT
end

function test_2_stage_decision_models_with_feedforwards(in_memory)
    template_uc = get_template_basic_uc_simulation()
    template_ed = get_template_nomin_ed_simulation()
    set_device_model!(template_ed, InterruptiblePowerLoad, StaticPowerLoad)
    set_device_model!(template_ed, HydroEnergyReservoir, HydroDispatchReservoirBudget)
    set_network_model!(template_uc, NetworkModel(
        CopperPlatePowerModel,
        # MILP "duals" not supported with free solvers
        # duals = [CopperPlateBalanceConstraint],
    ))
    set_network_model!(
        template_ed,
        NetworkModel(
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
                optimizer = GLPK_optimizer,
            ),
            DecisionModel(
                template_ed,
                c_sys5_hy_ed;
                name = "ED",
                optimizer = ipopt_optimizer,
            ),
        ],
    )

    sequence = SimulationSequence(;
        models = models,
        feedforwards = Dict(
            "ED" => [
                SemiContinuousFeedforward(;
                    component_type = ThermalStandard,
                    source = OnVariable,
                    affected_values = [ActivePowerVariable],
                ),
                EnergyLimitFeedforward(;
                    component_type = HydroEnergyReservoir,
                    source = ActivePowerVariable,
                    affected_values = [ActivePowerVariable],
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
    @test build_out == PSI.BuildStatus.BUILT
    execute_out = execute!(sim; in_memory = in_memory)
    @test execute_out == PSI.RunStatus.SUCCESSFUL
end

@testset "2-Stage Decision Models with FeedForwards" begin
    for in_memory in (true, false)
        test_2_stage_decision_models_with_feedforwards(in_memory)
    end
end
