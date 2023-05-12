############################ Hydro Generation Formulations #################################
abstract type AbstractHydroFormulation <: AbstractDeviceFormulation end
abstract type AbstractHydroDispatchFormulation <: AbstractHydroFormulation end
abstract type AbstractHydroUnitCommitment <: AbstractHydroFormulation end
abstract type AbstractHydroReservoirFormulation <: AbstractHydroDispatchFormulation end

"""
Formulation type to add injection variables constrained by a maximum injection time series for `HydroGen`
"""
struct HydroDispatchRunOfRiver <: AbstractHydroDispatchFormulation end

"""
Formulation type to add injection variables constrained by total energy production budget defined with a time series for `HydroGen`
"""
struct HydroDispatchReservoirBudget <: AbstractHydroReservoirFormulation end

"""
Formulation type to constrain hydropower production with a representation of the energy storage capacity and water inflow time series of a reservoir for `HydroGen`
"""
struct HydroDispatchReservoirStorage <: AbstractHydroReservoirFormulation end

"""
Formulation type to constrain energy production from pumped storage with a representation of the energy storage capacity of upper and lower reservoirs and water inflow time series of upper reservoir and outflow time series of lower reservoir for `HydroPumpedStorage`
"""
struct HydroDispatchPumpedStorage <: AbstractHydroReservoirFormulation end

"""
Formulation type to add commitment and injection variables constrained by a maximum injection time series for `HydroGen`
"""
struct HydroCommitmentRunOfRiver <: AbstractHydroUnitCommitment end

"""
Formulation type to add commitment and injection variables constrained by total energy production budget defined with a time series for `HydroGen`
"""
struct HydroCommitmentReservoirBudget <: AbstractHydroUnitCommitment end

"""
Formulation type to constrain hydropower production with unit commitment variables and a representation of the energy storage capacity and water inflow time series of a reservoir for `HydroGen`
"""
struct HydroCommitmentReservoirStorage <: AbstractHydroUnitCommitment end
