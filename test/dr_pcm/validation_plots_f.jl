include("utils_plots.jl")

function get_plt_bess_string( battery::EnergyReservoirStorage )
    rating   = get_rating( battery )
    cap      = get_storage_capacity( battery )
    bat_bus  = get_bus(battery).number
    return string( bat_bus ) * "_" * string( Int( round( rating ) ) ) * "MW" * string( Int( round( cap ) ) ) * "h"
end

function get_plt_complete_bess_str( sys::System )
    bess_str = ""
    for battery in get_components( x -> x.rating > 0.0, EnergyReservoirStorage, sys )
        aux_str = get_plt_bess_string( battery::EnergyReservoirStorage )
        bess_str = bess_str * "--" * aux_str
    end
    return bess_str
end

function execute_validation_plots( 
    sys::System, 
    uc::PowerSimulations.SimulationProblemResults;
    dir_f_emmissions_file::String = "code Sienna data/Data for simulation/emissions_factors_by_fuel.csv",
    dir_fuel_resources_file::String = "code_sienna_data/data for simulation/fuel_resources.csv",
    flag_hydro_curtailment::Bool = false,  #Put true if you want to compute Hydro curtailment
    )
    @info "*************************************"
    rel_path_rvalidation = "results_validation/"
    if !isdir( rel_path_rvalidation )
        mkdir( rel_path_rvalidation )
    end

    batteries_v =  get_components( x -> x.rating > 0.0, EnergyReservoirStorage, sys )
        number_bess = length( collect( batteries_v ) )
        if number_bess == 0
            rt_cap_str = "_0_0"
        else
            rt_cap_str = get_plt_complete_bess_str( sys ) * "-$(number_bess)bess" 
        end


    current_date = string( today() )
    if !isdir( rel_path_rvalidation * current_date * rt_cap_str * "/" )
        mkdir( rel_path_rvalidation * current_date * rt_cap_str * "/" )
    end

    rel_path_rvalidation     = rel_path_rvalidation * current_date * rt_cap_str * "/"
    rel_path_rvalidation_csv = rel_path_rvalidation * "csv_results/"

    if !isdir(rel_path_rvalidation_csv)
        mkdir(rel_path_rvalidation_csv)
    end

    uc_variable_keys   = list_variable_names(uc)
    uc_expression_keys = list_expression_names(uc)
    uc_parameter_keys  = list_parameter_names(uc)

    df_generic_data = read_realized_variable(uc, first(uc_variable_keys))
    steps_sim = Int64( round( size( df_generic_data )[1] / 24.0 ) )         #For hourly simulations
    initial_date = Dates.format(df_generic_data[1,"DateTime"], "yyyy-mm-dd")

    kind_components_v  = unique( typeof.( get_components( Component, sys ) ) )

    #-----HEAT MAP PLOTS OF EXPRESSIONS-----
    @info "--Ploting UC Expressions heat maps--"
    expresions_dict = read_realized_expressions(uc, list_expression_names(uc))
    for key in keys(expresions_dict)
        modify_df_for_heatmap_plot!( expresions_dict[ key ] )
        plot_dispatch_heatmap( expresions_dict[ key ], "Exp_"*key, rel_path_rvalidation )
    end
    @show key_thermal = filter(s -> occursin("ProductionCostExpression__Thermal", s), collect( keys(expresions_dict) ) )
    monthly_Tcost_dict = get_monthly_dict( expresions_dict, key_thermal )
    monthly_bar_plot( monthly_Tcost_dict, "Cost_[USD]", current_date, rel_path_rvalidation, rel_path_rvalidation_csv )

    #-----HEAT MAP PLOTS OF OBTAINED SLACKS-----
    @info "--Ploting slacks heat maps--"
    slacks_keys          = filter( x -> contains(x, "Slack"), uc_variable_keys )
    slacks_dispatch_dict = Dict{String, DataFrame}()
    slacks_reserve_dict  = Dict{String, DataFrame}()
    slacks_branchflow_dict = Dict{String, DataFrame}()
    slacks_index_dict    = Dict{String, Vector{Int64}}()
    slacks_branchs_dict  = Dict{String, Vector{Any}}()
    slacks_st_inj_dict   = Dict{String, Vector{Any}}()
    for slack_key in slacks_keys
        if contains( slack_key , "Balance" )
            slacks_dispatch_dict[ slack_key ] = read_realized_variable(uc, slack_key)
            modify_df_for_heatmap_plot!( slacks_dispatch_dict[ slack_key ] )
            plot_dispatch_heatmap( slacks_dispatch_dict[ slack_key ], "Slack_"*slack_key, rel_path_rvalidation  )

        elseif contains( slack_key , "Reserve" )
            slacks_reserve_dict[ slack_key ] = read_realized_variable(uc, slack_key)
            modify_df_for_heatmap_plot!( slacks_reserve_dict[ slack_key ] )
            plot_dispatch_heatmap( slacks_reserve_dict[ slack_key ], "Slack_"*slack_key, rel_path_rvalidation  )

        elseif contains( slack_key , "Transformer" ) || contains( slack_key , "Line" )
            slacks_branchflow_dict[ slack_key ], slacks_index_dict[ slack_key ], slacks_branchs_dict[ slack_key ], slacks_st_inj_dict[ slack_key ] = see_2bus_slack_elements( sys, uc, slack_key )
            modify_df_for_heatmap_plot!( slacks_branchflow_dict[ slack_key ] )
            plot_dispatch_heatmap( slacks_branchflow_dict[ slack_key ], "Slack_"*slack_key, rel_path_rvalidation  )
        end
        
    end
    monthly_SlackGen_dict = get_monthly_dict( slacks_dispatch_dict, collect( keys(slacks_dispatch_dict) ) )
    monthly_SlackRes_dict = get_monthly_dict( slacks_reserve_dict, collect( keys(slacks_reserve_dict) ) )
    monthly_SlackBra_dict = get_monthly_dict( slacks_branchflow_dict, collect( keys(slacks_branchflow_dict) ) )
    monthly_bar_plot( monthly_SlackGen_dict, "SlackGen", current_date, rel_path_rvalidation, rel_path_rvalidation_csv )
    monthly_bar_plot( monthly_SlackRes_dict, "SlackRes", current_date, rel_path_rvalidation, rel_path_rvalidation_csv )
    monthly_bar_plot( monthly_SlackBra_dict, "SlackBranches", current_date, rel_path_rvalidation, rel_path_rvalidation_csv )


    #-----HEAT MAP PLOTS OF OBTAINED DISPATCHS BY SOURCE-----
    @info "--Ploting SIENNA dispatchs by source heat maps--"
    generator_active_power_keys = filter( x -> startswith(x, "ActivePowerVariable"), uc_variable_keys ) 
    gen_dispatch_dict           = Dict{String, DataFrame}()
    #monthly_dispatch_dict       = Dict{String, Vector{Float64}}()
    for gen_type_key in generator_active_power_keys
        if contains(gen_type_key,"ThermalStandard")
            aux_df         = read_realized_variable(uc, gen_type_key)
            cols_to_remove = filter(col -> startswith(col, "IMPORT") || startswith(col, "EXPORT"), names(aux_df))
            cols_import    = filter(col -> startswith(col, "IMPORT") , names(aux_df)) #["DateTime"]
            cols_export    = filter(col -> startswith(col, "EXPORT") , names(aux_df)) #["DateTime"]
            pushfirst!( cols_import , "DateTime" )
            pushfirst!( cols_export , "DateTime" )
            gen_dispatch_dict[ "Import" ] = aux_df[ !, cols_import ]
            gen_dispatch_dict[ "Export" ] = aux_df[ !, cols_export ]
            gen_dispatch_dict[ gen_type_key ] = select!(aux_df, Not(cols_to_remove))
        else
            gen_dispatch_dict[ gen_type_key ] = read_realized_variable(uc, gen_type_key)
        end
        CSV.write(rel_path_rvalidation_csv * current_date * "_" * "Hourly " * gen_type_key * "_" * string(steps_sim) * "steps" * ".csv" , gen_dispatch_dict[ gen_type_key ])
        
        modify_df_for_heatmap_plot!( gen_dispatch_dict[ gen_type_key ] )
        plot_dispatch_heatmap( gen_dispatch_dict[ gen_type_key ], "_Dispatch[MW]_" * gen_type_key, rel_path_rvalidation )
    end

    #modify_df_for_heatmap_plot!( gen_dispatch_dict[ "Import" ] )
    #plot_dispatch_heatmap( gen_dispatch_dict[ "Import" ], "Import", rel_path_rvalidation )
    #CSV.write(rel_path_rvalidation_csv * current_date * "_" * "Hourly Import" * "_" * string(steps_sim) * "steps" * ".csv" , gen_dispatch_dict[ "Import" ])
    #modify_df_for_heatmap_plot!( gen_dispatch_dict[ "Export" ] )
    #plot_dispatch_heatmap( gen_dispatch_dict[ "Export" ], "Export", rel_path_rvalidation )

    @info "--Ploting SIENNA Monthly dispatchs bar plots by source--"
    #generator_active_power_keys_imports = vcat( ["Import"], generator_active_power_keys )
    monthly_dispatch_dict = get_monthly_dict( gen_dispatch_dict, generator_active_power_keys )
    monthly_bar_plot( monthly_dispatch_dict, "Dispatch [MWh]", current_date, rel_path_rvalidation, rel_path_rvalidation_csv )

    #monthly_exchange_dict = get_monthly_dict( gen_dispatch_dict, ["Import", "Export"] )
    #monthly_bar_plot( monthly_exchange_dict, "Exchange [MWh]", current_date, rel_path_rvalidation, rel_path_rvalidation_csv )



    @info "--Ploting SIENNA Monthly dispatchs bar plots by zone--"
    gen_types_v            = unique( typeof.(get_components(Generator, sys)) )
    #=gnames_by_zone_by_type_dic = get_gen_names_by_zone_by_type_dict( sys )
    monthly_bar_plot_by_zone(sys, gen_dispatch_dict, gnames_by_zone_by_type_dic, gen_types_v, "Dispatch by zone [MWh]", current_date, rel_path_rvalidation,"",true)
