
# Test build of decision models

# Reservoir data in USABLE_VOLUME
@testset "Hydro Reservoir Data in USABLE_VOLUME, single step simulation" begin
    # key word args for custom test system
    PSB = PowerSystemCaseBuilder
    kwargs = (
        withStandardLoad = true,
        withThermalStandard = true,
        withRenewableDispatch = true,
        withRenewableNonDispatch = true,
        withEnergyReservoirStorage = true,
        withInterruptiblePowerLoad = true,
        withHydroTurbine = true,
        withHydroPumpTurbine = false,
        withHydroDispatch = true,
        hydroLevelDataType = PSY.ReservoirDataType.USABLE_VOLUME,
    )
    test_system_uc = PSB.build_system(
        PSISystems,
        "csys5_custom";
        skip_serialization = true,
        time_series_in_memory = true,
        decision_model_type = "uc",
        kwargs...,
    )
    test_system_ed = PSB.build_system(
        PSISystems,
        "csys5_custom";
        skip_serialization = true,
        time_series_in_memory = true,
        decision_model_type = "uc",
        kwargs...,
    )

    # set templates and device models
    template_uc = ProblemTemplate(NetworkModel(CopperPlatePowerModel))
    set_device_model!(template_uc, HydroReservoir, HydroWaterModelReservoir)
    set_device_model!(template_uc, HydroTurbine, HydroTurbineBilinearDispatch)
    set_device_model!(template_uc, ThermalStandard, ThermalBasicUnitCommitment)
    set_device_model!(template_uc, PowerLoad, StaticPowerLoad)
    template_ed = ProblemTemplate(NetworkModel(CopperPlatePowerModel))
    set_device_model!(template_ed, HydroReservoir, HydroWaterModelReservoir)
    set_device_model!(template_ed, HydroTurbine, HydroTurbineBilinearDispatch)
    set_device_model!(template_ed, ThermalStandard, ThermalBasicDispatch)
    set_device_model!(template_ed, PowerLoad, StaticPowerLoad)
    # TODO: Test HydroPumpTurbine formulation?

    # see if single decision models will build

    # Set up Simulation
    models = SimulationModels(;
        decision_models = [
            DecisionModel(
                template_uc,
                test_system_uc;
                name = "UC",
                optimizer = SCIP.Optimizer,
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
                test_system_ed;
                name = "ED",
                optimizer = SCIP.Optimizer,
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
        ),
        ini_cond_chronology = InterProblemChronology(),
    )

    using Dates
    sim = Simulation(;
        name = "HydroTest",
        steps = 2,
        models = models,
        sequence = sequence,
        initial_time = DateTime("2020-01-01T00:00:00"),
        simulation_folder = mktempdir(; cleanup = true),
    )

    problem = DecisionModel(
        template_uc,
        test_system_uc;
        optimizer = SCIP.Optimizer,
        horizon = Hour(24),
    )
    @test build!(problem; output_dir = mktempdir()) ==
          InfrastructureSystems.Optimization.ModelBuildStatusModule.ModelBuildStatus.BUILT

    problem = DecisionModel(
        template_ed,
        test_system_ed;
        optimizer = SCIP.Optimizer,
    )
    @test build!(problem; output_dir = mktempdir()) ==
          InfrastructureSystems.Optimization.ModelBuildStatusModule.ModelBuildStatus.BUILT

    psi_checksolve_test(
        problem,
        [MOI.OPTIMAL, MOI.LOCALLY_SOLVED],
    )
    #@test build!(sim; serialize = false) == PSI.SimulationBuildStatus.BUILT
    #@test execute!(sim; enable_progress_bar = false) == PSI.RunStatus.SUCCESSFULLY_FINALIZED

end
#
# Reservoir data in ENERGY
@testset "Hydro Reservoir Data in ENERGY, single step simulation" begin
    # key word args for custom test system
    kwargs = (
        withStandardLoad = true,
        withThermalStandard = true,
        withRenewableDispatch = true,
        withRenewableNonDispatch = true,
        withEnergyReservoirStorage = true,
        withInterruptiblePowerLoad = true,
        withHydroTurbine = true,
        withHydroPumpTurbine = false,
        withHydroDispatch = true,
        hydroLevelDataType = PSY.ReservoirDataType.ENERGY,
    )
    test_system_uc = PSB.build_system(
        PSISystems,
        "csys5_custom";
        skip_serialization = true,
        time_series_in_memory = true,
        decision_model_type = "uc",
        kwargs...,
    )
    test_system_ed = PSB.build_system(
        PSISystems,
        "csys5_custom";
        skip_serialization = true,
        time_series_in_memory = true,
        decision_model_type = "uc",
        kwargs...,
    )

    remove_component!(HydroTurbine, test_system_uc, "HydroTurbine2")
    remove_component!(HydroTurbine, test_system_ed, "HydroTurbine2")

    # set templates and device models
    template_uc = ProblemTemplate(NetworkModel(CopperPlatePowerModel))
    set_device_model!(template_uc, HydroReservoir, HydroEnergyModelReservoir)
    set_device_model!(template_uc, HydroTurbine, HydroTurbineEnergyDispatch)
    set_device_model!(template_uc, ThermalStandard, ThermalBasicUnitCommitment)
    template_ed = ProblemTemplate(NetworkModel(CopperPlatePowerModel))
    set_device_model!(template_ed, HydroReservoir, HydroEnergyModelReservoir)
    set_device_model!(template_ed, HydroTurbine, HydroTurbineEnergyDispatch)
    set_device_model!(template_ed, ThermalStandard, ThermalBasicDispatch)
    # TODO: Test HydroPumpTurbine formulation?

    # Set up Simulation
    models = SimulationModels(;
        decision_models = [
            DecisionModel(
                template_uc,
                test_system_uc;
                name = "UC",
                optimizer = SCIP.Optimizer,
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
                test_system_ed;
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
        ),
        ini_cond_chronology = InterProblemChronology(),
    )

    using Dates
    sim = Simulation(;
        name = "HydroTest",
        steps = 2,
        models = models,
        sequence = sequence,
        initial_time = DateTime("2020-01-01T00:00:00"),
        simulation_folder = mktempdir(; cleanup = true),
    )

    problem = DecisionModel(
        template_uc,
        test_system_uc;
        optimizer = SCIP.Optimizer,
        horizon = Hour(24),
    )
    @test build!(problem; output_dir = mktempdir()) ==
          InfrastructureSystems.Optimization.ModelBuildStatusModule.ModelBuildStatus.BUILT

    problem = DecisionModel(
        template_ed,
        test_system_ed;
        optimizer = SCIP.Optimizer,
        horizon = Hour(24),
    )
    @test build!(problem; output_dir = mktempdir()) ==
          InfrastructureSystems.Optimization.ModelBuildStatusModule.ModelBuildStatus.BUILT

    psi_checksolve_test(
        problem,
        [MOI.OPTIMAL, MOI.LOCALLY_SOLVED],
    )
    #@test build!(sim; serialize = false) == InfrastructureSystems.Simulation.SimulationBuildStatusModule.SimulationBuildStatus.BUILT = 0
    #@test execute!(sim; enable_progress_bar = false) == PSI.RunStatus.SUCCESSFULLY_FINALIZED

end

# Reservoir data in VOLUME
@testset "Hydro Reservoir Data in TOTAL_VOLUME, single step simulation" begin
    # key word args for custom test system
    PSB = PowerSystemCaseBuilder
    kwargs = (
        withStandardLoad = true,
        withThermalStandard = true,
        withRenewableDispatch = true,
        withRenewableNonDispatch = true,
        withEnergyReservoirStorage = true,
        withInterruptiblePowerLoad = true,
        withHydroTurbine = true,
        withHydroPumpTurbine = false,
        withHydroDispatch = true,
        hydroLevelDataType = PSY.ReservoirDataType.TOTAL_VOLUME,
    )
    test_system_uc = PSB.build_system(
        PSISystems,
        "csys5_custom";
        skip_serialization = true,
        time_series_in_memory = true,
        decision_model_type = "uc",
        kwargs...,
    )
    test_system_ed = PSB.build_system(
        PSISystems,
        "csys5_custom";
        skip_serialization = true,
        time_series_in_memory = true,
        decision_model_type = "uc",
        kwargs...,
    )

    # set templates and device models
    template_uc = ProblemTemplate(NetworkModel(CopperPlatePowerModel))
    set_device_model!(template_uc, HydroReservoir, HydroWaterModelReservoir)
    set_device_model!(template_uc, HydroTurbine, HydroTurbineBilinearDispatch)
    set_device_model!(template_uc, ThermalStandard, ThermalStandardUnitCommitment)
    template_ed = ProblemTemplate(NetworkModel(CopperPlatePowerModel))
    set_device_model!(template_ed, HydroReservoir, HydroWaterModelReservoir)
    set_device_model!(template_ed, HydroTurbine, HydroTurbineBilinearDispatch)
    set_device_model!(template_ed, ThermalStandard, ThermalStandardDispatch)
    # TODO: Test HydroPumpTurbine formulation?

    # see if single decision models will build

    # Set up Simulation
    models = SimulationModels(;
        decision_models = [
            DecisionModel(
                template_uc,
                test_system_uc;
                name = "UC",
                optimizer = SCIP.Optimizer,
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
                test_system_ed;
                name = "ED",
                optimizer = SCIP.Optimizer,
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
        ),
        ini_cond_chronology = InterProblemChronology(),
    )

    using Dates
    sim = Simulation(;
        name = "HydroTest",
        steps = 2,
        models = models,
        sequence = sequence,
        initial_time = DateTime("2020-01-01T00:00:00"),
        simulation_folder = mktempdir(; cleanup = true),
    )

    problem = DecisionModel(
        template_uc,
        test_system_uc;
        optimizer = SCIP.Optimizer,
        horizon = Hour(24),
    )
    @test build!(problem; output_dir = mktempdir()) ==
          InfrastructureSystems.Optimization.ModelBuildStatusModule.ModelBuildStatus.BUILT

    problem = DecisionModel(
        template_ed,
        test_system_ed;
        optimizer = SCIP.Optimizer,
        horizon = Hour(24),
    )
    @test build!(problem; output_dir = mktempdir()) ==
          InfrastructureSystems.Optimization.ModelBuildStatusModule.ModelBuildStatus.BUILT

    psi_checksolve_test(
        problem,
        [MOI.OPTIMAL, MOI.LOCALLY_SOLVED],
    )
    #@test build!(sim; serialize = false) == PSI.SimulationBuildStatus.BUILT
    #@test execute!(sim; enable_progress_bar = false) == PSI.RunStatus.SUCCESSFULLY_FINALIZED

end

# Reservoir data in HEAD
@testset "Hydro Reservoir Data in HEAD, single step simulation" begin
    # key word args for custom test system
    PSB = PowerSystemCaseBuilder
    kwargs = (
        withStandardLoad = true,
        withThermalStandard = true,
        withRenewableDispatch = true,
        withRenewableNonDispatch = true,
        withEnergyReservoirStorage = true,
        withInterruptiblePowerLoad = true,
        withHydroTurbine = true,
        withHydroPumpTurbine = false,
        withHydroDispatch = true,
        hydroLevelDataType = PSY.ReservoirDataType.HEAD,
    )
    test_system_uc = PSB.build_system(
        PSISystems,
        "csys5_custom";
        skip_serialization = true,
        time_series_in_memory = true,
        decision_model_type = "uc",
        kwargs...,
    )
    test_system_ed = PSB.build_system(
        PSISystems,
        "csys5_custom";
        skip_serialization = true,
        time_series_in_memory = true,
        decision_model_type = "uc",
        kwargs...,
    )

    # set templates and device models
    template_uc = ProblemTemplate(NetworkModel(CopperPlatePowerModel))
    set_device_model!(template_uc, HydroReservoir, HydroWaterModelReservoir)
    set_device_model!(template_uc, HydroTurbine, HydroTurbineBilinearDispatch)
    set_device_model!(template_uc, ThermalStandard, ThermalStandardUnitCommitment)
    template_ed = ProblemTemplate(NetworkModel(CopperPlatePowerModel))
    set_device_model!(template_ed, HydroReservoir, HydroWaterModelReservoir)
    set_device_model!(template_ed, HydroTurbine, HydroTurbineBilinearDispatch)
    set_device_model!(template_ed, ThermalStandard, ThermalStandardDispatch)
    # TODO: Test HydroPumpTurbine formulation?

    # see if single decision models will build

    # Set up Simulation
    models = SimulationModels(;
        decision_models = [
            DecisionModel(
                template_uc,
                test_system_uc;
                name = "UC",
                optimizer = SCIP.Optimizer,
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
                test_system_ed;
                name = "ED",
                optimizer = SCIP.Optimizer,
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
        ),
        ini_cond_chronology = InterProblemChronology(),
    )

    using Dates
    sim = Simulation(;
        name = "HydroTest",
        steps = 2,
        models = models,
        sequence = sequence,
        initial_time = DateTime("2020-01-01T00:00:00"),
        simulation_folder = mktempdir(; cleanup = true),
    )

    problem = DecisionModel(
        template_uc,
        test_system_uc;
        optimizer = SCIP.Optimizer,
        horizon = Hour(24),
    )
    @test build!(problem; output_dir = mktempdir()) ==
          InfrastructureSystems.Optimization.ModelBuildStatusModule.ModelBuildStatus.BUILT

    problem = DecisionModel(
        template_ed,
        test_system_ed;
        optimizer = SCIP.Optimizer,
        horizon = Hour(24),
    )
    @test build!(problem; output_dir = mktempdir()) ==
          InfrastructureSystems.Optimization.ModelBuildStatusModule.ModelBuildStatus.BUILT

    psi_checksolve_test(
        problem,
        [MOI.OPTIMAL, MOI.LOCALLY_SOLVED],
    )
    #@test build!(sim; serialize = false) == PSI.SimulationBuildStatus.BUILT
    #@test execute!(sim; enable_progress_bar = false) == PSI.RunStatus.SUCCESSFULLY_FINALIZED

end
