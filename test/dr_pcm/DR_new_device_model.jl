using Pkg
# Pkg.activate("test")
# Pkg.instantiate()
# Pkg.add("LaTeXStrings")
using Revise
using PowerSystems
using PowerSimulations
using PowerSystemCaseBuilder
using PowerNetworkMatrices
using HydroPowerSimulations
using StorageSystemsSimulations
using DataFrames
using CSV
using Dates
using InfrastructureSystems
using Test
using Logging
using HiGHS
using JuMP
using Ipopt
using TimeSeries
using Statistics
using Plots
using LaTeXStrings

const PSY = PowerSystems
const PSI = PowerSimulations
const PSB = PowerSystemCaseBuilder
const IS = InfrastructureSystems
const PM = PSI.PM
const PNM = PowerNetworkMatrices
HiGHS_optimizer = HiGHS.Optimizer
Ipopt_optimizer = Ipopt.Optimizer

mip_gap = 0.0135

include("utils_sim.jl")
include("validation_plots_f.jl")

optimizer = optimizer_with_attributes(
                Ipopt_optimizer,
                )
                
sys = System("rd_system_storage_Pizarrete.json") # Load system 

batteries_v =  get_components( x -> x.rating > 0.0, EnergyReservoirStorage, sys )
number_bess = length( collect( batteries_v ) )
if number_bess == 0
    rating_cap_str = "_0_0"
else
    rating_cap_str = get_complete_bess_str( sys )
    rating_cap_str = rating_cap_str * "-$(number_bess)bess"
end

transform_single_time_series!(sys, Hour(48), Day(1))#

template_uc =
    ProblemTemplate(
        NetworkModel(PTDFPowerModel;#CopperPlatePowerModel  #PTDFPowerModel
        reduce_radial_branches = false,
        use_slacks = true #true
        ),
    )

set_device_model!(template_uc, ThermalStandard, ThermalStandardUnitCommitment)
set_device_model!(template_uc, PowerLoad, StaticPowerLoad)
set_device_model!(template_uc, HydroDispatch, HydroDispatchRunOfRiver) #HydroDispatchRunOfRiver
set_device_model!(template_uc, RenewableDispatch, RenewableFullDispatch)
set_device_model!(template_uc, DeviceModel(Line, StaticBranch;
                    use_slacks = true)) #true
set_device_model!(template_uc, DeviceModel(Transformer2W,
                        StaticBranch; use_slacks = true)) #true

#---- STORAGE, RESERVAS E INTERFACES ----
storage_model = DeviceModel(
     EnergyReservoirStorage,
     StorageDispatchWithReserves;
     attributes=Dict(
         "reservation" => false,
         "cycling_limits" => false,
         "energy_target" => false,
         "complete_coverage" => false,
         "regularization" => true
     ),
 )
 set_device_model!(template_uc, storage_model)

set_service_model!(
    template_uc,
    ServiceModel(VariableReserve{ReserveUp}, RangeReserve) #; use_slacks = true),
)
set_service_model!(
    template_uc,
    ServiceModel(VariableReserve{ReserveDown}, RangeReserve) #; use_slacks = true),
)

#=
set_service_model!(
    template_uc,
    TransmissionInterface, 
    ConstantMaxInterfaceFlow
)=#

model = DecisionModel(
    template_uc,
    sys;
    name = "UC",
    optimizer = optimizer,
    system_to_file = false,
    initialize_model = true,
    check_numerical_bounds = false,
    optimizer_solve_log_print = true,
    direct_mode_optimizer = false,
    rebuild_model = false,
    store_variable_names = true,
    calculate_conflict = true,
)

models = SimulationModels(
    decision_models = [model],
)

DA_sequence = SimulationSequence(
    models = models,
    ini_cond_chronology = InterProblemChronology(),
)

initial_date = "2024-01-01"
steps_sim    = 365
current_date = string( today() )
sim = Simulation(
    name = current_date * "_DR" * "_" * rating_cap_str * "_" * string(steps_sim) * "steps",
    steps = steps_sim,
    models = models,
    initial_time = DateTime(string(initial_date,"T00:00:00")),
    sequence = DA_sequence,
    simulation_folder = "."#tempdir()#".",
)

build!(sim; console_level = Logging.Info)
execute!(sim)

results = SimulationResults(sim)
uc      = get_decision_problem_results(results, "UC")

execute_validation_plots(sys, uc)

#using PowerGraphics
#using PowerAnalytics

#plot_fuel(uc)

#x = df_load[:, 1]
#plot()
# Add each column to the plot 
#for col in names(df_load)[2:end] 
#    plot!(x, df_load[:, col]) 
#end
#plot!()

