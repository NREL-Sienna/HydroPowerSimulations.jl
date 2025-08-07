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
    c_sys5_hyd = new_c_sys5_hyd()

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
    c_sys5_hyd = new_c_sys5_hyd()

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
    c_sys5_hyd = new_c_sys5_hyd()

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
    c_sys5_hyd = new_c_sys5_hyd()

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
    c_sys5_hyd = new_c_sys5_hyd()

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
    c_sys5_hyd = new_c_sys5_hyd()

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

#########################################
###### RESERVOIR SYSTEM TESTS ###########
#########################################

@testset "Solving ED Hydro System using Dispatch with Reservoir" begin
    sys = new_c_sys5_hyd()
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
    sys = new_c_sys5_hyd()
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
