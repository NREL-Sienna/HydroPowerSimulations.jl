#########################################
#### RESERVOIR BUDGET DISPATCH TESTS ####
#########################################
@testset "Hydro DCPLossLess with HydroTurbineEnergyDispatch and HydroEnergyModelReservoir (with budget) Formulations" begin
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyDispatch)
    reservoir_model = DeviceModel(
        HydroReservoir,
        HydroEnergyModelReservoir;
        attributes = Dict{String, Any}(
            "energy_target" => false,
            "hydro_budget" => true,
        ),
    )

    c_sys5_hyd = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")

    # No Parameters Testing
    model = DecisionModel(MockOperationProblem, DCPPowerModel, c_sys5_hyd)
    mock_construct_device!(model, turbine_model)
    mock_construct_device!(model, reservoir_model)
    moi_tests(model, 120, 0, 25, 24, 24, false)
    psi_checkobjfun_test(model, GAEVF)
end

@testset "Hydro ACPPowerModel with HydroTurbineEnergyDispatch and HydroEnergyModelReservoir (with budget) Formulations" begin
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyDispatch)
    reservoir_model = DeviceModel(
        HydroReservoir,
        HydroEnergyModelReservoir;
        attributes = Dict{String, Any}(
            "energy_target" => false,
            "hydro_budget" => true,
        ),
    )

    c_sys5_hyd = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")

    # No Parameters Testing
    model = DecisionModel(MockOperationProblem, ACPPowerModel, c_sys5_hyd)
    mock_construct_device!(model, turbine_model)
    mock_construct_device!(model, reservoir_model)
    moi_tests(model, 144, 0, 49, 48, 24, false)
    psi_checkobjfun_test(model, GAEVF)
end

###########################################
#### RESERVOIR BUDGET COMMITMENT TESTS ####
###########################################

@testset "Hydro DCPLossLess with HydroTurbineEnergyCommitment and HydroEnergyModelReservoir (with budget) Formulations" begin
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyCommitment)
    reservoir_model = DeviceModel(
        HydroReservoir,
        HydroEnergyModelReservoir;
        attributes = Dict{String, Any}(
            "energy_target" => false,
            "hydro_budget" => true,
        ),
    )

    c_sys5_hyd = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")

    # No Parameters Testing
    model = DecisionModel(MockOperationProblem, DCPPowerModel, c_sys5_hyd)
    mock_construct_device!(model, turbine_model)
    mock_construct_device!(model, reservoir_model)
    moi_tests(model, 144, 0, 25, 24, 24, true)
    psi_checkobjfun_test(model, GAEVF)
end

@testset "Hydro ACPPowerModel with HydroTurbineEnergyCommitment and HydroEnergyModelReservoir (with budget) Formulations" begin
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyCommitment)
    reservoir_model = DeviceModel(
        HydroReservoir,
        HydroEnergyModelReservoir;
        attributes = Dict{String, Any}(
            "energy_target" => false,
            "hydro_budget" => true,
        ),
    )

    c_sys5_hyd = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")

    # No Parameters Testing
    model = DecisionModel(MockOperationProblem, ACPPowerModel, c_sys5_hyd)
    mock_construct_device!(model, turbine_model)
    mock_construct_device!(model, reservoir_model)
    moi_tests(model, 168, 0, 49, 48, 24, true)
    psi_checkobjfun_test(model, GAEVF)
end

#########################################
#### RESERVOIR TARGET DISPATCH TESTS ####
#########################################

@testset "Hydro DCPLossLess with HydroTurbineEnergyDispatch and HydroEnergyModelReservoir (with target) Formulations" begin
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyDispatch)
    reservoir_model = DeviceModel(
        HydroReservoir,
        HydroEnergyModelReservoir;
        attributes = Dict{String, Any}(
            "energy_target" => true,
            "hydro_budget" => false,
        ),
    )

    c_sys5_hyd = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")

    # No Parameters Testing
    model = DecisionModel(MockOperationProblem, DCPPowerModel, c_sys5_hyd)
    mock_construct_device!(model, turbine_model)
    mock_construct_device!(model, reservoir_model)
    moi_tests(model, 120, 0, 24, 24, 48, false)
    psi_checkobjfun_test(model, GAEVF)
