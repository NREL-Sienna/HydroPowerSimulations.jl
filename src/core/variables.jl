"""
Struct to dispatch the creation of energy (water) spillage variable representing energy released from a storage/reservoir not injected into the network

Docs abbreviation: ``s``
"""
struct WaterSpillageVariable <: PSI.VariableType end

"""
Struct to dispatch the creation of a variable for energy storage level (state of charge) of upper reservoir

Docs abbreviation: ``e^\\text{up}``
"""
struct HydroEnergyVariableUp <: PSI.VariableType end

"""
Struct to dispatch the creation of a variable for energy storage level (state of charge) of lower reservoir

Docs abbreviation: ``e^\\text{dn}``
"""
struct HydroEnergyVariableDown <: PSI.VariableType end

"""
Struct to dispatch the creation of a slack variable for energy storage levels < target storage levels

Docs abbreviation: ``e^\\text{shortage}``
"""
struct HydroEnergyShortageVariable <: PSI.VariableType end

"""
Struct to dispatch the creation of a slack variable for energy storage levels > target storage levels

Docs abbreviation: ``e^\\text{surplus}``
"""
struct HydroEnergySurplusVariable <: PSI.VariableType end


####

"""
Struct to dispatch the creation of a variable for turbined flowrate.
"""
struct HydroTurbineFlowrateVariable <: PSI.VariableType end

"""
Struct to dispatch the creation of a variable for volume stored in a hydro reservoir.
"""
struct HydroReservoirVolumeVariable <: PSI.VariableType end

"""
Struct to dispatch the creation of a variable spillage released by a hydro reservoir.
"""
struct HydroReservoirSpillageVariable <: PSI.VariableType end

"""
Aux variable which keeps track of total water sent out of reservoir through turbines
"""
struct ReservoirTurbinedOutflowVariable <: PSI.VariableType end

"""
Aux variable which keeps track of water level (head) of hydro reservoirs
"""
struct ReservoirHeadVariable <: PSI.VariableType end

"""
Aux variable which keeps track of controlled inflows sent into a reservoir due to upstream releases
"""
struct ReservoirControlledInflow <: PSI.ExpressionType end







# convert_result_to_natural_units(::Type{HydroEnergyVariableUp}) = true # TODO: is this pu?




"""
Auxiliary Variable for Hydro Models that solve for total energy output

Docs abbreviation: ``E^\\text{hy,out}``
"""
struct HydroEnergyOutput <: PSI.AuxVariableType end
