function get_available_reservoirs(sys::System)
    pump_turbines = PSY.get_components(PSY.get_available, PSY.HydroPumpTurbine, sys)
    if isempty(pump_turbines)
        return PSY.get_components(PSY.get_available, PSY.HydroReservoir, sys)
    end
    reservoirs_in_pumps = Set{PSY.HydroReservoir}()
    for pump in pump_turbines
        push!(reservoirs_in_pumps, pump.head_reservoir)
        push!(reservoirs_in_pumps, pump.tail_reservoir)
    end
    return PSY.get_components(
        x -> (PSY.get_available(x)) && (x ∉ reservoirs_in_pumps),
        PSY.HydroReservoir,
        sys,
    )
end
