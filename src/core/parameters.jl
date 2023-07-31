"""
Parameter to define energy storage target level time series
"""
struct EnergyTargetTimeSeriesParameter <: PSI.TimeSeriesParameter end

"""
Parameter to define energy budget time series
"""
struct EnergyBudgetTimeSeriesParameter <: PSI.TimeSeriesParameter end

"""
Parameter to define energy inflow to storage or reservoir time series
"""
struct InflowTimeSeriesParameter <: PSI.TimeSeriesParameter end

"""
Parameter to define energy outflow from storage or reservoir time series
"""
struct OutflowTimeSeriesParameter <: PSI.TimeSeriesParameter end

"""
Parameter to define energy target
"""
struct EnergyTargetParameter <: PSI.VariableValueParameter end

PSI.convert_result_to_natural_units(::Type{EnergyTargetTimeSeriesParameter}) = true
PSI.convert_result_to_natural_units(::Type{EnergyBudgetTimeSeriesParameter}) = true
PSI.convert_result_to_natural_units(::Type{EnergyTargetParameter}) = true
PSI.convert_result_to_natural_units(::Type{InflowTimeSeriesParameter}) = true # TODO: is this pu?
PSI.convert_result_to_natural_units(::Type{OutflowTimeSeriesParameter}) = true # TODO: is this pu?
