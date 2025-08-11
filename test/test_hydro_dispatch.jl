#########################################
####### Hydro DISPATCH RUN OF RIVER BUDGET TEST ########
#########################################
@testset "Test Hydro Dispatch Run Of River Formulations " begin
    device_model = PSI.DeviceModel(HydroDispatch, HydroDispatchRunOfRiverBudget;
                                    attributes = Dict("hydro_budget_interval" => Hour(24)))

    
    sys = PSB.build_system(PSITestSystems, "c_sys5_hy")

    hy = only(get_components(HydroDispatch, sys))
    max_power = get_max_active_power(hy)
    resolution = Dates.Hour(1)
    tstamp = range(DateTime("2024-01-01T00:00:00"), step = resolution, length = 48)
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
    
    hydro_budget = 24;
    eps = 1e-6


    hy = only(get_components(HydroDispatch, c_sys5_hy))
    max_power = get_max_active_power(hy)

    tstamp = range(DateTime("2024-01-01T00:00:00"), step = Dates.Hour(1), length = 48)
    data = ones(length(tstamp)) / (get_base_power(c_sys5_hy) * max_power) 
    ts = SingleTimeSeries("hydro_budget", TimeArray(tstamp, data))
    add_time_series!(c_sys5_hy, first(get_components(HydroDispatch, c_sys5_hy)), ts)
    transform_single_time_series!(c_sys5_hy, Hour(24), Hour(24))

    template_uc = ProblemTemplate()
    set_device_model!(template_uc, ThermalStandard, ThermalBasicUnitCommitment)
    set_device_model!(template_uc, RenewableDispatch, RenewableFullDispatch)
    set_device_model!(template_uc, PowerLoad, StaticPowerLoad)
    set_device_model!(template_uc, RenewableNonDispatch, FixedOutput) 
    set_device_model!(template_uc, DeviceModel(HydroDispatch, HydroDispatchRunOfRiverBudget;
                 attributes = Dict("hydro_budget_interval" => Hour(hydro_budget))))                
    model = DecisionModel(template_uc, c_sys5_hy; optimizer = HiGHS_optimizer, store_variable_names = true)

    @test build!(model; output_dir = output_dir) ==
          PSI.ModelBuildStatus.BUILT

    @test solve!(model; output_dir = output_dir) ==
          IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED

    res = OptimizationProblemResults(model)
    hydro_power_sum = sum(read_variable(res, "ActivePowerVariable__HydroDispatch")[!, :HydroDispatch])

    @test abs(hydro_power_sum - hydro_budget) <= eps
end

#########################################
####### Hydro PUMP ENERGY DISPATCH TEST ########
#########################################
@testset "Test Hydro Pump Energy Dispatch Formulations " begin
    device_model = PSI.DeviceModel(
        HydroPumpTurbine,
        HPS.HydroPumpEnergyDispatch;
        attributes = Dict{String, Any}(
            "reservation" => true,
            "energy_target" => true,
        )
    )

    c_sys5_bat = PSB.build_system(PSITestSystems, "c_sys5_bat"; add_reserves = true)
    bat = first(PSY.get_components(EnergyReservoirStorage, c_sys5_bat))
    convert_to_hydropump!(bat, c_sys5_bat)
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

@testset "Test Hydro Pump Energy Dispatch Formulations " begin
    output_dir = mktempdir(; cleanup = true) 

    c_sys5_bat = PSB.build_system(PSITestSystems, "c_sys5_bat"; add_reserves = true)
    bat = first(PSY.get_components(EnergyReservoirStorage, c_sys5_bat))
    convert_to_hydropump!(bat, c_sys5_bat)
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
    set_device_model!(template_uc, DeviceModel(
                    HydroPumpTurbine,
                    HPS.HydroPumpEnergyDispatch;
                    attributes = Dict{String, Any}(
                    "reservation" => true,
                    "energy_target" => true,
        )
    )
    );

    model = DecisionModel(template_uc, c_sys5_bat; optimizer = HiGHS_optimizer, store_variable_names = true)

    @test build!(model; output_dir = output_dir) ==
          PSI.ModelBuildStatus.BUILT

    @test solve!(model; output_dir = output_dir) ==
          IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED
end