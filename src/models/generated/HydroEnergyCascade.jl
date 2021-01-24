#=
This file is auto-generated. Do not edit.
=#
"""
    mutable struct HydroEnergyCascade <: HydroCascade
        name::String
        available::Bool
        bus::PSY.Bus
        active_power::Float64
        reactive_power::Float64
        rating::Float64
        prime_mover::PSY.PrimeMovers
        active_power_limits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
        reactive_power_limits::Union{Nothing, PSY.Min_Max}
        ramp_limits::Union{Nothing, NamedTuple{(:up, :down), Tuple{Float64, Float64}}}
        time_limits::Union{Nothing, NamedTuple{(:up, :down), Tuple{Float64, Float64}}}
        base_power::Float64
        storage_capacity::Float64
        inflow::Float64
        initial_storage::Float64
        operation_cost::PSY.OperationalCost
        storage_target::Float64
        conversion_factor::Float64
        upstream::Vector{NamedTuple{(:unit, :lag, :multiplier), Tuple{PSY.HydroGen, Int64, Float64}}}
        services::Vector{PSY.Service}
        dynamic_injector::Union{Nothing, PSY.DynamicInjection}
        ext::Dict{String, Any}
        time_series_container::InfrastructureSystems.TimeSeriesContainer
        internal::IS.InfrastructureSystemsInternal
    end



# Arguments
- `name::String`
- `available::Bool`
- `bus::PSY.Bus`
- `active_power::Float64`
- `reactive_power::Float64`, validation range: `reactive_power_limits`, action if invalid: `warn`
- `rating::Float64`: Thermal limited MVA Power Output of the unit. <= Capacity, validation range: `(0, nothing)`, action if invalid: `error`
- `prime_mover::PSY.PrimeMovers`: Prime mover technology according to EIA 923
- `active_power_limits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}`
- `reactive_power_limits::Union{Nothing, PSY.Min_Max}`, action if invalid: `warn`
- `ramp_limits::Union{Nothing, NamedTuple{(:up, :down), Tuple{Float64, Float64}}}`: ramp up and ramp down limits in MW (in component base per unit) per minute, validation range: `(0, nothing)`, action if invalid: `error`
- `time_limits::Union{Nothing, NamedTuple{(:up, :down), Tuple{Float64, Float64}}}`: Minimum up and Minimum down time limits in hours, validation range: `(0, nothing)`, action if invalid: `error`
- `base_power::Float64`: Base power of the unit in MVA, validation range: `(0, nothing)`, action if invalid: `warn`
- `storage_capacity::Float64`: Maximum storage capacity in the reservoir (units can be p.u-hr or m^3)., validation range: `(0, nothing)`, action if invalid: `error`
- `inflow::Float64`: Baseline inflow into the reservoir (units can be p.u. or m^3/hr), validation range: `(0, nothing)`, action if invalid: `error`
- `initial_storage::Float64`: Initial storage capacity in the reservoir (units can be p.u-hr or m^3)., validation range: `(0, nothing)`, action if invalid: `error`
- `operation_cost::PSY.OperationalCost`: Operation Cost of Generation [`OperationalCost`](@ref)
- `storage_target::Float64`: Storage target at the end of simulation as ratio of storage capacity.
- `conversion_factor::Float64`: Conversion factor from flow/volume to energy: m^3 -> p.u-hr.
- `upstream::Vector{NamedTuple{(:unit, :lag, :multiplier), Tuple{PSY.HydroGen, Int64, Float64}}}`: unit: upstream units; lag: duration in number of periods between upstream release and downstream availability; multiplier: relationship between upstream energy release and downstream energy availability
- `services::Vector{PSY.Service}`: Services that this device contributes to
- `dynamic_injector::Union{Nothing, PSY.DynamicInjection}`: corresponding dynamic injection device
- `ext::Dict{String, Any}`
- `time_series_container::InfrastructureSystems.TimeSeriesContainer`: internal time_series storage
- `internal::IS.InfrastructureSystemsInternal`: power system internal reference, do not modify
"""
mutable struct HydroEnergyCascade <: HydroCascade
    name::String
    available::Bool
    bus::PSY.Bus
    active_power::Float64
    reactive_power::Float64
    "Thermal limited MVA Power Output of the unit. <= Capacity"
    rating::Float64
    "Prime mover technology according to EIA 923"
    prime_mover::PSY.PrimeMovers
    active_power_limits::NamedTuple{(:min, :max), Tuple{Float64, Float64}}
    reactive_power_limits::Union{Nothing, PSY.Min_Max}
    "ramp up and ramp down limits in MW (in component base per unit) per minute"
    ramp_limits::Union{Nothing, NamedTuple{(:up, :down), Tuple{Float64, Float64}}}
    "Minimum up and Minimum down time limits in hours"
    time_limits::Union{Nothing, NamedTuple{(:up, :down), Tuple{Float64, Float64}}}
    "Base power of the unit in MVA"
    base_power::Float64
    "Maximum storage capacity in the reservoir (units can be p.u-hr or m^3)."
    storage_capacity::Float64
    "Baseline inflow into the reservoir (units can be p.u. or m^3/hr)"
    inflow::Float64
    "Initial storage capacity in the reservoir (units can be p.u-hr or m^3)."
    initial_storage::Float64
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
    "internal time_series storage"
    time_series_container::InfrastructureSystems.TimeSeriesContainer
    "power system internal reference, do not modify"
    internal::IS.InfrastructureSystemsInternal