end

@testset "Hydro ACPPowerModel with HydroTurbineEnergyDispatch and HydroEnergyModelReservoir (with target) Formulations" begin
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyDispatch)
    reservoir_model = DeviceModel(
        HydroReservoir,
        HydroEnergyModelReservoir;
        attributes = Dict{String, Any}(
            "energy_target" => true,
            "hydro_budget" => false,
        ),
    )

    c_sys5_hyd = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")

    # No Parameters Testing
    model = DecisionModel(MockOperationProblem, ACPPowerModel, c_sys5_hyd)
    mock_construct_device!(model, turbine_model)
    mock_construct_device!(model, reservoir_model)
    moi_tests(model, 144, 0, 48, 48, 48, false)
    psi_checkobjfun_test(model, GAEVF)
end

#########################################
########### RUN OF RIVER TESTS ##########
#########################################

@testset "Solving ED Hydro System using Dispatch Run of River" begin
    sys = PSB.build_system(PSITestSystems, "c_sys5_hy")
    networks = [ACPPowerModel, DCPPowerModel]

    test_results =
        Dict{Any, Float64}(ACPPowerModel => 136581.41, DCPPowerModel => 135382.37)

    for net in networks
        @testset "HydroRoR ED model $(net)" begin
            template = get_thermal_dispatch_template_network(net)
            set_device_model!(template, HydroDispatch, HydroDispatchRunOfRiver)
            ED = DecisionModel(
                EconomicDispatchProblem,
                template,
                sys;
                optimizer = ipopt_optimizer,
            )
            @test build!(ED; output_dir = mktempdir(; cleanup = true)) ==
                  PSI.ModelBuildStatus.BUILT
            psi_checksolve_test(
                ED,
                [MOI.OPTIMAL, MOI.LOCALLY_SOLVED],
                test_results[net],
                1000,
            )
        end
    end
end

@testset "Solving ED Hydro System using Commitment Run of River" begin
    sys = PSB.build_system(PSITestSystems, "c_sys5_hy")
    net = CopperPlatePowerModel

    template = get_thermal_dispatch_template_network(net)
    set_device_model!(template, HydroDispatch, HydroCommitmentRunOfRiver)

    @testset "HydroRoR ED model $(net)" begin
        ED =
            DecisionModel(UnitCommitmentProblem, template, sys; optimizer = HiGHS_optimizer)
        @test build!(ED; output_dir = mktempdir(; cleanup = true)) ==
              PSI.ModelBuildStatus.BUILT
        psi_checksolve_test(ED, [MOI.OPTIMAL, MOI.LOCALLY_SOLVED], 135382.38, 1000)
    end
end

@testset "Test Reserves from Hydro with RunOfRiver" begin
    template = ProblemTemplate(CopperPlatePowerModel)
    set_device_model!(template, PowerLoad, StaticPowerLoad)
    set_device_model!(template, HydroEnergyReservoir, HydroDispatchRunOfRiver)
    set_service_model!(
        template,
        ServiceModel(VariableReserve{ReserveUp}, RangeReserve, "Reserve5"),
    )
    set_service_model!(
        template,
        ServiceModel(VariableReserve{ReserveDown}, RangeReserve, "Reserve6"),
    )
    set_service_model!(
        template,
        ServiceModel(ReserveDemandCurve{ReserveUp}, StepwiseCostReserve, "ORDC1"),
    )

    c_sys5_hyd = PSB.build_system(PSITestSystems, "c_sys5_hyd"; add_reserves = true)
    model = DecisionModel(template, c_sys5_hyd)
    @test build!(model; output_dir = mktempdir(; cleanup = true)) ==
          PSI.ModelBuildStatus.BUILT
    # The value of this test needs to be revised
    # moi_tests(model, 240, 0, 48, 96, 72, false)
