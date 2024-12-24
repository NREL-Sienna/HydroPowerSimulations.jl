"""
Expression for HydroPumpedStorage that keep track
of active power and reserves for Lower Bound limits
"""
struct ReserveRangeExpressionLB <: PSI.RangeConstraintLBExpressions end
"""
Expression for HydroPumpedStorage that keep track
of active power and reserves for Upper Bound limits
"""
struct ReserveRangeExpressionUB <: PSI.RangeConstraintUBExpressions end

PSI.should_write_resulting_value(::Type{ReserveRangeExpressionUB}) = true
PSI.should_write_resulting_value(::Type{ReserveRangeExpressionLB}) = true
