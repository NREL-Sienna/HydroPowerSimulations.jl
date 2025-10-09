"""
Expression for [`PowerSystems.HydroGen`](@extref) that keep track
of served reserve up for energy calculations
"""
struct HydroServedReserveUpExpression <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.HydroGen`](@extref) that keep track
of served reserve down for energy calculations
"""
struct HydroServedReserveDownExpression <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.HydroReservoir](@extref) that keep track
of total power into a reservoir, from all the upstream turbines connected to it
"""
struct TotalHydroPowerReservoirIn <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.HydroReservoir](@extref) that keep track
of total power out of a reservoir, from all the downstream turbines connected to it
"""
struct TotalHydroPowerReservoirOut <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.HydroReservoir](@extref) that keep track
of total spillage power into a reservoir, from all the upstream reservoirs connected to it
"""
struct TotalSpillagePowerReservoirIn <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.HydroReservoir`](@extref) that keep track
of total water flow turbined into a reservoir, from all the upstream turbines connected to it
"""
struct TotalHydroFlowRateReservoirIn <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.HydroReservoir`](@extref) that keep track
of total water turbined for a reservoir, from all the downstream turbines connected to it
"""
struct TotalHydroFlowRateReservoirOut <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.HydroReservoir](@extref) that keep track
of total spillage water flow rate into a reservoir, from all the upstream reservoirs connected to it
"""
struct TotalSpillageFlowRateReservoirIn <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.HydroGen`](@extref) that keep track
of total water turbined for a turbine, coming from multiple reservoirs
"""
struct TotalHydroFlowRateTurbineOut <: PSI.ExpressionType end

"""
Expression for [`PowerSystems.System`](@extref) that keep track
of the energy balance for the system in medium term planning
"""
struct EnergyBalanceExpression <: PSI.ExpressionType end

PSI.should_write_resulting_value(::Type{HydroServedReserveUpExpression}) = true
PSI.should_write_resulting_value(::Type{HydroServedReserveDownExpression}) = true
PSI.should_write_resulting_value(::Type{TotalHydroFlowRateReservoirOut}) = true
PSI.should_write_resulting_value(::Type{TotalHydroFlowRateTurbineOut}) = true
