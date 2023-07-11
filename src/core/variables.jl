"""
Struct to dispatch the creation of energy (water) spillage variable representing energy released from a storage/reservoir not injected into the network

Docs abbreviation: ``S``
"""
struct WaterSpillageVariable <: PSI.VariableType end

"""
Struct to dispatch the creation of a variable for energy storage level (state of charge) of upper reservoir

Docs abbreviation: ``E^{up}``
"""
struct EnergyVariableUp <: PSI.VariableType end

"""
Struct to dispatch the creation of a variable for energy storage level (state of charge) of lower reservoir

Docs abbreviation: ``E^{down}``
"""
struct EnergyVariableDown <: PSI.VariableType end

"""
Struct to dispatch the creation of a slack variable for energy storage levels < target storage levels

Docs abbreviation: ``E^{shortage}``
"""
struct EnergyShortageVariable <: PSI.VariableType end

"""
Struct to dispatch the creation of a slack variable for energy storage levels > target storage levels

Docs abbreviation: ``E^{surplus}``
"""
struct EnergySurplusVariable <: PSI.VariableType end

# convert_result_to_natural_units(::Type{WaterSpillageVariable }) = true # TODO: is this pu?