end

function HydroEnergyCascade(name, available, bus, active_power, reactive_power, rating, prime_mover, active_power_limits, reactive_power_limits, ramp_limits, time_limits, base_power, storage_capacity, inflow, initial_storage, operation_cost=PSY.TwoPartCost(0.0, 0.0), storage_target=1.0, conversion_factor=1.0, upstream=NamedTuple{(:unit, :lag, :multiplier), Tuple{PSY.HydroGen, Int64, Float64}}[], services=PSY.Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), time_series_container=InfrastructureSystems.TimeSeriesContainer(), )
    HydroEnergyCascade(name, available, bus, active_power, reactive_power, rating, prime_mover, active_power_limits, reactive_power_limits, ramp_limits, time_limits, base_power, storage_capacity, inflow, initial_storage, operation_cost, storage_target, conversion_factor, upstream, services, dynamic_injector, ext, time_series_container, IS.InfrastructureSystemsInternal(), )
end

function HydroEnergyCascade(; name, available, bus, active_power, reactive_power, rating, prime_mover, active_power_limits, reactive_power_limits, ramp_limits, time_limits, base_power, storage_capacity, inflow, initial_storage, operation_cost=PSY.TwoPartCost(0.0, 0.0), storage_target=1.0, conversion_factor=1.0, upstream=NamedTuple{(:unit, :lag, :multiplier), Tuple{PSY.HydroGen, Int64, Float64}}[], services=PSY.Device[], dynamic_injector=nothing, ext=Dict{String, Any}(), time_series_container=InfrastructureSystems.TimeSeriesContainer(), internal=IS.InfrastructureSystemsInternal(), )
    HydroEnergyCascade(name, available, bus, active_power, reactive_power, rating, prime_mover, active_power_limits, reactive_power_limits, ramp_limits, time_limits, base_power, storage_capacity, inflow, initial_storage, operation_cost, storage_target, conversion_factor, upstream, services, dynamic_injector, ext, time_series_container, internal, )
end

# Constructor for demo purposes; non-functional.
function HydroEnergyCascade(::Nothing)
    HydroEnergyCascade(;
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
        storage_capacity=0.0,
        inflow=0.0,
        initial_storage=0.0,
        operation_cost=PSY.TwoPartCost(nothing),
        storage_target=0.0,
        conversion_factor=0.0,
        upstream=NamedTuple{(:unit, :lag, :multiplier), Tuple{PSY.HydroGen, Int64, Float64}}[],
        services=PSY.Device[],
        dynamic_injector=nothing,
        ext=Dict{String, Any}(),
        time_series_container=InfrastructureSystems.TimeSeriesContainer(),
    )
end


InfrastructureSystems.get_name(value::HydroEnergyCascade) = value.name

PowerSystems.get_available(value::HydroEnergyCascade) = value.available

PowerSystems.get_bus(value::HydroEnergyCascade) = value.bus

PowerSystems.get_active_power(value::HydroEnergyCascade) = get_value(value, value.active_power)

