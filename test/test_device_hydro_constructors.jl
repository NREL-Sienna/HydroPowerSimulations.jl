#########################################
#### RESERVOIR BUDGET DISPATCH TESTS ####
#########################################

@testset "Hydro DCPLossLess HydroEnergyReservoir with HydroDispatchReservoirBudget Formulations" begin
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyDispatch)
    reservoir_model = DeviceModel(
        HydroReservoir,
        HydroEnergyModelReservoir;
        attributes = Dict{String, Any}(
            "energy_target" => false,
            "hydro_budget" => true,
        ),
    )
    c_sys5_hyd = new_c_sys5_hyd()

    # No Parameters Testing
    model = DecisionModel(MockOperationProblem, DCPPowerModel, c_sys5_hyd)
    mock_construct_device!(model, turbine_model)
    mock_construct_device!(model, reservoir_model)
    moi_tests(model, 120, 0, 25, 24, 24, false)
    psi_checkobjfun_test(model, GAEVF)
end

@testset "Hydro ACPPowerModel HydroEnergyReservoir with HydroDispatchReservoirBudget Formulations" begin
    turbine_model = PSI.DeviceModel(HydroTurbine, HydroTurbineEnergyDispatch)
    reservoir_model = DeviceModel(
        HydroReservoir,
        HydroEnergyModelReservoir;
        attributes = Dict{String, Any}(
            "energy_target" => false,
            "hydro_budget" => true,
        ),
    )
    c_sys5_hyd = new_c_sys5_hyd()

    # No Parameters Testing
    model = DecisionModel(MockOperationProblem, ACPPowerModel, c_sys5_hyd)
    mock_construct_device!(model, turbine_model)
    mock_construct_device!(model, reservoir_model)
    moi_tests(model, 144, 0, 49, 48, 24, false)
    psi_checkobjfun_test(model, GAEVF)
end
