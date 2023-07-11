"""
Struct to dispatch the creation of energy (water) spillage variable representing energy released from a storage/reservoir not injected into the network

Docs abbreviation: ``S``
"""
struct WaterSpillageVariable <: PSI.VariableType end

# convert_result_to_natural_units(::Type{WaterSpillageVariable }) = true # TODO: is this pu?