=#

    # EMISSION PLOTS
    @info "--Ploting SIENNA Monthly Fuel consuption and Emissions bar plots --"
    if isfile( dir_fuel_resources_file ) && isfile( dir_f_emmissions_file )
        generator_fuel_data_no_ef = CSV.read( dir_fuel_resources_file, DataFrame )
        fuel_emissions_data       = CSV.read( dir_f_emmissions_file, DataFrame )
        
        fuel_c_mbtu_dict      = Dict{String, DataFrame}()
        emissions_tkgco2_dict = Dict{String, DataFrame}()
        names_by_fuel_dict    = Dict{String, Vector{String}}()

        fuel_c_keys           = unique( generator_fuel_data_no_ef[!,:fuel_type] )

        generator_fuel_data  = get_emissions_df_by_unit( generator_fuel_data_no_ef, fuel_emissions_data )

        fuel_c_mbtu_df      = get_datetime_df_from_df( gen_dispatch_dict["ActivePowerVariable__ThermalStandard"] )
        emissions_tkgco2_df = get_datetime_df_from_df( gen_dispatch_dict["ActivePowerVariable__ThermalStandard"] )

        for k in fuel_c_keys
            fuel_c_mbtu_dict[k]      = fuel_c_mbtu_df
            emissions_tkgco2_dict[k] = fuel_c_mbtu_df
            names_by_fuel_dict[k]    = ["DateTime"]
        end

        for gen in names(gen_dispatch_dict["ActivePowerVariable__ThermalStandard"])[2:end-5]
            for row in eachrow(generator_fuel_data)
                if row["Name"] == gen
                    heat_rate = row["Fuel Rate"]
                    emission_f= row["emission_factor_ton_mmbtu"]
                    
                    fuel_c_mbtu_df[!, gen]      = gen_dispatch_dict["ActivePowerVariable__ThermalStandard"][!,gen] .* heat_rate
                    emissions_tkgco2_df[!, gen] = fuel_c_mbtu_df[!, gen] .* emission_f

                    push!(names_by_fuel_dict[ row["fuel_type"] ], gen)
                    break
                end
            end
        end
        modify_df_for_heatmap_plot!( fuel_c_mbtu_df )
        plot_dispatch_heatmap( fuel_c_mbtu_df, "Fuel Total Consumption [MBTU]_", rel_path_rvalidation )
        modify_df_for_heatmap_plot!( emissions_tkgco2_df )
        plot_dispatch_heatmap( emissions_tkgco2_df, "Fuel Total Emissions [t]", rel_path_rvalidation )

        #Split by fuel
        for k in fuel_c_keys

            aux_names_v = names_by_fuel_dict[ k ]

            fuel_c_mbtu_dict[k]     = fuel_c_mbtu_df[!, aux_names_v]
            emissions_tkgco2_dict[k] = emissions_tkgco2_df[!, aux_names_v]
            if size( fuel_c_mbtu_dict[k] )[2] > 1
                modify_df_for_heatmap_plot!( fuel_c_mbtu_dict[k] )
                plot_dispatch_heatmap( fuel_c_mbtu_dict[k], "Fuel Consumption [MBTU]_" * k, rel_path_rvalidation )
            end
            
            if size( emissions_tkgco2_dict[k] )[2] > 1
                modify_df_for_heatmap_plot!( emissions_tkgco2_dict[k] )
                plot_dispatch_heatmap( emissions_tkgco2_dict[k], "Fuel Emissions [t]_" * k, rel_path_rvalidation )
            end
        end

        monthly_fuel_c_mbtu_dict      = get_monthly_dict( fuel_c_mbtu_dict, fuel_c_keys )
        monthly_emissions_tkgco2_dict = get_monthly_dict( emissions_tkgco2_dict, fuel_c_keys )
        monthly_bar_plot( monthly_fuel_c_mbtu_dict, "Fuel consumption [MBTU]", current_date, rel_path_rvalidation, rel_path_rvalidation_csv )
        monthly_bar_plot( monthly_emissions_tkgco2_dict, "CO2 Emissions [t]", current_date, rel_path_rvalidation, rel_path_rvalidation_csv )
        
    else
        @info "--There is no CSV file containing emission factors and/or fuel type of each plant: $(dir_fuel_resources_file)--"
    end
    
    #-----HEAT MAP PLOTS FOR RESERVES----- 
    @info "--Ploting Reserves heat maps--"
    gen_names_by_type_dict = get_gen_names_by_type( sys, gen_types_v )

    reserves_keys             = filter( x -> startswith(x, "ActivePowerReserveVariable"), uc_variable_keys ) 
    reserves_dict             = Dict{String, DataFrame}()
    for reserve in reserves_keys
        reserve_shortname = replace(reserve, "ActivePowerReserveVariable__VariableReserve_" => "" )
        reserves_dict[ reserve ] = read_realized_variable(uc, reserve)
        modify_df_for_heatmap_plot!( reserves_dict[ reserve ] )
        plot_dispatch_heatmap( reserves_dict[ reserve ], "Reserve_[MW]_" * reserve_shortname, rel_path_rvalidation )
        reserves_by_gen_type_dict = get_reserves_by_gen_type( reserves_dict, gen_names_by_type_dict, gen_types_v, reserve, reserve_shortname, rel_path_rvalidation )
    end

    #-----CURTAILMENT HEAT MAP PLOTS -----
    @info "--Ploting Curtailment heat maps--"
    
    if flag_hydro_curtailment
        gen_parameter_keys = filter(x -> contains(x, "HydroEnergyReservoir") || contains(x, "HydroDispatch") || contains(x, "RenewableDispatch"), uc_parameter_keys)
    else
        gen_parameter_keys = filter(x -> contains(x, "RenewableDispatch"), uc_parameter_keys)
    end
    curtailment_keys = []
    gen_parameter_dict = Dict{String, DataFrame}()
    gen_curtailment_dict = Dict{String, DataFrame}()

    for param_key in gen_parameter_keys
        aux_key = replace(param_key, "ActivePowerTimeSeriesParameter" => "ActivePowerVariable") 
        gen_parameter_dict[ aux_key ] = read_realized_variable(uc, param_key)
        modify_df_for_heatmap_plot!( gen_parameter_dict[ aux_key ] )
        
        push!( curtailment_keys, aux_key )
        #gen_curtailment_dict[ aux_key ] = gen_parameter_dict[ aux_key ][!,2:end-5] .- gen_dispatch_dict[ aux_key ][!,2:end-5] #OLD Method
        gen_curtailment_dict[ aux_key ] = get_curtailment_df( gen_parameter_dict[ aux_key ][!,2:end-5], gen_dispatch_dict[ aux_key ][!,2:end-5], reserves_dict["ActivePowerReserveVariable__VariableReserve__ReserveUp__Reg Arriba"][!,2:end-5], reserves_dict["ActivePowerReserveVariable__VariableReserve__ReserveUp__Primaria"][!,2:end-5] )
        gen_curtailment_dict[ aux_key ] = hcat(gen_parameter_dict[ aux_key ][:, :DateTime], gen_curtailment_dict[ aux_key ])
        DataFrames.rename!(gen_curtailment_dict[ aux_key ], :x1 => :DateTime)
        modify_df_for_heatmap_plot!( gen_curtailment_dict[ aux_key ] )
        plot_dispatch_heatmap( gen_curtailment_dict[ aux_key ], "Curtailment [MW]"*aux_key, rel_path_rvalidation )
    end
    monthly_curtailment_dict = get_monthly_dict( gen_curtailment_dict, curtailment_keys )
    monthly_bar_plot( monthly_curtailment_dict, "Curtailment [MWh]", current_date, rel_path_rvalidation, rel_path_rvalidation_csv )

    monthly_parameter_dict              = get_monthly_dict( gen_parameter_dict, curtailment_keys )
    monthly_curtailment_percentage_dict = Dict{String, Vector{Float64}}()
    for key in curtailment_keys
        monthly_curtailment_percentage_dict[ key ] = ( monthly_curtailment_dict[ key ] ./ monthly_parameter_dict[ key ] ) .* 100
        CSV.write(rel_path_rvalidation_csv * current_date * "_" * "Hourly_Curtailment_" * key * "_" * string(steps_sim) * "steps" * ".csv" , gen_curtailment_dict[ key ])
        CSV.write(rel_path_rvalidation_csv * current_date * "_" * "Hourly_Parameter_" * key * "_" * string(steps_sim) * "steps" * ".csv" , gen_parameter_dict[ key ])
        CSV.write(rel_path_rvalidation_csv * current_date * "_" * "Hourly_Gen_" * key * "_" * string(steps_sim) * "steps" * ".csv" , gen_dispatch_dict[ key ])

    end
    @show monthly_curtailment_dict
    monthly_curtailment_percentage_dict[ "Month" ] = monthly_curtailment_dict[ "Month" ]
    monthly_bar_plot( monthly_curtailment_percentage_dict, "Curtailment [%]", current_date, rel_path_rvalidation, rel_path_rvalidation_csv, false )

    #@info "--Ploting SIENNA Monthly Curtailment bar plots by zone--"
    #monthly_bar_plot_by_zone(sys, gen_curtailment_dict, gnames_by_zone_by_type_dic, gen_types_v, "Curtailment by zone [MWh]", current_date, rel_path_rvalidation,"",true)

    #-----HEAT MAP PLOTS FOR BESS-----
    @info "--Ploting BESS heat maps--"
    storage_keys      = filter( x -> contains(x, "Storage"), uc_variable_keys )
    storage_var_dict  = Dict{String, DataFrame}()
    storage_keys_split_dict = Dict{String, Dict}()
    for storage_key in storage_keys
        storage_split_dict  = Dict{String, DataFrame}()
        storage_var_dict[ storage_key ] = read_realized_variable(uc, storage_key)
        storage_split_dict = get_dict_with_unstack_df_by_hour( sys, read_realized_variable(uc, storage_key), storage_key, rel_path_rvalidation, rel_path_rvalidation_csv )
        storage_keys_split_dict[storage_key] = storage_split_dict
        
        modify_df_for_heatmap_plot!( storage_var_dict[ storage_key ] )
        plot_dispatch_heatmap( storage_var_dict[ storage_key ], "storage_"*storage_key, rel_path_rvalidation  )
        CSV.write(rel_path_rvalidation_csv * current_date * "_" * "Hourly_storage_" * storage_key * "_" * string(steps_sim) * "steps" * ".csv" , storage_var_dict[ storage_key ])
        
    end

    cost_df = get_cost_per_mwh_df(sys, uc)
    _= get_dict_with_unstack_df_by_hour( sys, cost_df, " ", rel_path_rvalidation, rel_path_rvalidation_csv )
    
    # MAKE GENERATION DATAFRAMES BY PLANT
    #=plant_dispatch_dict = Dict{String, DataFrame}()
    plant_units_dict    = Dict{String, Dict}()
    complete_plant_df   = get_datetime_df_from_df( gen_dispatch_dict[ "Import" ] )
    plant_basic_info_df = DataFrame( plant_name = String[], Rating = Float64[], Lat = Float64[], Long = Float64[] )
    for (key, df) in gen_dispatch_dict
        plant_dispatch_dict[key], plant_units_dict[key] = get_plant_df( df )

        for col in names(plant_dispatch_dict[key][! , 2:end])
            complete_plant_df[! , Symbol(col)] = plant_dispatch_dict[key][! , col]
            push!(plant_basic_info_df, (col, get_plant_rating( sys, col ), 14.0, -85.0 ))
            rating_pp = get_plant_rating( sys, col )
        end
    end

    storage_ch_dis_keys= filter( x -> contains(x, "In") || contains(x, "Out"), storage_keys )
    for (key, df) in storage_var_dict
        if contains( key, "In" )
            for col in names(df[! , 2:end-5])
                complete_plant_df[! , Symbol(col*"_ch")] = df[! , col]
            end
        elseif contains( key, "Out" )
            for col in names(df[! , 2:end-5])
                complete_plant_df[! , Symbol(col*"_dis")] = df[! , col]
            end
        end
    end

    CSV.write(rel_path_rvalidation_csv * current_date * "_" * "Hourly Plant" * "_" * string(steps_sim) * "steps" * ".csv" , complete_plant_df)
    CSV.write(rel_path_rvalidation_csv * current_date * "_" * "Plant Info" * ".csv" , plant_basic_info_df)
    =#



    if any(x -> x == "FlowActivePowerVariable__Line", uc_variable_keys)
        #-----HEAT MAP PLOTS OF OBTAINED DISPATCHS BY INTERFACE-----   
        @info "--Ploting Interfaces Power Flows heat maps--"
        Plines           = read_realized_variable(uc, "FlowActivePowerVariable__Line")
        Pinterface_dict  = Dict{String, DataFrame}()
        for interface in get_components(TransmissionInterface, sys)
            println(interface.name)
            #TrInt         = get_component(TransmissionInterface, sys, interface.name)
            devices_TrInt = get_contributing_devices(sys, interface)
            contributing_names_v = ["DateTime"] #Plus "DateTime"
            for device in devices_TrInt
                push!(contributing_names_v, device.name)
                #println(device.name)
            end
            Pinterface_dict[ interface.name ] = Plines[ ! , contributing_names_v ]
            modify_df_for_heatmap_plot!( Pinterface_dict[ interface.name ] )
            plot_dispatch_heatmap( Pinterface_dict[ interface.name ], "Interface_"*interface.name, rel_path_rvalidation  )
        end
        monthly_Interface_dict = get_monthly_dict( Pinterface_dict, collect(keys(Pinterface_dict)) )
        monthly_bar_plot( monthly_Interface_dict, "Interface_[MWh]", current_date, rel_path_rvalidation, rel_path_rvalidation_csv, false )

        # --- ANALYSIS OF INTERREGIONAL POWER EXCHANGES 
        @info "--Ploting heat maps of Interregional Energy Exchange--"
        Lines_inter_region_dict, Signal_inter_region_dict, total_rating_dict = get_lines_interregion( sys )

        P_interregion_dict = Dict{String, DataFrame}()
        Ppu_interregion_dict = Dict{String, DataFrame}()
        for (key, lines_v) in Lines_inter_region_dict
            P_interregion_dict[ key ] = get_interregion_df( Plines, lines_v, Signal_inter_region_dict[ key ] )

            modify_df_for_heatmap_plot!( P_interregion_dict[ key ] )
            plot_dispatch_heatmap( P_interregion_dict[ key ], "Inter_Region_exchange_[MW]"*key, rel_path_rvalidation  )
            CSV.write(rel_path_rvalidation_csv * current_date * "_" * "Hourly_MW " * key * "_" * string(steps_sim) * "steps" * ".csv" , P_interregion_dict[ key ])


            aux_df    = get_datetime_df_from_df( P_interregion_dict[ key ] )
            aux_df[!,"Total"] = P_interregion_dict[ key ][!,"Total"] ./ total_rating_dict[ key ]
            Ppu_interregion_dict[key] = aux_df
            modify_df_for_heatmap_plot!( Ppu_interregion_dict[ key ] )
            plot_dispatch_heatmap( Ppu_interregion_dict[ key ], "Inter_Region_pu_exchange_"*key, rel_path_rvalidation  )
            CSV.write(rel_path_rvalidation_csv * current_date * "_" * "Hourly_pu " * key * "_" * string(steps_sim) * "steps" * ".csv" , Ppu_interregion_dict[ key ])
        end
    end

    #=if rt_cap_str == "_0_0"
        #-----HEAT MAP PLOTS OF ACTUAL DATA FROM PROVIDED TIME SERIES-----
        @info "--Ploting heat maps of actual data from provided time series--"
        generator_data         = CSV.read("code Sienna data/Data for simulation/resources_hydro_corrected.csv", DataFrame)
        generation_time_series = CSV.read("code Sienna data/Data for simulation/resources_time_series_curtailment_and_hydro corrected.csv", DataFrame, typemap=Dict(String7 => Float64))
        #generation_time_series.FECHA = DateTime.(generation_time_series.FECHA, dateformat"mm/dd/yyyy HH:MM")

        thermal_generators_df = filter( row->row["Type"]=="Thermal" && row["TS column name"]!="NO_TS", generator_data )
        thermal_ts_name       = ["DateTime"]
        thermal_ts_name = vcat(thermal_ts_name,unique(thermal_generators_df[!, "TS column name"]))


        thermal_generators_ts_df = generation_time_series[!, Cols(thermal_ts_name; operator=union)]
        #DataFrames.rename!(thermal_generators_ts_df, :FECHA => :DateTime)
        modify_df_for_heatmap_plot!( thermal_generators_ts_df )
        plot_dispatch_heatmap( thermal_generators_ts_df, "Actual Thermal Dispatch", rel_path_rvalidation  )
        thermal_generators_ts_simtime_df = filter( row -> row["DateTime"]>=DateTime(initial_date * "T00:00:00") && row["DateTime"]<=DateTime(initial_date * "T23:00:00") + Day(steps_sim-1), thermal_generators_ts_df )
        #modify_df_for_heatmap_plot!( thermal_generators_ts_simtime_df )
        plot_dispatch_heatmap( thermal_generators_ts_simtime_df, "Actual Thermal Dispatch", rel_path_rvalidation  )

        Ptermica = gen_dispatch_dict["ActivePowerVariable__ThermalStandard"]
        abs_err_df = DataFrame(DateTime = Ptermica.DateTime, Total = Ptermica.Total .- thermal_generators_ts_simtime_df.Total)
        rel_err_df = DataFrame(DateTime = Ptermica.DateTime, Total = (Ptermica.Total .- thermal_generators_ts_simtime_df.Total) ./ thermal_generators_ts_simtime_df.Total )
        modify_df_for_heatmap_plot!( abs_err_df )
        plot_dispatch_heatmap( abs_err_df, "abs_err_df", rel_path_rvalidation  )
        modify_df_for_heatmap_plot!( rel_err_df )
        plot_dispatch_heatmap( rel_err_df, "rel_err_df", rel_path_rvalidation  )

        abs_Tdisp_error_dict = Dict{String, DataFrame}()
        abs_Tdisp_error_dict[ "ThermalDispatch" ] = abs_err_df
        monthly_abs_Tdisp_error_dict = get_monthly_dict( abs_Tdisp_error_dict, collect(keys(abs_Tdisp_error_dict)) )
        monthly_bar_plot( monthly_abs_Tdisp_error_dict, "Absolute Error Thermal Dispatch [MWh]", current_date, rel_path_rvalidation, rel_path_rvalidation_csv )
        rel_Tdisp_error_dict = Dict{String, DataFrame}()
        rel_Tdisp_error_dict[ "ThermalDispatch" ] = rel_err_df
        monthly_rel_Tdisp_error_dict = get_monthly_dict( rel_Tdisp_error_dict, collect(keys(rel_Tdisp_error_dict)) )
        monthly_bar_plot( monthly_rel_Tdisp_error_dict, "Relative Error Thermal Dispatch [%]", current_date, rel_path_rvalidation, rel_path_rvalidation_csv )
    end=#



    to_json(sys, rel_path_rvalidation*"dr_system.json"; force = true)

    #=Plant = "CANAVERAL"
    gen_unit = "_1"
    hydro_param=read_realized_variable(uc, "ActivePowerTimeSeriesParameter__HydroEnergyReservoir")
    hydro_dispatch=read_realized_variable(uc, "ActivePowerVariable__HydroEnergyReservoir")
    df_comp = hcat(hydro_param[: , [:DateTime]], hydro_param[:, [:CANAVERAL_1]], hydro_dispatch[:, [:CANAVERAL_1]], makeunique=true)
    trace4 = scatter( x = df_comp.DateTime, y = df_comp.CANAVERAL_1, mode = "lines", name = "Parametro"*Plant*gen_unit )
    trace5 = scatter( x = df_comp.DateTime, y = df_comp.CANAVERAL_1, mode = "lines", name = "Despacho"*Plant*gen_unit )
    p10=plot([trace4, trace5])

    Plant = "CANAVERAL"
    gen_unit = "_2"
    df_comp = hcat(hydro_param[: , [:DateTime]], hydro_param[:, [:CANAVERAL_1]], hydro_dispatch[:, [:CANAVERAL_1]], makeunique=true)
    trace4 = scatter( x = df_comp.DateTime, y = df_comp.CANAVERAL_1, mode = "lines", name = "Parametro"*Plant*gen_unit )
    trace5 = scatter( x = df_comp.DateTime, y = df_comp.CANAVERAL_1, mode = "lines", name = "Despacho"*Plant*gen_unit )
    p11=plot([trace4, trace5])=#
end

