struct HydroDispatchRunOfRiverLowerBound <: PSI.AbstractHydroDispatchFormulation end
abstract type TimeSeriesLowerBound <: PSI.ConstraintType end
const MIN_HOURLY_HYDRO_BOUND = "min_hourly_hydro_bound"

function PSI.add_constraints!(
    psi_container::PSI.OptimizationContainer,
    ::Type{TimeSeriesLowerBound},
    devices::IS.FlattenIteratorWrapper{H},
    ::PSI.DeviceModel{H, D},
    ::Type{S},
    feedforward::Union{Nothing, PSI.AbstractAffectFeedForward},
) where {H <: PSY.HydroGen, D <: HydroDispatchRunOfRiverLowerBound, S <: PM.AbstractPowerModel}
    time_steps = PSI.model_time_steps(psi_container)
    names = [PSY.get_name(d) for d in devices]
    
    active_power = PSI.get_variable(psi_container, PSI.make_variable_name(PSI.ActivePowerVariable, H))
    
    cons_name = PSI.make_constraint_name(MIN_HOURLY_HYDRO_BOUND, H)
    constraint = PSI.add_cons_container!(psi_container, cons_name, names, time_steps)
    
    for d in devices
        time_series = PSI.get_time_series(psi_container, d, MIN_HOURLY_HYDRO_BOUND)
        for t in time_steps
            name = PSY.get_name(d)
            constraint[name, t] = JuMP.@constraint(psi_container.JuMPmodel, 
            active_power[name, t] >= time_series[t]
            )
        end
    end
    return
end
