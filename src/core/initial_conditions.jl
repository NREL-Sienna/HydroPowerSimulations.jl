"""
Initial condition for Upper reservoir in [`PowerSystems.HydroPumpedStorage`](@extref) formulations
"""
struct InitialHydroEnergyLevelUp <: PSI.InitialConditionType end

"""
Initial condition for Down reservoir in [`PowerSystems.HydroPumpedStorage`](@extref) formulations
"""
struct InitialHydroEnergyLevelDown <: PSI.InitialConditionType end

"""
Initial condition for volume in reservoir in [`PowerSystems.HydroReservoir`](@extref) formulations
"""
struct InitialReservoirVolume <: PSI.InitialConditionType end

"""
Initial condition for head in reservoir in [`PowerSystems.HydroReservoir`](@extref) formulations
"""
struct InitialReservoirHead <: PSI.InitialConditionType end
