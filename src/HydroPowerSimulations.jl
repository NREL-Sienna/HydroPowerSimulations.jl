module HydroPowerSimulations

#################################################################################
# Exports
export HydroEnergyCascade
export HydroDispatchCascade
export HydroDispatchReservoirCascade
export HydroDispatchRunOfRiverCascade

#################################################################################
# Imports
using PowerSystems
import InfrastructureSystems
import Dates
import TimeZones
import PowerSimulations
import PowerModels
import JuMP
import Cbc
import CSV
import DataFrames
import ParameterJuMP

const PSY = PowerSystems
const IS = InfrastructureSystems
const PM = PowerModels
const PSI = PowerSimulations
const PJ = ParameterJuMP

#################################################################################
# Includes
include("models/HydroCascade.jl")
include("models/generated/includes.jl")
include("devices_models/devices/HydroReservoirCascade.jl")
include("devices_models/devices/HydroDispatchCascade.jl")
include("devices_models/device_constructors/HydroReservoirCascade_constructor.jl")
include("devices_models/device_constructors/HydroDispatchCascade_constructor.jl")
include("parsers/set_upstream.jl")

end # module
