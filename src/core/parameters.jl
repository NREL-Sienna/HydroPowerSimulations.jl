"""
Parameter to define energy storage target level time series for hydro generators
"""
struct EnergyTargetTimeSeriesParameter <: PSI.TimeSeriesParameter end

"""
Parameter to define energy budget time series for hydro generators
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
Parameter to define energy target for feedforward
"""
struct ReservoirTargetParameter <: PSI.VariableValueParameter end
"""
Parameter to define energy limit for feedforward
"""
struct ReservoirLimitParameter <: PSI.VariableValueParameter end

"""
Parameter to define energy usage limit for feedforward
"""
struct HydroUsageLimitParameter <: PSI.VariableValueParameter end

"""
Parameter to define the level target for feedforward
"""
struct LevelTargetParameter <: PSI.VariableValueParameter end

convert_result_to_natural_units(::Type{ReservoirLimitParameter}) = true
convert_result_to_natural_units(::Type{ReservoirTargetParameter}) = true

PSI.convert_result_to_natural_units(::Type{EnergyTargetTimeSeriesParameter}) = true
PSI.convert_result_to_natural_units(::Type{EnergyBudgetTimeSeriesParameter}) = true
PSI.convert_result_to_natural_units(::Type{ReservoirTargetParameter}) = true
PSI.convert_result_to_natural_units(::Type{InflowTimeSeriesParameter}) = true # TODO: is this pu?
PSI.convert_result_to_natural_units(::Type{OutflowTimeSeriesParameter}) = true # TODO: is this pu?