end

#########################################
###### RESERVOIR SYSTEM TESTS ###########
#########################################

@testset "Solving ED Hydro System using Dispatch with Reservoir" begin
    sys = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")
    networks = [ACPPowerModel, DCPPowerModel]
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyDispatch)
    models = [
        DeviceModel(
            HydroReservoir,
            HydroEnergyModelReservoir;
            attributes = Dict{String, Any}(
                "energy_target" => true,
                "hydro_budget" => false,
            ),
        ),
        DeviceModel(
            HydroReservoir,
            HydroEnergyModelReservoir;
            attributes = Dict{String, Any}(
                "energy_target" => false,
                "hydro_budget" => true,
            ),
        ),
    ]
    test_results = Dict{Any, Float64}(
        (ACPPowerModel, HydroEnergyModelReservoir, true) => 136296.0,
        (DCPPowerModel, HydroEnergyModelReservoir, true) => 135404.0,
        (ACPPowerModel, HydroEnergyModelReservoir, false) => 131305.0,
        (DCPPowerModel, HydroEnergyModelReservoir, false) => 130479.0,
    )

    for net in networks
        for reservoir_model in models
            formulation = PSI.get_formulation(reservoir_model)
            attrs = PSI.get_attributes(reservoir_model)
            energy_target = get(attrs, "energy_target", false)
            hydro_budget = get(attrs, "hydro_budget", false)
            @testset "$(formulation) with energy_target: $energy_target, and hydro_budget: $hydro_budget, ED model on $(net)" begin
                template = get_thermal_dispatch_template_network(net)
                set_device_model!(template, turbine_model)
                set_device_model!(template, reservoir_model)

                ED = DecisionModel(
                    EconomicDispatchProblem,
                    template,
                    sys;
                    optimizer = ipopt_optimizer,
                )
                @test build!(ED; output_dir = mktempdir(; cleanup = true)) ==
                      PSI.ModelBuildStatus.BUILT
                psi_checksolve_test(
                    ED,
                    [MOI.OPTIMAL, MOI.LOCALLY_SOLVED],
                    test_results[(net, formulation, energy_target)],
                    1000,
                )
            end
        end
    end
end

@testset "Solving ED Hydro System using Commitment with Reservoir" begin
    sys = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")
    net = DCPPowerModel
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyCommitment)
    models = [
        DeviceModel(
            HydroReservoir,
            HydroEnergyModelReservoir;
            attributes = Dict{String, Any}(
                "energy_target" => true,
                "hydro_budget" => false,
            ),
        ),
        DeviceModel(
            HydroReservoir,
            HydroEnergyModelReservoir;
            attributes = Dict{String, Any}(
                "energy_target" => false,
                "hydro_budget" => true,
            ),
        ),
    ]
    test_results = Dict{Any, Float64}(
        (DCPPowerModel, HydroEnergyModelReservoir, true) => 150759.0,
        (DCPPowerModel, HydroEnergyModelReservoir, false) => 144109.0,
    )

    for reservoir_model in models
        formulation = PSI.get_formulation(reservoir_model)
        attrs = PSI.get_attributes(reservoir_model)
        energy_target = get(attrs, "energy_target", false)
        hydro_budget = get(attrs, "hydro_budget", false)
        @testset "$(formulation) with energy_target: $energy_target, and hydro_budget: $hydro_budget, ED model on $(net)" begin
            template = get_thermal_dispatch_template_network(net)
            set_device_model!(template, turbine_model)
            set_device_model!(template, reservoir_model)

            ED = DecisionModel(
                EconomicDispatchProblem,
                template,
                sys;
                optimizer = HiGHS_optimizer,
            )
            @test build!(ED; output_dir = mktempdir(; cleanup = true)) ==
                  PSI.ModelBuildStatus.BUILT
            psi_checksolve_test(
                ED,
                [MOI.OPTIMAL, MOI.LOCALLY_SOLVED],
                test_results[(net, formulation, energy_target)],
                1000,
            )
        end
    end
