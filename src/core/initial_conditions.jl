"""
Initial condition for Upper reservoir in [`PowerSystems.HydroPumpedStorage`](@extref) formulations
"""
struct InitialHydroEnergyLevelUp <: PSI.InitialConditionType end

"""
Initial condition for Down reservoir in [`PowerSystems.HydroReservoir`](@extref) formulations
"""

struct InitialHydroEnergyLevelDown <: PSI.InitialConditionType end
