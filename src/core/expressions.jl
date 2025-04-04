"""
Expression for [`PowerSystems.HydroPumpedStorage`](@extref) that keep track
of active power and reserves for Lower Bound limits
"""
struct ReserveRangeExpressionLB <: PSI.RangeConstraintLBExpressions end
"""
Expression for [`PowerSystems.HydroPumpedStorage`](@extref) that keep track
of active power and reserves for Upper Bound limits
"""
struct ReserveRangeExpressionUB <: PSI.RangeConstraintUBExpressions end

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

PSI.should_write_resulting_value(::Type{ReserveRangeExpressionUB}) = true
PSI.should_write_resulting_value(::Type{ReserveRangeExpressionLB}) = true
PSI.should_write_resulting_value(::Type{HydroServedReserveUpExpression}) = true
PSI.should_write_resulting_value(::Type{HydroServedReserveDownExpression}) = true
