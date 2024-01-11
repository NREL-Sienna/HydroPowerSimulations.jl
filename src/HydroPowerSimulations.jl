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

######## Hydro Formulations ########
export HydroDispatchReservoirBudget
export HydroDispatchReservoirStorage
export HydroCommitmentReservoirBudget
export HydroCommitmentReservoirStorage
export HydroDispatchPumpedStorage
export HydroDispatchRunOfRiver
export HydroCommitmentRunOfRiver

######## Hydro Variables ########
export HydroEnergyVariableUp
export WaterSpillageVariable
export HydroEnergyShortageVariable

######## Hydro Aux Variables ########
export HydroEnergyOutput

######## Hydro parameters #######
export ReservoirTargetParameter
export ReservoirLimitParameter

######## Hydro Initial Conditions #######
export InitialHydroEnergyLevelUp
export InitialHydroEnergyLevelDown

######## Hydro feedforwards #######
export ReservoirTargetFeedforward
export ReservoirLimitFeedforward

#################################################################################
# Imports
using PowerSystems
import InfrastructureSystems
import Dates
import PowerSimulations
import JuMP

const PSY = PowerSystems
const IS = InfrastructureSystems
const PM = PowerSimulations.PM

# import PowerSimulations: HydroDispatchRunOfRiver, HydroCommitmentRunOfRiver
# import PowerSimulations: HydroCommitmentRunOfRiver
# export HydroCommitmentRunOfRiver
# export HydroDispatchRunOfRiver

#################################################################################
# Includes
# Core includes
include("core/formulations.jl")
include("core/variables.jl")
include("core/constraints.jl")
include("core/expressions.jl")
include("core/parameters.jl")
include("core/initial_conditions.jl")

# Models
include("hydro_generation.jl")
include("hydrogeneration_constructor.jl")
include("feedforwards.jl")

end # module
