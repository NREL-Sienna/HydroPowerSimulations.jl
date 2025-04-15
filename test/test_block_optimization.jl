@testset "Hydro Block Optimization Begin" begin
    output_dir = mktempdir(; cleanup = true)

    modeling_horizon = 52 * 24 * 1
    sys = get_test_reservoir_turbine_sys(modeling_horizon)

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
        horizon = Hour(modeling_horizon),
    )

    @test build!(model; output_dir = output_dir) ==
          PSI.ModelBuildStatus.BUILT

    @test solve!(model; optimizer = Ipopt_optimizer, output_dir = output_dir) ==
          IS.Simulation.RunStatus.SUCCESSFULLY_FINALIZED
end