end

########################################################
####### Hydro DISPATCH RUN OF RIVER BUDGET TEST ########
########################################################
@testset "Test Hydro Dispatch Run Of River Formulations " begin
    device_model = PSI.DeviceModel(HydroDispatch, HydroDispatchRunOfRiverBudget;
        attributes = Dict("hydro_budget_interval" => Hour(24)))

    sys = PSB.build_system(PSITestSystems, "c_sys5_hy")

    hy = only(get_components(HydroDispatch, sys))
    max_power = get_max_active_power(hy)
    resolution = Dates.Hour(1)
    tstamp = range(DateTime("2024-01-01T00:00:00"); step = resolution, length = 48)
    data = ones(length(tstamp)) / (get_base_power(sys) * max_power)
    ts = SingleTimeSeries("hydro_budget", TimeArray(tstamp, data))
    add_time_series!(sys, hy, ts)
    transform_single_time_series!(sys, Hour(24), Hour(24))

    model = DecisionModel(MockOperationProblem, CopperPlatePowerModel, sys)
    mock_construct_device!(model, device_model)
    moi_tests(model, 24, 0, 50, 24, 0, false)
    psi_checkobjfun_test(model, GAEVF)
end

@testset "Solve Hydro Dispatch Run Of River" begin
    output_dir = mktempdir(; cleanup = true)

    c_sys5_hy = PSB.build_system(PSITestSystems, "c_sys5_hy")

    hydro_budget = 24
    eps = 1e-6

    hy = only(get_components(HydroDispatch, c_sys5_hy))
    max_power = get_max_active_power(hy)

    tstamp = range(DateTime("2024-01-01T00:00:00"); step = Dates.Hour(1), length = 48)
    data = ones(length(tstamp)) / (get_base_power(c_sys5_hy) * max_power)
    ts = SingleTimeSeries("hydro_budget", TimeArray(tstamp, data))
    add_time_series!(c_sys5_hy, first(get_components(HydroDispatch, c_sys5_hy)), ts)
    transform_single_time_series!(c_sys5_hy, Hour(24), Hour(24))

    template_uc = ProblemTemplate()
    set_device_model!(template_uc, ThermalStandard, ThermalBasicUnitCommitment)
    set_device_model!(template_uc, RenewableDispatch, RenewableFullDispatch)
    set_device_model!(template_uc, PowerLoad, StaticPowerLoad)
    set_device_model!(template_uc, RenewableNonDispatch, FixedOutput)
    set_device_model!(
        template_uc,
        DeviceModel(HydroDispatch, HydroDispatchRunOfRiverBudget;
            attributes = Dict("hydro_budget_interval" => Hour(hydro_budget))),
    )
    model = DecisionModel(
        template_uc,
        c_sys5_hy;
        optimizer = HiGHS_optimizer,
        store_variable_names = true,
    )

    @test build!(model; output_dir = output_dir) ==
          PSI.ModelBuildStatus.BUILT

    @test solve!(model; output_dir = output_dir) ==
          IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED

    res = OptimizationProblemResults(model)
    hydro_power_sum =
        sum(read_variable(res, "ActivePowerVariable__HydroDispatch")[!, :HydroDispatch])

    @test abs(hydro_power_sum - hydro_budget) <= eps
end

