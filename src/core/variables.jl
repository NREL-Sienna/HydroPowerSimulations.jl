"""
Struct to dispatch the creation of energy (water) spillage variable representing energy released from a storage/reservoir not injected into the network

Docs abbreviation: ``S``
"""
struct WaterSpillageVariable <: PSI.VariableType end

"""
Struct to dispatch the creation of a variable for energy storage level (state of charge) of upper reservoir

Docs abbreviation: ``E^{up}``
"""
struct HydroEnergyVariableUp <: PSI.VariableType end

"""
Struct to dispatch the creation of a variable for energy storage level (state of charge) of lower reservoir

Docs abbreviation: ``E^{down}``
"""
struct HydroEnergyVariableDown <: PSI.VariableType end

"""
Struct to dispatch the creation of a slack variable for energy storage levels < target storage levels

Docs abbreviation: ``E^{shortage}``
"""
struct HydroEnergyShortageVariable <: PSI.VariableType end

"""
Struct to dispatch the creation of a slack variable for energy storage levels > target storage levels

Docs abbreviation: ``E^{surplus}``
"""
struct HydroEnergySurplusVariable <: PSI.VariableType end

# convert_result_to_natural_units(::Type{HydroEnergyVariableUp}) = true # TODO: is this pu?

"""
Auxiliary Variable for Hydro Models that solve for total energy output
"""
struct HydroEnergyOutput <: PSI.AuxVariableType end
