var documenterSearchIndex = {"docs":
[{"location":"quick_start_guide/#Quick-Start-Guide","page":"Quick Start Guide","title":"Quick Start Guide","text":"","category":"section"},{"location":"quick_start_guide/","page":"Quick Start Guide","title":"Quick Start Guide","text":"HydroPowerSimulations.jl is structured to enable stuff","category":"page"},{"location":"api/internal/#Internal-API","page":"Internal API Reference","title":"Internal API","text":"","category":"section"},{"location":"api/internal/","page":"Internal API Reference","title":"Internal API Reference","text":"Modules = [HydroPowerSimulations]\nPublic = false","category":"page"},{"location":"api/internal/#HydroPowerSimulations.EnergyBudgetTimeSeriesParameter","page":"Internal API Reference","title":"HydroPowerSimulations.EnergyBudgetTimeSeriesParameter","text":"Parameter to define energy budget time series\n\n\n\n\n\n","category":"type"},{"location":"api/internal/#HydroPowerSimulations.EnergyTargetTimeSeriesParameter","page":"Internal API Reference","title":"HydroPowerSimulations.EnergyTargetTimeSeriesParameter","text":"Parameter to define energy storage target level time series\n\n\n\n\n\n","category":"type"},{"location":"api/internal/#HydroPowerSimulations.HydroEnergySurplusVariable","page":"Internal API Reference","title":"HydroPowerSimulations.HydroEnergySurplusVariable","text":"Struct to dispatch the creation of a slack variable for energy storage levels > target storage levels\n\nDocs abbreviation: E^surplus\n\n\n\n\n\n","category":"type"},{"location":"api/internal/#HydroPowerSimulations.HydroEnergyVariableDown","page":"Internal API Reference","title":"HydroPowerSimulations.HydroEnergyVariableDown","text":"Struct to dispatch the creation of a variable for energy storage level (state of charge) of lower reservoir\n\nDocs abbreviation: E^down\n\n\n\n\n\n","category":"type"},{"location":"api/internal/#HydroPowerSimulations.InflowTimeSeriesParameter","page":"Internal API Reference","title":"HydroPowerSimulations.InflowTimeSeriesParameter","text":"Parameter to define energy inflow to storage or reservoir time series\n\n\n\n\n\n","category":"type"},{"location":"api/internal/#HydroPowerSimulations.OutflowTimeSeriesParameter","page":"Internal API Reference","title":"HydroPowerSimulations.OutflowTimeSeriesParameter","text":"Parameter to define energy outflow from storage or reservoir time series\n\n\n\n\n\n","category":"type"},{"location":"api/internal/#PowerSimulations.add_constraints!-Union{Tuple{X}, Tuple{W}, Tuple{V}, Tuple{PowerSimulations.OptimizationContainer, Type{<:PowerSimulations.PowerVariableLimitsConstraint}, Type{<:Union{PowerSimulations.ExpressionType, PowerSimulations.VariableType}}, InfrastructureSystems.FlattenIteratorWrapper{V}, PowerSimulations.DeviceModel{V, W}, PowerSimulations.NetworkModel{X}}} where {V<:PowerSystems.HydroGen, W<:HydroPowerSimulations.AbstractHydroDispatchFormulation, X<:PowerModels.AbstractPowerModel}","page":"Internal API Reference","title":"PowerSimulations.add_constraints!","text":"Add power variable limits constraints for hydro dispatch formulation\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.add_constraints!-Union{Tuple{X}, Tuple{W}, Tuple{V}, Tuple{PowerSimulations.OptimizationContainer, Type{<:PowerSimulations.PowerVariableLimitsConstraint}, Type{<:Union{PowerSimulations.ExpressionType, PowerSimulations.VariableType}}, InfrastructureSystems.FlattenIteratorWrapper{V}, PowerSimulations.DeviceModel{V, W}, PowerSimulations.NetworkModel{X}}} where {V<:PowerSystems.HydroGen, W<:HydroPowerSimulations.AbstractHydroUnitCommitment, X<:PowerModels.AbstractPowerModel}","page":"Internal API Reference","title":"PowerSimulations.add_constraints!","text":"Add power variable limits constraints for hydro unit commitment formulation\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.add_constraints!-Union{Tuple{X}, Tuple{W}, Tuple{V}, Tuple{PowerSimulations.OptimizationContainer, Type{<:PowerSimulations.PowerVariableLimitsConstraint}, Type{<:Union{PowerSimulations.ExpressionType, PowerSimulations.VariableType}}, InfrastructureSystems.FlattenIteratorWrapper{V}, PowerSimulations.DeviceModel{V, W}, PowerSimulations.NetworkModel{X}}} where {V<:PowerSystems.HydroPumpedStorage, W<:HydroPowerSimulations.AbstractHydroReservoirFormulation, X<:PowerModels.AbstractPowerModel}","page":"Internal API Reference","title":"PowerSimulations.add_constraints!","text":"Add output power variable limits constraints for hydro dispatch formulation\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.add_constraints!-Union{Tuple{X}, Tuple{W}, Tuple{V}, Tuple{PowerSimulations.OptimizationContainer, Type{HydroPowerSimulations.EnergyCapacityDownConstraint}, InfrastructureSystems.FlattenIteratorWrapper{V}, PowerSimulations.DeviceModel{V, W}, PowerSimulations.NetworkModel{X}}} where {V<:PowerSystems.HydroPumpedStorage, W<:HydroPowerSimulations.AbstractHydroReservoirFormulation, X<:PowerModels.AbstractPowerModel}","page":"Internal API Reference","title":"PowerSimulations.add_constraints!","text":"Add energy capacity down constraints for hydro pumped storage\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.add_constraints!-Union{Tuple{X}, Tuple{W}, Tuple{V}, Tuple{PowerSimulations.OptimizationContainer, Type{HydroPowerSimulations.EnergyCapacityUpConstraint}, InfrastructureSystems.FlattenIteratorWrapper{V}, PowerSimulations.DeviceModel{V, W}, PowerSimulations.NetworkModel{X}}} where {V<:PowerSystems.HydroPumpedStorage, W<:HydroPowerSimulations.AbstractHydroReservoirFormulation, X<:PowerModels.AbstractPowerModel}","page":"Internal API Reference","title":"PowerSimulations.add_constraints!","text":"This function defines the constraints for the water level (or state of charge) for the HydroPumpedStorage.\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.add_constraints!-Union{Tuple{X}, Tuple{W}, Tuple{V}, Tuple{PowerSimulations.OptimizationContainer, Type{HydroPowerSimulations.EnergyTargetConstraint}, InfrastructureSystems.FlattenIteratorWrapper{V}, PowerSimulations.DeviceModel{V, W}, PowerSimulations.NetworkModel{X}}} where {V<:PowerSystems.HydroGen, W<:HydroPowerSimulations.AbstractHydroReservoirFormulation, X<:PowerModels.AbstractPowerModel}","page":"Internal API Reference","title":"PowerSimulations.add_constraints!","text":"Add energy target constraints for hydro gen\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.add_constraints!-Union{Tuple{X}, Tuple{W}, Tuple{V}, Tuple{PowerSimulations.OptimizationContainer, Type{PowerSimulations.ActivePowerVariableLimitsConstraint}, Type{<:Union{PowerSimulations.ExpressionType, PowerSimulations.VariableType}}, InfrastructureSystems.FlattenIteratorWrapper{V}, PowerSimulations.DeviceModel{V, W}, PowerSimulations.NetworkModel{X}}} where {V<:PowerSystems.HydroGen, W<:HydroDispatchRunOfRiver, X<:PowerModels.AbstractPowerModel}","page":"Internal API Reference","title":"PowerSimulations.add_constraints!","text":"Time series constraints\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.add_constraints!-Union{Tuple{X}, Tuple{W}, Tuple{V}, Tuple{PowerSimulations.OptimizationContainer, Type{PowerSimulations.ActivePowerVariableLimitsConstraint}, Type{<:Union{PowerSimulations.VariableType, var\"#s36\"} where var\"#s36\"<:PowerSimulations.RangeConstraintLBExpressions}, InfrastructureSystems.FlattenIteratorWrapper{V}, PowerSimulations.DeviceModel{V, W}, PowerSimulations.NetworkModel{X}}} where {V<:PowerSystems.HydroGen, W<:HydroCommitmentRunOfRiver, X<:PowerModels.AbstractPowerModel}","page":"Internal API Reference","title":"PowerSimulations.add_constraints!","text":"Add semicontinuous range constraints for Hydro Unit Commitment formulation\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.add_constraints!-Union{Tuple{X}, Tuple{W}, Tuple{V}, Tuple{PowerSimulations.OptimizationContainer, Type{PowerSimulations.EnergyBalanceConstraint}, InfrastructureSystems.FlattenIteratorWrapper{V}, PowerSimulations.DeviceModel{V, W}, PowerSimulations.NetworkModel{X}}} where {V<:PowerSystems.HydroEnergyReservoir, W<:HydroPowerSimulations.AbstractHydroReservoirFormulation, X<:PowerModels.AbstractPowerModel}","page":"Internal API Reference","title":"PowerSimulations.add_constraints!","text":"This function defines the constraints for the water level (or state of charge) for the Hydro Reservoir.\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.add_constraints!-Union{Tuple{X}, Tuple{W}, Tuple{V}, Tuple{PowerSimulations.OptimizationContainer, Type{PowerSimulations.InputActivePowerVariableLimitsConstraint}, Type{<:Union{PowerSimulations.ExpressionType, PowerSimulations.VariableType}}, InfrastructureSystems.FlattenIteratorWrapper{V}, PowerSimulations.DeviceModel{V, W}, PowerSimulations.NetworkModel{X}}} where {V<:PowerSystems.HydroPumpedStorage, W<:HydroPowerSimulations.AbstractHydroReservoirFormulation, X<:PowerModels.AbstractPowerModel}","page":"Internal API Reference","title":"PowerSimulations.add_constraints!","text":"Add input power variable limits constraints for hydro dispatch formulation\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.add_feedforward_constraints!-Union{Tuple{T}, Tuple{PowerSimulations.OptimizationContainer, PowerSimulations.DeviceModel, InfrastructureSystems.FlattenIteratorWrapper{T}, ReservoirLimitFeedforward}} where T<:PowerSystems.Component","page":"Internal API Reference","title":"PowerSimulations.add_feedforward_constraints!","text":"    add_feedforward_constraints(container::OptimizationContainer,\n                    cons_name::Symbol,\n                    param_reference,\n                    var_key::VariableKey)\n\nConstructs a parameterized integral limit constraint to implement feedforward from other models. The Parameters are initialized using the upper boundary values of the provided variables.\n\nsum(variable[var_name, t] for t in 1:affected_periods)/affected_periods <= param_reference[var_name]\n\nLaTeX\n\nsum_t x leq param^max\n\nArguments\n\ncontainer::OptimizationContainer : the optimization_container model built in PowerSimulations\nmodel::DeviceModel : the device model\ndevices::IS.FlattenIteratorWrapper{T} : list of devices\nff::FixValueFeedforward : a instance of the FixValue Feedforward\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.add_feedforward_constraints!-Union{Tuple{U}, Tuple{T}, Tuple{PowerSimulations.OptimizationContainer, PowerSimulations.DeviceModel{T, U}, InfrastructureSystems.FlattenIteratorWrapper{T}, ReservoirTargetFeedforward}} where {T<:PowerSystems.HydroGen, U<:HydroPowerSimulations.AbstractHydroFormulation}","page":"Internal API Reference","title":"PowerSimulations.add_feedforward_constraints!","text":"    add_feedforward_constraints(\n        container::PSI.OptimizationContainer,\n        ::PSI.DeviceModel,\n        devices::IS.FlattenIteratorWrapper{T},\n        ff::ReservoirTargetFeedforward,\n    ) where {T <: PSY.Component}\n\nConstructs a equality constraint to a fix a variable in one model using the variable value from other model results.\n\nvariable[var_name, t] + slack[var_name, t] >= param[var_name, t]\n\nLaTeX\n\nx + slack = param\n\nArguments\n\ncontainer::PSI.OptimizationContainer : the optimization_container model built in PowerSimulations\nmodel::PSI.DeviceModel : the device model\ndevices::IS.FlattenIteratorWrapper{T} : list of devices\nff::ReservoirTargetFeedforward : a instance of the FixValue Feedforward\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.construct_device!-Union{Tuple{S}, Tuple{D}, Tuple{H}, Tuple{PowerSimulations.OptimizationContainer, PowerSystems.System, PowerSimulations.ArgumentConstructStage, PowerSimulations.DeviceModel{H, D}, PowerSimulations.NetworkModel{S}}} where {H<:PowerSystems.HydroGen, D<:HydroCommitmentReservoirBudget, S<:PowerModels.AbstractActivePowerModel}","page":"Internal API Reference","title":"PowerSimulations.construct_device!","text":"Construct model for HydroGen with ReservoirBudget Commitment Formulation with only Active Power.\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.construct_device!-Union{Tuple{S}, Tuple{D}, Tuple{H}, Tuple{PowerSimulations.OptimizationContainer, PowerSystems.System, PowerSimulations.ArgumentConstructStage, PowerSimulations.DeviceModel{H, D}, PowerSimulations.NetworkModel{S}}} where {H<:PowerSystems.HydroGen, D<:HydroCommitmentReservoirBudget, S<:PowerModels.AbstractPowerModel}","page":"Internal API Reference","title":"PowerSimulations.construct_device!","text":"Construct model for HydroGen with ReservoirBudget Commitment Formulation\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.construct_device!-Union{Tuple{S}, Tuple{D}, Tuple{H}, Tuple{PowerSimulations.OptimizationContainer, PowerSystems.System, PowerSimulations.ArgumentConstructStage, PowerSimulations.DeviceModel{H, D}, PowerSimulations.NetworkModel{S}}} where {H<:PowerSystems.HydroGen, D<:HydroCommitmentRunOfRiver, S<:PowerModels.AbstractActivePowerModel}","page":"Internal API Reference","title":"PowerSimulations.construct_device!","text":"Construct model for HydroGen with RunOfRiver Commitment Formulation with only Active Power.\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.construct_device!-Union{Tuple{S}, Tuple{D}, Tuple{H}, Tuple{PowerSimulations.OptimizationContainer, PowerSystems.System, PowerSimulations.ArgumentConstructStage, PowerSimulations.DeviceModel{H, D}, PowerSimulations.NetworkModel{S}}} where {H<:PowerSystems.HydroGen, D<:HydroPowerSimulations.AbstractHydroDispatchFormulation, S<:PowerModels.AbstractActivePowerModel}","page":"Internal API Reference","title":"PowerSimulations.construct_device!","text":"Construct model for HydroGen with RunOfRiver Dispatch Formulation with only Active Power.\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.construct_device!-Union{Tuple{S}, Tuple{D}, Tuple{H}, Tuple{PowerSimulations.OptimizationContainer, PowerSystems.System, PowerSimulations.ArgumentConstructStage, PowerSimulations.DeviceModel{H, D}, PowerSimulations.NetworkModel{S}}} where {H<:PowerSystems.HydroGen, D<:HydroPowerSimulations.AbstractHydroDispatchFormulation, S<:PowerModels.AbstractPowerModel}","page":"Internal API Reference","title":"PowerSimulations.construct_device!","text":"Construct model for HydroGen with RunOfRiver Dispatch Formulation\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.construct_device!-Union{Tuple{S}, Tuple{H}, Tuple{PowerSimulations.OptimizationContainer, PowerSystems.System, PowerSimulations.ArgumentConstructStage, PowerSimulations.DeviceModel{H, HydroCommitmentReservoirStorage}, PowerSimulations.NetworkModel{S}}} where {H<:PowerSystems.HydroEnergyReservoir, S<:PowerModels.AbstractActivePowerModel}","page":"Internal API Reference","title":"PowerSimulations.construct_device!","text":"Construct model for HydroGen with ReservoirStorage Dispatch Formulation with only Active Power\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.construct_device!-Union{Tuple{S}, Tuple{H}, Tuple{PowerSimulations.OptimizationContainer, PowerSystems.System, PowerSimulations.ArgumentConstructStage, PowerSimulations.DeviceModel{H, HydroCommitmentReservoirStorage}, PowerSimulations.NetworkModel{S}}} where {H<:PowerSystems.HydroEnergyReservoir, S<:PowerModels.AbstractPowerModel}","page":"Internal API Reference","title":"PowerSimulations.construct_device!","text":"Construct model for HydroGen with ReservoirStorage Commitment Formulation\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.construct_device!-Union{Tuple{S}, Tuple{H}, Tuple{PowerSimulations.OptimizationContainer, PowerSystems.System, PowerSimulations.ArgumentConstructStage, PowerSimulations.DeviceModel{H, HydroDispatchPumpedStorage}, PowerSimulations.NetworkModel{S}}} where {H<:PowerSystems.HydroPumpedStorage, S<:PowerModels.AbstractActivePowerModel}","page":"Internal API Reference","title":"PowerSimulations.construct_device!","text":"Construct model for HydroPumpedStorage with PumpedStorage Dispatch Formulation with only Active Power\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.construct_device!-Union{Tuple{S}, Tuple{H}, Tuple{PowerSimulations.OptimizationContainer, PowerSystems.System, PowerSimulations.ArgumentConstructStage, PowerSimulations.DeviceModel{H, HydroDispatchReservoirBudget}, PowerSimulations.NetworkModel{S}}} where {H<:PowerSystems.HydroEnergyReservoir, S<:PowerModels.AbstractActivePowerModel}","page":"Internal API Reference","title":"PowerSimulations.construct_device!","text":"Construct model for HydroGen with ReservoirBudget Dispatch Formulation with only Active Power.\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.construct_device!-Union{Tuple{S}, Tuple{H}, Tuple{PowerSimulations.OptimizationContainer, PowerSystems.System, PowerSimulations.ArgumentConstructStage, PowerSimulations.DeviceModel{H, HydroDispatchReservoirBudget}, PowerSimulations.NetworkModel{S}}} where {H<:PowerSystems.HydroEnergyReservoir, S<:PowerModels.AbstractPowerModel}","page":"Internal API Reference","title":"PowerSimulations.construct_device!","text":"Construct model for HydroGen with ReservoirBudget Dispatch Formulation\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.construct_device!-Union{Tuple{S}, Tuple{H}, Tuple{PowerSimulations.OptimizationContainer, PowerSystems.System, PowerSimulations.ArgumentConstructStage, PowerSimulations.DeviceModel{H, HydroDispatchReservoirStorage}, PowerSimulations.NetworkModel{S}}} where {H<:PowerSystems.HydroEnergyReservoir, S<:PowerModels.AbstractActivePowerModel}","page":"Internal API Reference","title":"PowerSimulations.construct_device!","text":"Construct model for HydroGen with ReservoirStorage Dispatch Formulation with only Active Power\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.construct_device!-Union{Tuple{S}, Tuple{H}, Tuple{PowerSimulations.OptimizationContainer, PowerSystems.System, PowerSimulations.ArgumentConstructStage, PowerSimulations.DeviceModel{H, HydroDispatchReservoirStorage}, PowerSimulations.NetworkModel{S}}} where {H<:PowerSystems.HydroEnergyReservoir, S<:PowerModels.AbstractPowerModel}","page":"Internal API Reference","title":"PowerSimulations.construct_device!","text":"Construct model for HydroGen with ReservoirStorage Dispatch Formulation\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.construct_device!-Union{Tuple{S}, Tuple{H}, Tuple{PowerSimulations.OptimizationContainer, PowerSystems.System, PowerSimulations.ArgumentConstructStage, PowerSimulations.DeviceModel{H, PowerSimulations.FixedOutput}, PowerSimulations.NetworkModel{S}}} where {H<:PowerSystems.HydroGen, S<:PowerModels.AbstractPowerModel}","page":"Internal API Reference","title":"PowerSimulations.construct_device!","text":"Construct model for HydroGen with FixedOutput Formulation\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.get_min_max_limits-Tuple{PowerSystems.HydroGen, Type{<:PowerSimulations.ActivePowerVariableLimitsConstraint}, Type{<:HydroPowerSimulations.AbstractHydroFormulation}}","page":"Internal API Reference","title":"PowerSimulations.get_min_max_limits","text":"Min and max active Power Variable limits\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.get_min_max_limits-Tuple{PowerSystems.HydroGen, Type{<:PowerSimulations.ActivePowerVariableLimitsConstraint}, Type{<:HydroPowerSimulations.AbstractHydroReservoirFormulation}}","page":"Internal API Reference","title":"PowerSimulations.get_min_max_limits","text":"Min and max active Power Variable limits\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.get_min_max_limits-Tuple{PowerSystems.HydroGen, Type{<:PowerSimulations.InputActivePowerVariableLimitsConstraint}, Type{HydroDispatchPumpedStorage}}","page":"Internal API Reference","title":"PowerSimulations.get_min_max_limits","text":"Min and max input active power variable limits for hydro dispatch pumped storage\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.get_min_max_limits-Tuple{PowerSystems.HydroGen, Type{<:PowerSimulations.OutputActivePowerVariableLimitsConstraint}, Type{HydroDispatchPumpedStorage}}","page":"Internal API Reference","title":"PowerSimulations.get_min_max_limits","text":"Min and max output active power variable limits for hydro dispatch pumped storage\n\n\n\n\n\n","category":"method"},{"location":"api/internal/#PowerSimulations.get_min_max_limits-Tuple{PowerSystems.HydroGen, Type{<:PowerSimulations.ReactivePowerVariableLimitsConstraint}, Type{<:HydroPowerSimulations.AbstractHydroReservoirFormulation}}","page":"Internal API Reference","title":"PowerSimulations.get_min_max_limits","text":"Min and max reactive Power Variable limits\n\n\n\n\n\n","category":"method"},{"location":"#PowerSystems.jl","page":"Welcome Page","title":"PowerSystems.jl","text":"","category":"section"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"CurrentModule = HydroPowerSimulations","category":"page"},{"location":"#Overview","page":"Welcome Page","title":"Overview","text":"","category":"section"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"HydroPowerSimulations.jl is a Julia package that provides blah blah","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"","category":"page"},{"location":"","page":"Welcome Page","title":"Welcome Page","text":"HydroPowerSimulations has been developed as part of the FlexPower Project at the U.S. Department of Energy's National Renewable Energy Laboratory (NREL)","category":"page"},{"location":"api/public/#Public-API-Reference","page":"Public API Reference","title":"Public API Reference","text":"","category":"section"},{"location":"api/public/","page":"Public API Reference","title":"Public API Reference","text":"Modules = [HydroPowerSimulations]\nPublic = true","category":"page"},{"location":"api/public/#HydroPowerSimulations.HydroCommitmentReservoirBudget","page":"Public API Reference","title":"HydroPowerSimulations.HydroCommitmentReservoirBudget","text":"Formulation type to add commitment and injection variables constrained by total energy production budget defined with a time series for HydroGen\n\n\n\n\n\n","category":"type"},{"location":"api/public/#HydroPowerSimulations.HydroCommitmentReservoirStorage","page":"Public API Reference","title":"HydroPowerSimulations.HydroCommitmentReservoirStorage","text":"Formulation type to constrain hydropower production with unit commitment variables and a representation of the energy storage capacity and water inflow time series of a reservoir for HydroGen\n\n\n\n\n\n","category":"type"},{"location":"api/public/#HydroPowerSimulations.HydroCommitmentRunOfRiver","page":"Public API Reference","title":"HydroPowerSimulations.HydroCommitmentRunOfRiver","text":"Formulation type to add commitment and injection variables constrained by a maximum injection time series for HydroGen\n\n\n\n\n\n","category":"type"},{"location":"api/public/#HydroPowerSimulations.HydroDispatchPumpedStorage","page":"Public API Reference","title":"HydroPowerSimulations.HydroDispatchPumpedStorage","text":"Formulation type to constrain energy production from pumped storage with a representation of the energy storage capacity of upper and lower reservoirs and water inflow time series of upper reservoir and outflow time series of lower reservoir for HydroPumpedStorage\n\n\n\n\n\n","category":"type"},{"location":"api/public/#HydroPowerSimulations.HydroDispatchReservoirBudget","page":"Public API Reference","title":"HydroPowerSimulations.HydroDispatchReservoirBudget","text":"Formulation type to add injection variables constrained by total energy production budget defined with a time series for HydroGen\n\n\n\n\n\n","category":"type"},{"location":"api/public/#HydroPowerSimulations.HydroDispatchReservoirStorage","page":"Public API Reference","title":"HydroPowerSimulations.HydroDispatchReservoirStorage","text":"Formulation type to constrain hydropower production with a representation of the energy storage capacity and water inflow time series of a reservoir for HydroGen\n\n\n\n\n\n","category":"type"},{"location":"api/public/#HydroPowerSimulations.HydroDispatchRunOfRiver","page":"Public API Reference","title":"HydroPowerSimulations.HydroDispatchRunOfRiver","text":"Formulation type to add injection variables constrained by a maximum injection time series for HydroGen\n\n\n\n\n\n","category":"type"},{"location":"api/public/#HydroPowerSimulations.HydroEnergyOutput","page":"Public API Reference","title":"HydroPowerSimulations.HydroEnergyOutput","text":"Auxiliary Variable for Hydro Models that solve for total energy output\n\n\n\n\n\n","category":"type"},{"location":"api/public/#HydroPowerSimulations.HydroEnergyShortageVariable","page":"Public API Reference","title":"HydroPowerSimulations.HydroEnergyShortageVariable","text":"Struct to dispatch the creation of a slack variable for energy storage levels < target storage levels\n\nDocs abbreviation: E^shortage\n\n\n\n\n\n","category":"type"},{"location":"api/public/#HydroPowerSimulations.HydroEnergyVariableUp","page":"Public API Reference","title":"HydroPowerSimulations.HydroEnergyVariableUp","text":"Struct to dispatch the creation of a variable for energy storage level (state of charge) of upper reservoir\n\nDocs abbreviation: E^up\n\n\n\n\n\n","category":"type"},{"location":"api/public/#HydroPowerSimulations.ReservoirLimitFeedforward","page":"Public API Reference","title":"HydroPowerSimulations.ReservoirLimitFeedforward","text":"Adds a constraint to limit the sum of a variable over the number of periods to the source value\n\n\n\n\n\n","category":"type"},{"location":"api/public/#HydroPowerSimulations.ReservoirLimitParameter","page":"Public API Reference","title":"HydroPowerSimulations.ReservoirLimitParameter","text":"Parameter to define energy limit\n\n\n\n\n\n","category":"type"},{"location":"api/public/#HydroPowerSimulations.ReservoirTargetFeedforward","page":"Public API Reference","title":"HydroPowerSimulations.ReservoirTargetFeedforward","text":"Adds a constraint to enforce a minimum reservoir level target with a slack variable associated with a penalty term.\n\nFields:\n\noptmization_container_key ->\nsource - From where the data comes\naffected_values -\n\n\n\n\n\n","category":"type"},{"location":"api/public/#HydroPowerSimulations.ReservoirTargetParameter","page":"Public API Reference","title":"HydroPowerSimulations.ReservoirTargetParameter","text":"Parameter to define energy target\n\n\n\n\n\n","category":"type"},{"location":"api/public/#HydroPowerSimulations.WaterSpillageVariable","page":"Public API Reference","title":"HydroPowerSimulations.WaterSpillageVariable","text":"Struct to dispatch the creation of energy (water) spillage variable representing energy released from a storage/reservoir not injected into the network\n\nDocs abbreviation: S\n\n\n\n\n\n","category":"type"}]
}
