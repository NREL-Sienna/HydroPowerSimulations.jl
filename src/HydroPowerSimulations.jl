module HydroPowerSimulations

#################################################################################
# Exports
export HydroEnergyCascade
export HydroDispatchReservoirCascade

#################################################################################
# Imports
import Revise
import PowerSystems
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
include("models/HydroEnergyCascade.jl")
include("devices_models/devices/HydroReservoirCascade.jl")
include("devices_models/device_constructors/HydroReservoirCascade_constructor.jl")
include("parsers/set_upstream.jl")

end # module
