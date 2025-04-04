############################ Hydro Generation Formulations #################################
# Defined in PSI copied here for reference
# abstract type PSI.AbstractHydroFormulation <: PSI.AbstractDeviceFormulation end
# abstract type PSI.AbstractHydroDispatchFormulation <: PSI.AbstractHydroFormulation end
# abstract type PSI.AbstractHydroUnitCommitment <: PSI.AbstractHydroFormulation end

abstract type AbstractHydroFormulation <: PSI.AbstractDeviceFormulation end
abstract type AbstractHydroDispatchFormulation <: AbstractHydroFormulation end
abstract type AbstractHydroReservoirFormulation <: AbstractHydroDispatchFormulation end
abstract type AbstractHydroUnitCommitment <: AbstractHydroFormulation end

"""
Formulation type to add injection variables constrained by total energy production budget defined with a time series for [`PowerSystems.HydroGen`](@extref)
"""
struct HydroDispatchReservoirBudget <: AbstractHydroReservoirFormulation end

"""
Formulation type to constrain hydropower production with a representation of the energy storage capacity and water inflow time series of a reservoir for [`PowerSystems.HydroGen`](@extref)
"""
struct HydroDispatchReservoirStorage <: AbstractHydroReservoirFormulation end

"""
Formulation type to constrain energy production from pumped storage with a representation of the energy storage capacity of upper and lower reservoirs and water inflow time series of upper reservoir and outflow time series of lower reservoir for [`PowerSystems.HydroPumpedStorage`](@extref)
"""
struct HydroDispatchPumpedStorage <: AbstractHydroReservoirFormulation end

"""
Formulation type to add injection variables constrained by a maximum injection time series for [`PowerSystems.HydroGen`](@extref)
"""
struct HydroDispatchRunOfRiver <: AbstractHydroDispatchFormulation end

"""
Formulation type to add commitment and injection variables constrained by total energy production budget defined with a time series for [`PowerSystems.HydroGen`](@extref)
"""
struct HydroCommitmentReservoirBudget <: AbstractHydroReservoirFormulation end

"""
Formulation type to constrain hydropower production with unit commitment variables and a representation of the energy storage capacity and water inflow time series of a reservoir for [`PowerSystems.HydroGen`](@extref)
"""
struct HydroCommitmentReservoirStorage <: AbstractHydroReservoirFormulation end

"""
Formulation type to add commitment and injection variables constrained by a maximum injection time series for [`PowerSystems.HydroGen`](@extref)
"""
struct HydroCommitmentRunOfRiver <: AbstractHydroUnitCommitment end

"""
Formulation type to add commitment and injection variables constrained by a maximum injection time series for [`PowerSystems.HydroGen`](@extref)
"""
struct HydroReservoirRunOfRiver <: AbstractHydroUnitCommitment end

"""
Formulation type to add reservoir methods with hydro turbines for [`PowerSystems.HydroGen`](@extref)
"""
struct HydroLongTermReservoir <: AbstractHydroReservoirFormulation end

"""
Formulation type to add injection variables for a HydroTurbine connected to reservoirs using a bilinear model [`PowerSystems.HydroGen`](@extref)
"""
struct HydroTurbineBilinearDispatch <: AbstractHydroDispatchFormulation end
