struct ReserveRangeExpressionLB <: PSI.RangeConstraintLBExpressions end
struct ReserveRangeExpressionUB <: PSI.RangeConstraintUBExpressions end

PSI.should_write_resulting_value(::Type{ReserveRangeExpressionUB}) = true
PSI.should_write_resulting_value(::Type{ReserveRangeExpressionLB}) = true
