function get_available_reservoirs(sys::System)
    return PSY.get_components(
        x -> (PSY.get_available(x)),
        PSY.HydroReservoir,
        sys,
    )
end

function get_available_turbines(
    d::PSY.HydroReservoir,
    ::Type{U},
) where {U <: Union{TotalHydroPowerReservoirIncoming, TotalHydroFlowRateReservoirIncoming}}
    return filter(
        x -> PSY.get_available(x) && isa(x, PSY.HydroTurbine),
        PSY.get_upstream_turbines(d),
    )
end

function get_available_turbines(
    d::PSY.HydroReservoir,
    ::Type{U},
) where {U <: Union{TotalHydroPowerReservoirOutgoing, TotalHydroFlowRateReservoirOutgoing}}
    return filter(
        x -> PSY.get_available(x) && isa(x, PSY.HydroTurbine),
        PSY.get_downstream_turbines(d),
    )
end