################################################
####### Hydro PUMP ENERGY DISPATCH TEST ########
################################################
@testset "Test Hydro Pump Energy Dispatch Formulations " begin
    device_model = PSI.DeviceModel(
        HydroPumpTurbine,
        HPS.HydroPumpEnergyDispatch;
        attributes = Dict{String, Any}(
            "reservation" => true,
            "energy_target" => true,
        ),
    )

    c_sys5_bat =
        PSB.build_system(PSITestSystems, "c_sys5_hydro_pump_energy"; add_reserves = true)

    hy_pump = first(PSY.get_components(HydroPumpTurbine, c_sys5_bat))

    ### Add Time Series ###
    DayAhead = collect(
        DateTime("1/1/2024  0:00:00", "d/m/y  H:M:S"):Hour(1):DateTime(
            "1/1/2024  23:00:00",
            "d/m/y  H:M:S",
        ),
    )

    hydro_max_power = 0.8 * ones(48)
    hydro_max_cap = 0.9 * ones(48)
    tstamps = vcat(DayAhead, DayAhead .+ Day(1))
    tarray_power = TimeArray(tstamps, hydro_max_power)
    tarray_cap = TimeArray(tstamps, hydro_max_cap)

    PSY.add_time_series!(
        c_sys5_bat,
        hy_pump,
        PSY.SingleTimeSeries("max_active_power", tarray_power),
    )
    PSY.add_time_series!(
        c_sys5_bat,
        hy_pump,
        PSY.SingleTimeSeries("capacity", tarray_cap),
    )
    transform_single_time_series!(c_sys5_bat, Hour(24), Hour(24))

    model = DecisionModel(MockOperationProblem, CopperPlatePowerModel, c_sys5_bat)
    mock_construct_device!(model, device_model)
    moi_tests(model, 168, 0, 120, 24, 25, true)
    psi_checkobjfun_test(model, GAEVF)
end

@testset "Test Hydro Pump Energy Dispatch Formulations 2" begin
    output_dir = mktempdir(; cleanup = true)

    c_sys5_bat =
        PSB.build_system(PSITestSystems, "c_sys5_hydro_pump_energy"; add_reserves = true)

    hy_pump = first(PSY.get_components(HydroPumpTurbine, c_sys5_bat))

    ### Add Time Series ###
    DayAhead = collect(
        DateTime("1/1/2024  0:00:00", "d/m/y  H:M:S"):Hour(1):DateTime(
            "1/1/2024  23:00:00",
            "d/m/y  H:M:S",
        ),
    )

    hydro_max_power = 0.8 * ones(48)
    hydro_max_cap = 0.9 * ones(48)
    tstamps = vcat(DayAhead, DayAhead .+ Day(1))
    tarray_power = TimeArray(tstamps, hydro_max_power)
    tarray_cap = TimeArray(tstamps, hydro_max_cap)

    PSY.add_time_series!(
        c_sys5_bat,
        hy_pump,
        PSY.SingleTimeSeries("max_active_power", tarray_power),
    )
    PSY.add_time_series!(
        c_sys5_bat,
        hy_pump,
        PSY.SingleTimeSeries("capacity", tarray_cap),
    )
    transform_single_time_series!(c_sys5_bat, Hour(24), Hour(24))

    template_uc = ProblemTemplate()
    set_device_model!(template_uc, ThermalStandard, ThermalBasicUnitCommitment)
    set_device_model!(template_uc, RenewableDispatch, RenewableFullDispatch)
    set_device_model!(template_uc, PowerLoad, StaticPowerLoad)
    set_device_model!(template_uc, RenewableNonDispatch, FixedOutput)
    set_device_model!(
        template_uc,
        DeviceModel(
            HydroPumpTurbine,
            HPS.HydroPumpEnergyDispatch;
            attributes = Dict{String, Any}(
                "reservation" => true,
                "energy_target" => true,
            ),
        ),
    )

    model = DecisionModel(
        template_uc,
        c_sys5_bat;
        optimizer = HiGHS_optimizer,
        store_variable_names = true,
    )

    @test build!(model; output_dir = output_dir) ==
          PSI.ModelBuildStatus.BUILT

    @test solve!(model; output_dir = output_dir) ==
          IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED
end

#########################################
######## HydroBlock model Tests #########
#########################################

