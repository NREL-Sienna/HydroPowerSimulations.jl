"""
Adds a constraint to enforce a minimum reservoir level target with a slack variable associated witha penalty term.
"""
struct ReservoirTargetFeedforward <: PSI.AbstractAffectFeedforward
    optimization_container_key::PSI.OptimizationContainerKey
    affected_values::Vector{<:PSI.OptimizationContainerKey}
    target_period::Int
    penalty_cost::Float64
    function ReservoirTargetFeedforward(;
        component_type::Type{<:PSY.Component},
        source::Type{T},
        affected_values::Vector{DataType},
        target_period::Int,
        penalty_cost::Float64,
        meta=PSI.CONTAINER_KEY_EMPTY_META,
    ) where {T}
        values_vector = Vector{PSI.VariableKey}(undef, length(affected_values))
        for (ix, v) in enumerate(affected_values)
            if v <: PSI.VariableType
                values_vector[ix] =
                    PSI.get_optimization_container_key(v(), component_type, meta)
            else
                error(
                    "ReservoirTargetFeedforward is only compatible with VariableType or ParamterType affected values",
                )
            end
        end
        new(
            PSI.get_optimization_container_key(T(), component_type, meta),
            values_vector,
            target_period,
            penalty_cost,
        )
    end
end

PSI.get_default_parameter_type(::ReservoirTargetFeedforward, _) = ReservoirTargetParameter
PSI.get_optimization_container_key(ff::ReservoirTargetFeedforward) =
    ff.optimization_container_key

@doc raw"""
        add_feedforward_constraints(
            container::PSI.OptimizationContainer,
            ::PSI.DeviceModel,
            devices::IS.FlattenIteratorWrapper{T},
            ff::ReservoirTargetFeedforward,
        ) where {T <: PSY.Component}

Constructs a equality constraint to a fix a variable in one model using the variable value from other model results.


``` variable[var_name, t] + slack[var_name, t] >= param[var_name, t] ```

# LaTeX

`` x + slack >= param``

# Arguments
* container::PSI.OptimizationContainer : the optimization_container model built in PowerSimulations
* model::PSI.DeviceModel : the device model
* devices::IS.FlattenIteratorWrapper{T} : list of devices
* ff::ReservoirTargetFeedforward : a instance of the FixValue Feedforward
"""
function PSI.add_feedforward_constraints!(
    container::PSI.OptimizationContainer,
    ::PSI.DeviceModel{T, U},
    devices::IS.FlattenIteratorWrapper{T},
    ff::ReservoirTargetFeedforward,
) where {T <: PSY.HydroGen, U <: AbstractHydroFormulation}
    time_steps = PSI.get_time_steps(container)
    parameter_type = PSI.get_default_parameter_type(ff, T)
    param = PSI.get_parameter_array(container, parameter_type(), T)
    multiplier = PSI.get_parameter_multiplier_array(container, parameter_type(), T)
    target_period = ff.target_period
    penalty_cost = ff.penalty_cost
    for var in PSI.get_affected_values(ff)
        variable = PSI.get_variable(container, var)
        slack_var = PSI.get_variable(container, HydroEnergyShortageVariable(), T)
        set_name, set_time = JuMP.axes(variable)
        IS.@assert_op set_name == [PSY.get_name(d) for d in devices]
        IS.@assert_op set_time == time_steps

        var_type = PSI.get_entry_type(var)
        con_ub = PSI.add_constraints_container!(
            container,
            PSI.FeedforwardEnergyTargetConstraint(),
            T,
            set_name;
            meta="$(var_type)target",
        )

        for d in devices
            name = PSY.get_name(d)
            con_ub[name] = JuMP.@constraint(
                container.JuMPmodel,
                variable[name, target_period] + slack_var[name, target_period] >=
                param[name, target_period] * multiplier[name, target_period]
            )
            PSI.add_to_objective_invariant_expression!(
                container,
                slack_var[name, target_period] * penalty_cost,
            )
        end
    end
    return
end

function PSI._add_feedforward_arguments!(
    container::PSI.OptimizationContainer,
    model::PSI.DeviceModel{T, U},
    devices::IS.FlattenIteratorWrapper{T},
    ff::ReservoirTargetFeedforward,
) where {T <: PSY.HydroGen, U <: AbstractHydroFormulation}
    parameter_type = PSI.get_default_parameter_type(ff, T)
    PSI.add_parameters!(container, parameter_type, ff, model, devices)
    # Enabling this FF requires the addition of an extra variable
    PSI.add_variables!(
        container,
        HydroEnergyShortageVariable,
        devices,
        PSI.get_formulation(model)(),
    )
    return
end
