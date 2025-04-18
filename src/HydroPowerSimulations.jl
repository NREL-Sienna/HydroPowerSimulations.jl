module HydroPowerSimulations

#################################################################################
# Exports
# export HydroEnergyCascade
# export HydroDispatchCascade
# export HydroDispatchReservoirCascade
# export HydroDispatchRunOfRiverCascade
# export HydroDispatchReservoirBudgetUpperBound
# export HydroDispatchRunOfRiverLowerBound
# export HydroDispatchReservoirBudgetLowerUpperBound

###### Hydro Decision Models #######
export MediumTermHydroPlanning

######## Hydro Formulations ########
export HydroDispatchReservoirBudget
export HydroDispatchReservoirStorage
export HydroCommitmentReservoirBudget
export HydroCommitmentReservoirStorage
export HydroDispatchPumpedStorage
export HydroDispatchRunOfRiver
export HydroCommitmentRunOfRiver
export HydroEnergyBlockOptimization
export HydroLongTermReservoir
export HydroTurbineBilinearDispatch

######## Hydro Variables ########
export HydroEnergyVariableUp
export HydroEnergyVariableDown
export WaterSpillageVariable
export HydroEnergyShortageVariable
export HydroEnergySurplusVariable
export HydroReservoirHeadVariable
export HydroReservoirVolumeVariable
export HydroTurbineFlowRateVariable

######## Hydro Aux Variables ########
export HydroEnergyOutput

######## Hydro parameters #######
export EnergyTargetTimeSeriesParameter
export EnergyBudgetTimeSeriesParameter
export InflowTimeSeriesParameter
export OutflowTimeSeriesParameter
export ReservoirTargetParameter
export ReservoirLimitParameter
export HydroUsageLimitParameter

######## Hydro Initial Conditions #######
export InitialHydroEnergyLevelUp
export InitialHydroEnergyLevelDown

######## Hydro Constraints #######
export EnergyTargetConstraint
export EnergyCapacityDownConstraint
export EnergyCapacityUpConstraint
export EnergyBudgetConstraint
export ReservoirLevelLimitConstraint
export ReservoirLevelTargetConstraint
export TurbinePowerOutputConstraint
export ReservoirHeadToVolumeConstraint
export ReservoirInventoryConstraint

######## Hydro feedforwards #######
export ReservoirTargetFeedforward
export ReservoirLimitFeedforward
export HydroUsageLimitFeedforward

######## Hydro Expressions #######
export ReserveRangeExpressionLB
export ReserveRangeExpressionUB

#################################################################################
# Imports
using PowerSystems
import InfrastructureSystems
import Dates
import PowerSimulations
import JuMP

const PSY = PowerSystems
const IS = InfrastructureSystems
const ISSIM = InfrastructureSystems.Simulation
const ISOPT = InfrastructureSystems.Optimization
const PSI = PowerSimulations
# Import PM types this way to avoid dependency issues with PowerSimulations
const PM = PowerSimulations.PM

# import PowerSimulations: HydroDispatchRunOfRiver, HydroCommitmentRunOfRiver
# import PowerSimulations: HydroCommitmentRunOfRiver
# export HydroCommitmentRunOfRiver
# export HydroDispatchRunOfRiver

#################################################################################
# Includes
# Core includes
include("core/definitions.jl")
include("core/formulations.jl")
include("core/variables.jl")
include("core/constraints.jl")
include("core/expressions.jl")
include("core/parameters.jl")
include("core/initial_conditions.jl")
include("core/decision_models.jl")

# Models
include("hydro_generation.jl")
include("hydrogeneration_constructor.jl")
include("hydro_decision_model.jl")
include("feedforwards.jl")

end # module
