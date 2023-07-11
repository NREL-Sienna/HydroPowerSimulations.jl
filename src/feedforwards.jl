@doc raw"""
        add_feedforward_constraints(
            container::OptimizationContainer,
            ::DeviceModel,
            devices::IS.FlattenIteratorWrapper{T},
            ff::EnergyTargetFeedforward,
        ) where {T <: PSY.Component}

Constructs a equality constraint to a fix a variable in one model using the variable value from other model results.


``` variable[var_name, t] + slack[var_name, t] >= param[var_name, t] ```

# LaTeX

`` x + slack >= param``

# Arguments
* container::OptimizationContainer : the optimization_container model built in PowerSimulations
* model::DeviceModel : the device model
* devices::IS.FlattenIteratorWrapper{T} : list of devices
* ff::EnergyTargetFeedforward : a instance of the FixValue Feedforward
"""
function add_feedforward_constraints!(
    container::OptimizationContainer,
    ::DeviceModel,
    devices::IS.FlattenIteratorWrapper{T},
    ff::EnergyTargetFeedforward,
) where {T <: PSY.Component}
    time_steps = get_time_steps(container)
    parameter_type = get_default_parameter_type(ff, T)
    param = get_parameter_array(container, parameter_type(), T)
    multiplier = get_parameter_multiplier_array(container, parameter_type(), T)
    target_period = ff.target_period
    penalty_cost = ff.penalty_cost
    for var in get_affected_values(ff)
        variable = get_variable(container, var)
        slack_var = get_variable(container, EnergyShortageVariable(), T)
        set_name, set_time = JuMP.axes(variable)
        IS.@assert_op set_name == [PSY.get_name(d) for d in devices]
        IS.@assert_op set_time == time_steps

        var_type = get_entry_type(var)
        con_ub = add_constraints_container!(
            container,
            FeedforwardEnergyTargetConstraint(),
            T,
            set_name;
            meta = "$(var_type)target",
        )

        for d in devices
            name = PSY.get_name(d)
            con_ub[name] = JuMP.@constraint(
                container.JuMPmodel,
                variable[name, target_period] + slack_var[name, target_period] >=
                param[name, target_period] * multiplier[name, target_period]
            )
            add_to_objective_invariant_expression!(
                container,
                slack_var[name, target_period] * penalty_cost,
            )
        end
    end
    return
end

function _add_feedforward_arguments!(
    container::OptimizationContainer,
    model::DeviceModel,
    devices::IS.FlattenIteratorWrapper{T},
    ff::EnergyTargetFeedforward,
) where {T <: PSY.Component}
    parameter_type = get_default_parameter_type(ff, T)
    add_parameters!(container, parameter_type, ff, model, devices)
    # Enabling this FF requires the addition of an extra variable
    add_variables!(container, EnergyShortageVariable, devices, get_formulation(model)())
    return
end
