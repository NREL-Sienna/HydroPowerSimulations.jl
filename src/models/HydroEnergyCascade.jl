mutable struct HydroEnergyCascade <: PSY.HydroGen
    name::String
    available::Bool
    bus::PSY.Bus
    active_power::Float64
    reactive_power::Float64
    "Thermal limited MVA Power Output of the unit. <= Capacity"
    rating::Float64
    "prime_mover Technology according to EIA 923"
    prime_mover::PSY.PrimeMovers.PrimeMover
    active_power_limits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
    reactive_power_limits::Union{Nothing, PSY.Min_Max}
    "ramp up and ramp down limits in MW (in component base per unit) per minute"
    ramp_limits::Union{Nothing, NamedTuple{(:up, :down), Tuple{Float64, Float64}}}
    "Minimum up and Minimum down time limits in hours"
    time_limits::Union{Nothing, NamedTuple{(:up, :down), Tuple{Float64, Float64}}}
    "Operation Cost of Generation [`TwoPartCost`](@ref)"
    operation_cost::PSY.TwoPartCost
    "Base power of the unit in MVA"
    base_power::Float64
    "Maximum storage capacity in the reservoir (units can be p.u-hr or m^3)."
    storage_capacity::Float64
    "Baseline inflow into the reservoir (units can be p.u. or m^3/hr)"
    inflow::Float64
    "Initial storage capacity in the reservoir (units can be p.u-hr or m^3)."
    initial_storage::Float64
    "Storage target at the end of simulation as ratio of storage capacity."
    storage_target::Float64
    "Conversion factor from flow/volume to energy: m^3 -> p.u-hr."
    conversion_factor::Float64
    "Upstream units"
    upstream::Vector{HydroEnergyCascade}
    "Services that this device contributes to"
    services::Vector{PSY.Service}
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, PSY.DynamicInjection}
    ext::Dict{String, Any}
    "internal forecast storage"
    forecasts::IS.Forecasts
    "power system internal reference, do not modify"
    internal::IS.InfrastructureSystemsInternal
end

function HydroEnergyCascade(name, available, bus, active_power, reactive_power, rating, prime_mover, active_power_limits, reactive_power_limits, ramp_limits, time_limits, operation_cost, base_power, storage_capacity, inflow, initial_storage, storage_target=1.0, conversion_factor=1.0, upstream=HydroEnergyCascade[], services=PSY.Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), forecasts=InfrastructureSystems.Forecasts(), )
    HydroEnergyCascade(name, available, bus, active_power, reactive_power, rating, prime_mover, active_power_limits, reactive_power_limits, ramp_limits, time_limits, operation_cost, base_power, storage_capacity, inflow, initial_storage, storage_target, conversion_factor, upstream, services, dynamic_injector, ext, forecasts, IS.InfrastructureSystemsInternal(), )
end

function HydroEnergyCascade(; name, available, bus, active_power, reactive_power, rating, prime_mover, active_power_limits, reactive_power_limits, ramp_limits, time_limits, operation_cost, base_power, storage_capacity, inflow, initial_storage, storage_target=1.0, conversion_factor=1.0, upstream=HydroEnergyCascade[], services=PSY.Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), forecasts=InfrastructureSystems.Forecasts(), )
    HydroEnergyCascade(name, available, bus, active_power, reactive_power, rating, prime_mover, active_power_limits, reactive_power_limits, ramp_limits, time_limits, operation_cost, base_power, storage_capacity, inflow, initial_storage, storage_target, conversion_factor, upstream, services, dynamic_injector, ext, forecasts, )
end

