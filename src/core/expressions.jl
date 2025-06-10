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
Expression for [`PowerSystems.HydroGen`](@extref) that keep track
of total water turbined for a reservoir, from all the turbines connected to it
"""
struct TotalHydroFlowRateReservoirOut <: PSI.ExpressionType end

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
