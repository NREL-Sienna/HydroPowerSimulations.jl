"""
Initial condition for Upper reservoir in HydroPumpedStorage formulations
"""
struct InitialHydroEnergyLevelUp <: PSI.InitialConditionType end

"""
Initial condition for Down reservoir in HydroPumpedStorage formulations
"""
struct InitialHydroEnergyLevelDown <: PSI.InitialConditionType end
