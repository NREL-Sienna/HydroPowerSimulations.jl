#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct HydroDispatchCascade <: HydroCascade
        name::String
        available::Bool
        bus::PSY.Bus
        active_power::Float64
        reactive_power::Float64
        rating::Float64
        prime_mover::PSY.PrimeMovers.PrimeMover
        active_power_limits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
        reactive_power_limits::Union{Nothing, PSY.Min_Max}
        ramp_limits::Union{Nothing, NamedTuple{(:up, :down), Tuple{Float64, Float64}}}
        time_limits::Union{Nothing, NamedTuple{(:up, :down), Tuple{Float64, Float64}}}
        base_power::Float64
        operation_cost::PSY.OperationalCost
        storage_target::Float64
        conversion_factor::Float64
        upstream::Vector{NamedTuple{(:unit, :lag, :multiplier), Tuple{PSY.HydroGen, Int64, Float64}}}
        services::Vector{PSY.Service}
        dynamic_injector::Union{Nothing, PSY.DynamicInjection}
        ext::Dict{String, Any}
        forecasts::InfrastructureSystems.Forecasts
        internal::IS.InfrastructureSystemsInternal
    end



# Arguments
- `name::String`
- `available::Bool`
- `bus::PSY.Bus`
- `active_power::Float64`
- `reactive_power::Float64`, validation range: `reactive_power_limits`, action if invalid: `warn`
- `rating::Float64`: Thermal limited MVA Power Output of the unit. <= Capacity, validation range: `(0, nothing)`, action if invalid: `error`
- `prime_mover::PSY.PrimeMovers.PrimeMover`: Prime mover technology according to EIA 923
- `active_power_limits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}`
- `reactive_power_limits::Union{Nothing, PSY.Min_Max}`, action if invalid: `warn`
- `ramp_limits::Union{Nothing, NamedTuple{(:up, :down), Tuple{Float64, Float64}}}`: ramp up and ramp down limits in MW (in component base per unit) per minute, validation range: `(0, nothing)`, action if invalid: `error`
- `time_limits::Union{Nothing, NamedTuple{(:up, :down), Tuple{Float64, Float64}}}`: Minimum up and Minimum down time limits in hours, validation range: `(0, nothing)`, action if invalid: `error`
- `base_power::Float64`: Base power of the unit in MVA, validation range: `(0, nothing)`, action if invalid: `warn`
- `operation_cost::PSY.OperationalCost`: Operation Cost of Generation [`OperationalCost`](@ref)
- `storage_target::Float64`: Storage target at the end of simulation as ratio of storage capacity.
- `conversion_factor::Float64`: Conversion factor from flow/volume to energy: m^3 -> p.u-hr.
- `upstream::Vector{NamedTuple{(:unit, :lag, :multiplier), Tuple{PSY.HydroGen, Int64, Float64}}}`: unit: upstream units; lag: duration in number of periods between upstream release and downstream availability; multiplier: relationship between upstream energy release and downstream energy availability
- `services::Vector{PSY.Service}`: Services that this device contributes to
- `dynamic_injector::Union{Nothing, PSY.DynamicInjection}`: corresponding dynamic injection device
- `ext::Dict{String, Any}`
- `forecasts::InfrastructureSystems.Forecasts`: internal forecast storage
- `internal::IS.InfrastructureSystemsInternal`: power system internal reference, do not modify
"""
mutable struct HydroDispatchCascade <: HydroCascade
    name::String
    available::Bool
    bus::PSY.Bus
    active_power::Float64
    reactive_power::Float64
    "Thermal limited MVA Power Output of the unit. <= Capacity"
    rating::Float64
    "Prime mover technology according to EIA 923"
    prime_mover::PSY.PrimeMovers.PrimeMover
    active_power_limits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
    reactive_power_limits::Union{Nothing, PSY.Min_Max}
    "ramp up and ramp down limits in MW (in component base per unit) per minute"
    ramp_limits::Union{Nothing, NamedTuple{(:up, :down), Tuple{Float64, Float64}}}
    "Minimum up and Minimum down time limits in hours"
    time_limits::Union{Nothing, NamedTuple{(:up, :down), Tuple{Float64, Float64}}}
    "Base power of the unit in MVA"
    base_power::Float64
    "Operation Cost of Generation [`OperationalCost`](@ref)"
    operation_cost::PSY.OperationalCost
    "Storage target at the end of simulation as ratio of storage capacity."
    storage_target::Float64
    "Conversion factor from flow/volume to energy: m^3 -> p.u-hr."
    conversion_factor::Float64
    "unit: upstream units; lag: duration in number of periods between upstream release and downstream availability; multiplier: relationship between upstream energy release and downstream energy availability"
    upstream::Vector{NamedTuple{(:unit, :lag, :multiplier), Tuple{PSY.HydroGen, Int64, Float64}}}
    "Services that this device contributes to"
    services::Vector{PSY.Service}
    "corresponding dynamic injection device"
    dynamic_injector::Union{Nothing, PSY.DynamicInjection}
    ext::Dict{String, Any}
    "internal forecast storage"
    forecasts::InfrastructureSystems.Forecasts
    "power system internal reference, do not modify"
    internal::IS.InfrastructureSystemsInternal
end

function HydroDispatchCascade(name, available, bus, active_power, reactive_power, rating, prime_mover, active_power_limits, reactive_power_limits, ramp_limits, time_limits, base_power, operation_cost=PSY.TwoPartCost(0.0, 0.0), storage_target=1.0, conversion_factor=1.0, upstream=NamedTuple{(:unit, :lag, :multiplier), Tuple{PSY.HydroGen, Int64, Float64}}[], services=PSY.Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), forecasts=InfrastructureSystems.Forecasts(), )
    HydroDispatchCascade(name, available, bus, active_power, reactive_power, rating, prime_mover, active_power_limits, reactive_power_limits, ramp_limits, time_limits, base_power, operation_cost, storage_target, conversion_factor, upstream, services, dynamic_injector, ext, forecasts, IS.InfrastructureSystemsInternal(), )
end

function HydroDispatchCascade(; name, available, bus, active_power, reactive_power, rating, prime_mover, active_power_limits, reactive_power_limits, ramp_limits, time_limits, base_power, operation_cost=PSY.TwoPartCost(0.0, 0.0), storage_target=1.0, conversion_factor=1.0, upstream=NamedTuple{(:unit, :lag, :multiplier), Tuple{PSY.HydroGen, Int64, Float64}}[], services=PSY.Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), forecasts=InfrastructureSystems.Forecasts(), internal=IS.InfrastructureSystemsInternal(), )
    HydroDispatchCascade(name, available, bus, active_power, reactive_power, rating, prime_mover, active_power_limits, reactive_power_limits, ramp_limits, time_limits, base_power, operation_cost, storage_target, conversion_factor, upstream, services, dynamic_injector, ext, forecasts, internal, )
end

# Constructor for demo purposes; non-functional.
function HydroDispatchCascade(::Nothing)
    HydroDispatchCascade(;
        name="init",
        available=false,
        bus=PSY.Bus(nothing),
        active_power=0.0,
        reactive_power=0.0,
        rating=0.0,
        prime_mover=PSY.PrimeMovers.HY,
        active_power_limits=(min=0.0, max=0.0),
        reactive_power_limits=nothing,
        ramp_limits=nothing,
        time_limits=nothing,
        base_power=0.0,
        operation_cost=PSY.TwoPartCost(nothing),
        storage_target=0.0,
        conversion_factor=0.0,
        upstream=NamedTuple{(:unit, :lag, :multiplier), Tuple{PSY.HydroGen, Int64, Float64}}[],
        services=PSY.Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
        forecasts=InfrastructureSystems.Forecasts(),
    )
end


InfrastructureSystems.get_name(value::HydroDispatchCascade) = value.name

PowerSystems.get_available(value::HydroDispatchCascade) = value.available

PowerSystems.get_bus(value::HydroDispatchCascade) = value.bus

PowerSystems.get_active_power(value::HydroDispatchCascade) = get_value(value, value.active_power)

PowerSystems.get_reactive_power(value::HydroDispatchCascade) = get_value(value, value.reactive_power)

PowerSystems.get_rating(value::HydroDispatchCascade) = get_value(value, value.rating)

PowerSystems.get_prime_mover(value::HydroDispatchCascade) = value.prime_mover

PowerSystems.get_active_power_limits(value::HydroDispatchCascade) = get_value(value, value.active_power_limits)

PowerSystems.get_reactive_power_limits(value::HydroDispatchCascade) = get_value(value, value.reactive_power_limits)

PowerSystems.get_ramp_limits(value::HydroDispatchCascade) = get_value(value, value.ramp_limits)

PowerSystems.get_time_limits(value::HydroDispatchCascade) = value.time_limits

PowerSystems.get_base_power(value::HydroDispatchCascade) = value.base_power

PowerSystems.get_operation_cost(value::HydroDispatchCascade) = value.operation_cost

PowerSystems.get_storage_target(value::HydroDispatchCascade) = value.storage_target

PowerSystems.get_conversion_factor(value::HydroDispatchCascade) = value.conversion_factor
"""Get [`HydroDispatchCascade`](@ref) `upstream`."""
get_upstream(value::HydroDispatchCascade) = value.upstream

PowerSystems.get_services(value::HydroDispatchCascade) = value.services

PowerSystems.get_dynamic_injector(value::HydroDispatchCascade) = value.dynamic_injector

PowerSystems.get_ext(value::HydroDispatchCascade) = value.ext

InfrastructureSystems.get_forecasts(value::HydroDispatchCascade) = value.forecasts

PowerSystems.get_internal(value::HydroDispatchCascade) = value.internal


InfrastructureSystems.set_name!(value::HydroDispatchCascade, val) = value.name = val

PowerSystems.set_available!(value::HydroDispatchCascade, val) = value.available = val

PowerSystems.set_bus!(value::HydroDispatchCascade, val) = value.bus = val

PowerSystems.set_active_power!(value::HydroDispatchCascade, val) = value.active_power = val

PowerSystems.set_reactive_power!(value::HydroDispatchCascade, val) = value.reactive_power = val

PowerSystems.set_rating!(value::HydroDispatchCascade, val) = value.rating = val

PowerSystems.set_prime_mover!(value::HydroDispatchCascade, val) = value.prime_mover = val

PowerSystems.set_active_power_limits!(value::HydroDispatchCascade, val) = value.active_power_limits = val

PowerSystems.set_reactive_power_limits!(value::HydroDispatchCascade, val) = value.reactive_power_limits = val

PowerSystems.set_ramp_limits!(value::HydroDispatchCascade, val) = value.ramp_limits = val

PowerSystems.set_time_limits!(value::HydroDispatchCascade, val) = value.time_limits = val

PowerSystems.set_base_power!(value::HydroDispatchCascade, val) = value.base_power = val

PowerSystems.set_operation_cost!(value::HydroDispatchCascade, val) = value.operation_cost = val

PowerSystems.set_storage_target!(value::HydroDispatchCascade, val) = value.storage_target = val

PowerSystems.set_conversion_factor!(value::HydroDispatchCascade, val) = value.conversion_factor = val
"""Set [`HydroDispatchCascade`](@ref) `upstream`."""
set_upstream!(value::HydroDispatchCascade, val) = value.upstream = val

PowerSystems.set_services!(value::HydroDispatchCascade, val) = value.services = val

PowerSystems.set_ext!(value::HydroDispatchCascade, val) = value.ext = val

InfrastructureSystems.set_forecasts!(value::HydroDispatchCascade, val) = value.forecasts = val

PowerSystems.set_internal!(value::HydroDispatchCascade, val) = value.internal = val