IS.get_name(value::HydroEnergyCascade) = value.name
"""Get HydroEnergyReservoir available."""
PSY.get_available(value::HydroEnergyCascade) = value.available
"""Get HydroEnergyReservoir bus."""
PSY.get_bus(value::HydroEnergyCascade) = value.bus
"""Get HydroEnergyReservoir active_power."""
PSY.get_active_power(value::HydroEnergyCascade) = value.active_power
"""Get HydroEnergyReservoir reactive_power."""
PSY.get_reactive_power(value::HydroEnergyCascade) = value.reactive_power
"""Get HydroEnergyReservoir rating."""
PSY.get_rating(value::HydroEnergyCascade) = value.rating
"""Get HydroEnergyReservoir prime_mover."""
PSY.get_prime_mover(value::HydroEnergyCascade) = value.prime_mover
"""Get HydroEnergyReservoir active_power_limits."""
PSY.get_active_power_limits(value::HydroEnergyCascade) = value.active_power_limits
"""Get HydroEnergyReservoir reactive_power_limits."""
PSY.get_reactive_power_limits(value::HydroEnergyCascade) = value.reactive_power_limits
"""Get HydroEnergyReservoir ramp_limits."""
PSY.get_ramp_limits(value::HydroEnergyCascade) = value.ramp_limits
"""Get HydroEnergyReservoir time_limits."""
PSY.get_time_limits(value::HydroEnergyCascade) = value.time_limits
"""Get HydroEnergyReservoir operation_cost."""
PSY.get_operation_cost(value::HydroEnergyCascade) = value.operation_cost
"""Get HydroEnergyReservoir base_power."""
PSY.get_base_power(value::HydroEnergyCascade) = value.base_power
"""Get HydroEnergyReservoir storage_capacity."""
PSY.get_storage_capacity(value::HydroEnergyCascade) = value.storage_capacity
"""Get HydroEnergyReservoir inflow."""
PSY.get_inflow(value::HydroEnergyCascade) = value.inflow
"""Get HydroEnergyReservoir initial_storage."""
PSY.get_initial_storage(value::HydroEnergyCascade) = value.initial_storage
"""Get HydroEnergyReservoir storage_target."""
PSY.get_storage_target(value::HydroEnergyCascade) = value.storage_target
"""Get HydroEnergyReservoir conversion_factor."""
PSY.get_conversion_factor(value::HydroEnergyCascade) = value.conversion_factor
"""Get HydroEnergyReservoir upstream."""
get_upstream(value::HydroEnergyCascade) = value.upstream
"""Get HydroEnergyReservoir services."""
get_services(value::HydroEnergyCascade) = value.services
"""Get HydroEnergyReservoir dynamic_injector."""
get_dynamic_injector(value::HydroEnergyCascade) = value.dynamic_injector
"""Get HydroEnergyReservoir ext."""
get_ext(value::HydroEnergyCascade) = value.ext

InfrastructureSystems.get_forecasts(value::HydroEnergyCascade) = value.forecasts
"""Get HydroEnergyReservoir internal."""
get_internal(value::HydroEnergyCascade) = value.internal


InfrastructureSystems.set_name!(value::HydroEnergyCascade, val) = value.name = val
"""Set HydroEnergyReservoir available."""
set_available!(value::HydroEnergyCascade, val) = value.available = val
"""Set HydroEnergyReservoir bus."""
set_bus!(value::HydroEnergyCascade, val) = value.bus = val
"""Set HydroEnergyReservoir active_power."""
set_active_power!(value::HydroEnergyCascade, val) = value.active_power = val
"""Set HydroEnergyReservoir reactive_power."""
set_reactive_power!(value::HydroEnergyCascade, val) = value.reactive_power = val
"""Set HydroEnergyReservoir rating."""
set_rating!(value::HydroEnergyCascade, val) = value.rating = val
"""Set HydroEnergyReservoir prime_mover."""
set_prime_mover!(value::HydroEnergyCascade, val) = value.prime_mover = val
"""Set HydroEnergyReservoir active_power_limits."""
set_active_power_limits!(value::HydroEnergyCascade, val) = value.active_power_limits = val
"""Set HydroEnergyReservoir reactive_power_limits."""
set_reactive_power_limits!(value::HydroEnergyCascade, val) = value.reactive_power_limits = val
"""Set HydroEnergyReservoir ramp_limits."""
set_ramp_limits!(value::HydroEnergyCascade, val) = value.ramp_limits = val
"""Set HydroEnergyReservoir time_limits."""
set_time_limits!(value::HydroEnergyCascade, val) = value.time_limits = val
"""Set HydroEnergyReservoir operation_cost."""
set_operation_cost!(value::HydroEnergyCascade, val) = value.operation_cost = val
"""Set HydroEnergyReservoir base_power."""
set_base_power!(value::HydroEnergyCascade, val) = value.base_power = val
"""Set HydroEnergyReservoir storage_capacity."""
set_storage_capacity!(value::HydroEnergyCascade, val) = value.storage_capacity = val
"""Set HydroEnergyReservoir inflow."""
set_inflow!(value::HydroEnergyCascade, val) = value.inflow = val
"""Set HydroEnergyReservoir initial_storage."""
set_initial_storage!(value::HydroEnergyCascade, val) = value.initial_storage = val
"""Set HydroEnergyReservoir storage_target."""
set_storage_target!(value::HydroEnergyCascade, val) = value.storage_target = val
"""Set HydroEnergyReservoir conversion_factor."""
set_conversion_factor!(value::HydroEnergyCascade, val) = value.conversion_factor = val
"""Set HydroEnergyReservoir upstream."""
set_upstream!(value::HydroEnergyCascade, val) = value.upstream = val
"""Set HydroEnergyReservoir services."""
set_services!(value::HydroEnergyCascade, val) = value.services = val
"""Set HydroEnergyReservoir ext."""
set_ext!(value::HydroEnergyCascade, val) = value.ext = val

InfrastructureSystems.set_forecasts!(value::HydroEnergyCascade, val) = value.forecasts = val
"""Set HydroEnergyReservoir internal."""
set_internal!(value::HydroEnergyCascade, val) = value.internal = val