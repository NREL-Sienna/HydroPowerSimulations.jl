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

######## Hydro Variables ########
export EnergyVariableUp
export WaterSpillageVariable

######## Hydro parameters #######
export EnergyTargetParameter

#################################################################################
# Imports
using PowerSystems
import InfrastructureSystems
import Dates
import PowerSimulations
import PowerModels
import JuMP
import CSV
import DataFrames

const PSY = PowerSystems
const IS = InfrastructureSystems
const PM = PowerModels
const PSI = PowerSimulations

import PowerSimulations: HydroDispatchRunOfRiver, HydroCommitmentRunOfRiver
export HydroCommitmentRunOfRiver
export HydroDispatchRunOfRiver

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