@testset "Test Hydro Block Optimization Formulation" begin
    output_dir = mktempdir(; cleanup = true)
    modeling_horizon = 52 * 24 * 1

    sys = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_energy")
    res = first(PSY.get_components(HydroReservoir, sys))

    set_head_to_volume_factor!(res, LinearCurve(1.0))
    template_ed = ProblemTemplate(
        NetworkModel(
            CopperPlatePowerModel;
        ),
    )
    set_device_model!(template_ed, PowerLoad, StaticPowerLoad)
    set_device_model!(template_ed, ThermalStandard, ThermalDispatchNoMin)
    set_device_model!(template_ed, HydroReservoir, HydroEnergyBlockOptimization)
    set_device_model!(template_ed, HydroTurbine, HydroEnergyBlockOptimization)

    model = DecisionModel(
        template_ed,
        sys;
        name = "ED",
        optimizer = Ipopt_optimizer,
        optimizer_solve_log_print = true,
        store_variable_names = true,
        system_to_file = true,
        horizon = Hour(24),
    )

    @test build!(model; output_dir = output_dir) ==
          PSI.ModelBuildStatus.BUILT

    # @test solve!(model; optimizer = Ipopt_optimizer, output_dir = output_dir) ==
    #       IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED

    # check the second step is equal to the first step + dispatch 
end

################################################
######## HydroWaterModelReservoir TEST #########
################################################

@testset "Solve HydroWaterModelReservoir" begin
    output_dir = mktempdir(; cleanup = true)

    c_sys5_hy = PSB.build_system(PSITestSystems, "c_sys5_hy_turbine_head")

    template = ProblemTemplate()
    set_device_model!(template, HydroTurbine, HydroTurbineBilinearDispatch)
    set_device_model!(template, HydroReservoir, HydroWaterModelReservoir)

    set_device_model!(template, ThermalStandard, ThermalDispatchNoMin)
    set_device_model!(template, PowerLoad, StaticPowerLoad)

    model = DecisionModel(
        template,
        sys;
        optimizer = Ipopt_optimizer,
        store_variable_names = true,
    )

    @test build!(model; output_dir = output_dir) ==
          PSI.ModelBuildStatus.BUILT

    @test solve!(model; output_dir = output_dir) ==
          IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED

    res = OptimizationProblemResults(model)

    moi_tests(model, 240, 0, 168, 168, 72, false)
    psi_checkobjfun_test(model, AffExpr)

    df_outflow = read_expression(res, "TotalHydroFlowRateTurbineOut__HydroTurbine")
    hydro_vol_df =
        read_variables(res, [(HydroReservoirVolumeVariable, HydroReservoir)])["HydroReservoirVolumeVariable__HydroReservoir"]
    hydro_head_df =
        read_variables(res, [(HydroReservoirHeadVariable, HydroReservoir)])["HydroReservoirHeadVariable__HydroReservoir"]
    hydro_spillage_df =
        read_variables(res, [(WaterSpillageVariable, HydroReservoir)])["WaterSpillageVariable__HydroReservoir"]
    hydro_inflow_df =
        read_parameters(res, [(InflowTimeSeriesParameter, HydroReservoir)])["InflowTimeSeriesParameter__HydroReservoir"]

    total_inflow = sum(values(hydro_inflow_ts))
    total_outflow = sum(df_outflow[!, "Water_Turbine"])
    total_spillage = sum(hydro_spillage_df[!, "Water_Reservoir"])

    calculated_vf =
        (hydro_vol_df[1, "Water_Reservoir"]) +
        ((total_inflow - total_outflow - total_spillage) * 3600 * 1e-9)

    @test abs(calculated_vf - hydro_vol_df[end, "Water_Reservoir"]) <= 1e-4
    
    psi_checksolve_test(
            model,
            [MOI.OPTIMAL, MOI.ALMOST_OPTIMAL, MOI.LOCALLY_SOLVED],
            158187.86,
            1000,
        )
end