PowerSystems.get_reactive_power(value::HydroEnergyCascade) = get_value(value, value.reactive_power)

PowerSystems.get_rating(value::HydroEnergyCascade) = get_value(value, value.rating)

PowerSystems.get_prime_mover(value::HydroEnergyCascade) = value.prime_mover

PowerSystems.get_active_power_limits(value::HydroEnergyCascade) = get_value(value, value.active_power_limits)

PowerSystems.get_reactive_power_limits(value::HydroEnergyCascade) = get_value(value, value.reactive_power_limits)

PowerSystems.get_ramp_limits(value::HydroEnergyCascade) = get_value(value, value.ramp_limits)

PowerSystems.get_time_limits(value::HydroEnergyCascade) = value.time_limits

PowerSystems.get_base_power(value::HydroEnergyCascade) = value.base_power

PowerSystems.get_storage_capacity(value::HydroEnergyCascade) = get_value(value, value.storage_capacity)

PowerSystems.get_inflow(value::HydroEnergyCascade) = get_value(value, value.inflow)

PowerSystems.get_initial_storage(value::HydroEnergyCascade) = get_value(value, value.initial_storage)

PowerSystems.get_operation_cost(value::HydroEnergyCascade) = value.operation_cost

PowerSystems.get_storage_target(value::HydroEnergyCascade) = value.storage_target

PowerSystems.get_conversion_factor(value::HydroEnergyCascade) = value.conversion_factor
"""Get [`HydroEnergyCascade`](@ref) `upstream`."""
get_upstream(value::HydroEnergyCascade) = value.upstream

PowerSystems.get_services(value::HydroEnergyCascade) = value.services

PowerSystems.get_dynamic_injector(value::HydroEnergyCascade) = value.dynamic_injector

PowerSystems.get_ext(value::HydroEnergyCascade) = value.ext

InfrastructureSystems.get_time_series_container(value::HydroEnergyCascade) = value.time_series_container

PowerSystems.get_internal(value::HydroEnergyCascade) = value.internal


InfrastructureSystems.set_name!(value::HydroEnergyCascade, val) = value.name = val

PowerSystems.set_available!(value::HydroEnergyCascade, val) = value.available = val

PowerSystems.set_bus!(value::HydroEnergyCascade, val) = value.bus = val

PowerSystems.set_active_power!(value::HydroEnergyCascade, val) = value.active_power = val

PowerSystems.set_reactive_power!(value::HydroEnergyCascade, val) = value.reactive_power = val

PowerSystems.set_rating!(value::HydroEnergyCascade, val) = value.rating = val

PowerSystems.set_prime_mover!(value::HydroEnergyCascade, val) = value.prime_mover = val

PowerSystems.set_active_power_limits!(value::HydroEnergyCascade, val) = value.active_power_limits = val

PowerSystems.set_reactive_power_limits!(value::HydroEnergyCascade, val) = value.reactive_power_limits = val

PowerSystems.set_ramp_limits!(value::HydroEnergyCascade, val) = value.ramp_limits = val

PowerSystems.set_time_limits!(value::HydroEnergyCascade, val) = value.time_limits = val

PowerSystems.set_base_power!(value::HydroEnergyCascade, val) = value.base_power = val

PowerSystems.set_storage_capacity!(value::HydroEnergyCascade, val) = value.storage_capacity = val

PowerSystems.set_inflow!(value::HydroEnergyCascade, val) = value.inflow = val

PowerSystems.set_initial_storage!(value::HydroEnergyCascade, val) = value.initial_storage = val

PowerSystems.set_operation_cost!(value::HydroEnergyCascade, val) = value.operation_cost = val

PowerSystems.set_storage_target!(value::HydroEnergyCascade, val) = value.storage_target = val

PowerSystems.set_conversion_factor!(value::HydroEnergyCascade, val) = value.conversion_factor = val
"""Set [`HydroEnergyCascade`](@ref) `upstream`."""
set_upstream!(value::HydroEnergyCascade, val) = value.upstream = val

PowerSystems.set_services!(value::HydroEnergyCascade, val) = value.services = val

PowerSystems.set_ext!(value::HydroEnergyCascade, val) = value.ext = val

InfrastructureSystems.set_time_series_container!(value::HydroEnergyCascade, val) = value.time_series_container = val

