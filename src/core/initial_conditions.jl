"""
Initial condition for Upper reservoir in [`PowerSystems.HydroPumpedStorage`](@extref) formulations
"""
struct InitialHydroEnergyLevelUp <: PSI.InitialConditionType end

"""
Initial condition for Down reservoir in [`PowerSystems.HydroPumpedStorage`](@extref) formulations
"""
struct InitialHydroEnergyLevelDown <: PSI.InitialConditionType end

"""
Final condition for Upper reservoir in [`PowerSystems.HydroPumpedStorage`](@extref) formulations
"""
struct FinalHydroEnergyLevelUp <: PSI.InitialConditionType end
