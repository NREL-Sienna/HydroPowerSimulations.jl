using PlotlyJS
using Dates
using DataFrames
using CSV
using Combinatorics

function get_cost_per_mwh_df(
    sys::System,
    uc::PowerSimulations.SimulationProblemResults,
)
    cost_hourly_df=read_realized_expressions(uc, list_expression_names(uc))["ProductionCostExpression__ThermalStandard"]
    themal_P = read_realized_variable(uc, "ActivePowerVariable__ThermalStandard")
    cost_per_mwh_df = cost_hourly_df[!,2:end] ./ themal_P[!,2:end]
    for col in names(cost_per_mwh_df)
        cost_per_mwh_df[!, col] = Union{Float64, Missing}[cost_per_mwh_df[!, col]...]  # Convert column to support missing
    end
    
    # Replace all NaN values with missing
    for col in names(cost_per_mwh_df)
        replace!(cost_per_mwh_df[!, col], NaN => missing)
    end
    
    cost_expensive_unit_v = [maximum(skipmissing(row)) for row in eachrow(Matrix(cost_per_mwh_df))]
    cost_expensive_unit_df = get_datetime_df_from_df(cost_hourly_df)
    cost_expensive_unit_df.cost_per_MWh = cost_expensive_unit_v
    return cost_expensive_unit_df
end

function get_box_plot( 
        df_split_by_hour::DataFrame, 
        plot_title::String,
        rel_path_rvalidation::String,
        rel_path_rvalidation_csv::String,
        y_axis_title::String = "Power",
        y_axis_units::String = "[MW]",
        x_axis_title::String = "Hour",
        x_axis_units::String = "",
        )
    if y_axis_title == "Energy"
        y_axis_units = "[MWh]"
    elseif y_axis_title == "Cost"
        y_axis_units = "[USD/MWh]"
    end
    traces =[
        box(; 
            y = df_split_by_hour[!, name], 
            name = name,
            marker_color = "blue"
            ) 
            for name in names(df_split_by_hour[!, 1:end])]
    layout = Layout(;
        title = plot_title,
        yaxis = attr(; title = y_axis_title * y_axis_units),
        xaxis = attr(; title = x_axis_title * x_axis_units),
    )
    data = traces
    p = PlotlyJS.plot(data, layout)
    display(p)

    current_date = string( today() )
    fig_name =  current_date * "_" * plot_title * ".png"
    savefig(p, rel_path_rvalidation * fig_name )
    CSV.write(rel_path_rvalidation_csv * current_date * "_Unstack_df_" * fig_name * ".csv" , df_split_by_hour)    
end

function get_equivalent_cycles(
    sys::System,
    hourly_p_v,
    storage_name::String = ""
  )
    bess = get_component( EnergyReservoirStorage, sys, storage_name )
    rating = get_rating( bess ) * ( get_base_power(sys) / get_base_power(bess) )
    capacity = get_storage_capacity( bess )
    nominal_energy = get_base_power( bess ) * capacity
    total_energy = sum( hourly_p_v )
    try 
        return Int64( round( total_energy/nominal_energy ) )
    catch
        return 0
    end
end

function get_dict_with_unstack_df_by_hour(
    sys::System,
    df::DataFrame, 
    key::String,
    rel_path_rvalidation::String,
    rel_path_rvalidation_csv::String,
    )
    # Extract the hour for each row and create a new column "Hour"
    df.Hour = hour.(df.DateTime)
    df.Day  = day.(df.DateTime)
    df.Month  = month.(df.DateTime)
    # Initialize the dictionary to store results
    result_dict = Dict{String, DataFrame}()
    # Iterate through the non-DateTime columns
    for column in names(df)
        if ( column in ["DateTime", "Month", "Hour", "Day"] )
            continue
        end

        # Filter the data for the current column and pivot by hour
        sub_df = unstack(df[!, ["Month", "Day", "Hour", column]], [:Month, :Day], :Hour, column)
        
        # Add to dictionary
        result_dict[column] = sub_df
        if occursin("EnergyReservoirStorage", key)
            if occursin("RegularizationVariable", key) 
                continue
            end
            if occursin("EnergyVariable", key)
                get_box_plot( sub_df[!,3:end], "Box plot BESS " * key * " " * column, rel_path_rvalidation, rel_path_rvalidation_csv, "Energy ", "[MWh]" )
                continue
            end
            @info "Computing equivalent cycles for BESS $column"
            @show equivalent_cycles = get_equivalent_cycles( sys, df[!,column], column )
            get_box_plot( sub_df[!,3:end], "Box plot BESS " * key * " " * column * "--Equivalent Cycles = " * string(equivalent_cycles), rel_path_rvalidation, rel_path_rvalidation_csv, "Power ", "[MW]" )

        elseif occursin("Cost", key)
            get_box_plot( sub_df[!,3:end], "Box plot " * key * " " * column, rel_path_rvalidation, rel_path_rvalidation_csv, "Cost ", "[USD/MWh]" )
        end
    end

    return result_dict
end

function modify_df_for_heatmap_plot!( 
    df_dispatch::DataFrame 
    )
    df_dispatch[!,"Total"] = sum(eachcol(df_dispatch[!,2:end]))   #Sum Power of all units at each hour and Add colum "Total"
    transform!(df_dispatch, :DateTime => ByRow(x -> (Date(x), Time(x))) => [:Date, :Time])     #Splits datetime column in date and time
    df_dispatch.Month = Dates.month.(df_dispatch."DateTime") 
    df_dispatch.Year  = Dates.year.(df_dispatch."DateTime")
end

function plot_dispatch_heatmap( 
    df_dispatch::DataFrame, 
    title_str::String, 
    rel_path_rvalidation::String="results_validation/" 
    )
    dates     = unique( df_dispatch.Date )
    steps_sim = size(dates)[1]
    m = zeros( steps_sim, 24 )
    i = 1
    for d in dates
        m[i:i,:] = transpose( filter(row -> row.Date == d, df_dispatch).Total )
        i = i + 1
    end
    #DUE TO CONFLICTS MUST COMMENT POWERGRAPHICS AND POWEEANALYTICS
    current_date = string( today() )
    fig_name =  current_date * "_" * title_str * "_" * string(steps_sim) * "steps" * ".png"
    p = PlotlyJS.plot(
        heatmap(
            x=[0; 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20; 21; 22; 23],
            y=dates,
            z=m,
            cbar_title="MW",
            ),
        Layout(title=fig_name, xaxis_side="bottom")
        )
    
    savefig(p, rel_path_rvalidation * fig_name )

end

function get_2bus_component_type(slack_var_str::String)
    if occursin("Line", slack_var_str)
        component_type = Line
    elseif occursin("Transformer2W", slack_var_str)
        component_type = Transformer2W
    elseif occursin("TapTransformer", slack_var_str)
        component_type = TapTransformer
    end
    return component_type
end

function see_2bus_slack_elements( sys::System, uc:: PowerSimulations.SimulationProblemResults, slack_var_str::String )
    slack_df  = read_realized_variable(uc, slack_var_str)
    slack_cols_index   = findall( col -> any(i->i!=0, col) , eachcol( slack_df[!,2:end] ) ) .+ 1#  findall( x -> !all(i->i==0, x) , eachcol( slack_df[!,2:end] ) ) .+ 1
    
    if length(slack_cols_index) < 1
        println("There are not slack violations of $slack_var_str")
        return slack_df, [], [], []
    end

    #plot_dataframe(slack_df, title="slack_var_str")
    println(slack_var_str)
    
    components_v       = []
    StaticInj_2bus_v   = []
    component_type     = get_2bus_component_type(slack_var_str)

    for n in names(slack_df)[slack_cols_index]
        component = get_component(component_type, sys, n)
        push!(components_v, component)
        push!( StaticInj_2bus_v, get_components(x -> get_number(get_bus(x)) == component.arc.from.number || get_number(get_bus(x)) == component.arc.to.number , StaticInjection, sys) )
    end
    
    return slack_df, slack_cols_index, components_v, StaticInj_2bus_v
end


function get_gen_names_by_type( sys::System, gen_types_v::Vector{DataType} )
    gen_names_by_type_dict = Dict{String, Vector{String}}()
    for type in gen_types_v
        type_str = string( type )
        gen_names_by_type_dict[ type_str ] = []
        for gen in get_components(type, sys)
            push!(gen_names_by_type_dict[ type_str ], gen.name)
        end
    end
    return gen_names_by_type_dict
end

function get_reserves_by_gen_type( 
    reserves_dict::Dict, 
    gen_names_by_type_dict::Dict,
    gen_types_v::Vector{DataType},
    reserve::String,
    reserve_shortname::String,
    rel_path_rvalidation::String 
    )
    reserves_by_gen_type_dict = Dict{String, DataFrame}()

    for g_type in gen_types_v
        reserve_names_v = names(reserves_dict[ reserve ])
        common_names    = intersect( gen_names_by_type_dict[ string(g_type) ], reserve_names_v )
        if length(common_names) > 0
            filter_keys = ["DateTime"]
            filter_keys = vcat(filter_keys, common_names)
            reserves_by_gen_type_dict[ string(g_type)*reserve_shortname ] = reserves_dict[ reserve ][!,filter_keys]
            modify_df_for_heatmap_plot!( reserves_by_gen_type_dict[ string(g_type)*reserve_shortname ] )
            plot_dispatch_heatmap( reserves_by_gen_type_dict[ string(g_type)*reserve_shortname ], "Reserve_[MW]" * string(g_type)*reserve_shortname, rel_path_rvalidation )
        end   
    end
    return reserves_by_gen_type_dict
end

#------- FUNCTIONS FOR MONTHLY PLOTS ----------

function get_months_index(
    hourly_dict::Dict,
    keys_v::Union{Vector{String}, Vector{String15}, Vector{Any}}
)
    for k in keys_v
        if "Month" in names( hourly_dict[k] )
            return unique( hourly_dict[k][ : , :Month ] )
        end
    end
end

function get_monthly_dict( 
    hourly_dict::Dict, 
    keys_v::Union{Vector{String}, Vector{String15}, Vector{Any}} 
    )
    if length(hourly_dict) == 0
        @info "--Dict is empty--"
        return Dict{String, Vector{Float64}}()
    end
    monthly_dict = Dict{String, Vector{Float64}}()

    monthly_dict["Month"] = get_months_index( hourly_dict, keys_v )
    for k in keys_v
        if size( hourly_dict[ k ] )[2] > 1
            
            result_df = combine(groupby(hourly_dict[ k ], [:Year, :Month]), names(hourly_dict[ k ])[2:end-4] .=> sum)
            monthly_dict[ k ] = result_df.Total_sum
        end
    end
    return monthly_dict
end

function select_color( key )
    flag = true

    if occursin("ThermalStandard", key) 
        marker_color = "#ff4d4d"
    elseif occursin("HydroEnergyReservoir", key) 
       marker_color = "#007bff"
    elseif occursin("HydroDispatch", key) 
       marker_color = "#00baff"
    elseif occursin("RenewableDispatch", key) 
        marker_color = "#00b330"
    elseif occursin("Coal", key) 
        marker_color = "black"
    elseif occursin("Bunker", key) 
        marker_color = "#7f7f7f"
    elseif occursin("Diesel", key)
       marker_color = "#a07800"
    elseif occursin("Natural Gas", key)
        marker_color = "#ffa94e"
    else
        marker_color = "#ffcfce"
        flag = false
    end
    return flag, marker_color
end
function monthly_bar_plot( 
    monthly_dict::Dict, 
    fig_key_name::String, 
    current_date::String, 
    rel_path_rvalidation::String, 
    rel_path_rvalidation_csv::String,
    flag_stack::Bool = true
    )
    
    if length(monthly_dict) == 0
        @info "--Dict $fig_key_name is empty--"
        return Dict{String, Vector{Float64}}()
    end
    x_vals       = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dec"]
    x_vals       = x_vals[ Int64.( monthly_dict["Month"] ) ]
    
    # Create a list of bar traces for each category 
    if haskey( monthly_dict , "Month" )
        keys_monthly_dict = filter( x -> x != "Month", keys( monthly_dict ) )
    else
        keys_monthly_dict = keys( monthly_dict )
    end
    traces = [ 
        begin 
            flag_color, m_color = select_color( key )
            if flag_color == true
                bar( x = x_vals, y = monthly_dict[key], name = key, marker_color = m_color ) 
            else 
                bar( x = x_vals, y = monthly_dict[key], name = key ) 
            end 
        end
        for key in keys_monthly_dict 
            ]
    # Create the plot and set barmode to stack
    if flag_stack
        p = PlotlyJS.plot(traces, Layout(barmode="stack", title="Monthly " * fig_key_name, xaxis_title="Month")) 
    else
        p = PlotlyJS.plot(traces, Layout(barmode="unstack", title="Monthly " * fig_key_name, xaxis_title="Month")) 
    end
    display(p)
    fig_name =  current_date * "_" * "Monthly " * fig_key_name * "_" * string(steps_sim) * "steps" * ".png"
    savefig(p, rel_path_rvalidation * fig_name )
    CSV.write(rel_path_rvalidation_csv * current_date * "_" * "Monthly " * fig_key_name * "_" * string(steps_sim) * "steps" * ".csv" , monthly_dict)
end


# ----------- FUNCTIONS TO COMPUTE CURTAILMENT -------------------------

function get_curtailment_df( 
    parameter::DataFrame, 
    dispatch::DataFrame, 
    reserves_up::DataFrame, 
    r_primaria_up::DataFrame 
    )
    
    curtailment = DataFrame()
    
    for name in names( parameter ) 
        @info "--- Computing curtailment of $(name) ---"
        curtailment[ ! , name ] = parameter[ ! , name ] - dispatch[ ! , name ] 

        if name in names( reserves_up )
            @info "    $(name) Reserve up"
            curtailment[ ! , name ] = curtailment[ ! , name ] - reserves_up[ ! , name ]
        end

        if name in names( r_primaria_up )
            @info "    $(name) Reserve primaria"
            curtailment[ ! , name ] = curtailment[ ! , name ] - r_primaria_up[ ! , name ]
        end
        
    end
    return curtailment
end

# ----------- FUNCTIONS TO MAKE GENERATION DATAFRAMES BY PLANT -------------------------
function remove_after_last_underscore( 
    input_string::String 
    )::String 

    last_index = findlast(==('_'), input_string) 
    return last_index === nothing ? input_string : input_string[1:last_index-1]
end

function get_plant_names_v( names_gen::Vector{String} )
    for i in eachindex(names_gen)
        names_gen[i] =  remove_after_last_underscore(names_gen[i])
    end
    return unique(names_gen)
end

function get_datetime_df_from_df( template_df::DataFrame )
    df = DataFrame()
    df[!,"DateTime"] = template_df[!,"DateTime"]
    return df
end

function get_plant_df( gen_units_df::DataFrame )
    names_gen   = names( gen_units_df[!,2:end-5] )
    plant_names = get_plant_names_v( names_gen )
    plant_df    = get_datetime_df_from_df( gen_units_df )

    plant_units_dict = Dict{String, Vector{String}}()
    for name in plant_names
        filtered_cols = filter(col -> startswith(string(col), name), names(gen_units_df[!,2:end-5]) ) 
        # Select the filtered columns from the DataFrame 
        plant_vals = sum( eachcol( gen_units_df[!,2:end-5][:, filtered_cols] ) ) 
        plant_df[!, Symbol(name)] = plant_vals

        plant_units_dict[name] = filtered_cols
    end
    return plant_df, plant_units_dict
end

function get_plant_rating( 
    sys::System, 
    plant_name::String 
    )
    sienna_gen_unnits_v = collect(get_components(x-> startswith(x.name,plant_name) , Generator, sys))
    plant_rating = 0.0
    for gen in sienna_gen_unnits_v
        unit_rating = 1.0

        if typeof(gen) == RenewableDispatch
            unit_rating = gen.base_power
        else
            unit_rating = gen.base_power * gen.active_power_limits[2]
        end

        plant_rating = plant_rating + unit_rating
    end
    return plant_rating
end

function get_generator_type( key::String )
    if key == contains("HydroEnergyReservoir") || key == contains("HydroDispatch")
        technology = "Hydro"
    elseif key == contains("ThermalStandard") 
        technology = "Oil"
    elseif key == contains("RenewableDispatch")
        technology = "Wind/Solar"
    else
        technology = key
    end
    return technology
end

#---------- FUNCTIONS FOR EMISSIONS CALCULATIONS --------------
function get_emissions_df_by_unit(
    generator_fuel_data::DataFrame, 
    fuel_emissions_data::DataFrame 
    )
    emissions_df = generator_fuel_data
    emissions_factors_v = []

    for row in eachrow( generator_fuel_data )

        key_fuel = filter( x -> x.Fuel_type == row["fuel_type"], fuel_emissions_data )
        push!( emissions_factors_v, key_fuel[1,"EmissionFactor_ton_co2_mmbtu"] )

    end
    emissions_df[!,"emission_factor_ton_mmbtu"] = emissions_factors_v
    return emissions_df
end

#---------- FUNCTIONS FOR INTERREGIONAL TRANSMISSION ANALYSIS --------------
function get_nzones_and_znames( sys::System )

    zones_names_v = []
    for zone in get_components(LoadZone, sys)
        push!( zones_names_v, zone.name )
    end

    n_zones = length(collect(get_components(LoadZone, sys)))

    return string.(zones_names_v), n_zones
end


function get_lines_interregion( sys::System )

    zones_names_v, n_zones = get_nzones_and_znames( sys )

    r_zones = 2
    c_zones = factorial(n_zones) / ( factorial(r_zones) * factorial( n_zones - r_zones ) )
    combinations_v = collect(combinations(1:n_zones, r_zones))
    base_power_sys = get_base_power(sys)

    Lines_inter_region   = Dict{String, Vector{Line}}()
    Signal_inter_region  = Dict{String, Vector{Int64}}()
    total_rating_dict    = Dict{String, Float64}()

    for c in combinations_v
        sum_rating = 0
        aux_v      = []
        aux_line_v = []
        zone_str_l = string( zones_names_v[ c[1] ] )
        zone_str_h = string( zones_names_v[ c[2] ] )
        for line in collect(get_components(x-> x.arc.from.load_zone.name==zone_str_l && x.arc.to.load_zone.name==zone_str_h, Line, sys))
            push!(aux_line_v, line )
            sum_rating = sum_rating + (line.rating * base_power_sys)
        end
        push!(aux_v, length( collect(get_components(x-> x.arc.from.load_zone.name==zone_str_l && x.arc.to.load_zone.name==zone_str_h, Line, sys)) ) )
        
        for line in collect(get_components(x-> x.arc.from.load_zone.name==zone_str_h && x.arc.to.load_zone.name==zone_str_l, Line, sys))
            push!(aux_line_v, line )
            sum_rating = sum_rating + (line.rating * base_power_sys)
        end
        push!(aux_v, length( collect(get_components(x-> x.arc.from.load_zone.name==zone_str_h && x.arc.to.load_zone.name==zone_str_l, Line, sys)) ) )
        
        if length( aux_line_v ) > 0
            Lines_inter_region[zone_str_l * "_" * zone_str_h]  = aux_line_v
            Signal_inter_region[zone_str_l * "_" * zone_str_h] = aux_v
            total_rating_dict[zone_str_l * "_" * zone_str_h]   = sum_rating
        end
    end
    
    return Lines_inter_region, Signal_inter_region, total_rating_dict
end

function get_interregion_df( 
    Plines, 
    lines_v, 
    signal_lin_v 
    )
    names_lines_v = ["DateTime"]
    for line in lines_v
        push!( names_lines_v, line.name )
    end

    P_interregion_df = Plines[!,names_lines_v[1:signal_lin_v[1]+1]]

    for col in names_lines_v[ signal_lin_v[1]+2 : end]
        P_interregion_df[ !, Symbol( col ) ] = Plines[!,col] .* (-1)
    end
    
    return P_interregion_df
end





#-------FUNCTIONS TO PLOT DISPATCH/CURTAILMENT BY ZONE-------
function monthly_bar_plot_by_zone(
    sys::System, 
    gen_dispatch_dict::Dict, 
    gnames_by_zone_by_type_dic::Dict,
    gen_types_v,
    fig_key_name::String, 
    current_date::String, 
    rel_path_rvalidation::String, 
    rel_path_rvalidation_csv::String,
    flag_stack::Bool = true
    )
    
    gen_h_by_zone_by_type_dic, gen_m_by_zone_by_type_dic = get_hourly_gen_values_by_zone_by_type_dict( gnames_by_zone_by_type_dic, gen_dispatch_dict, sys )
    @show gen_h_by_zone_by_type_dic
    months_index_v = get_months_index( gen_h_by_zone_by_type_dic["1"], collect( keys( gen_h_by_zone_by_type_dic["1"] ) ) )
    x_vals         = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dec"]

    zones_names_v, n_zones = get_nzones_and_znames( sys )
    x1             = replicate_vector_elements( x_vals[months_index_v], length( zones_names_v ) )

    x2 = repeat( zones_names_v, length( months_index_v ) )

    gen_types_e_v  = filter( x -> x != RenewableNonDispatch, gen_types_v )

    plot_dict = Dict{String, Vector{Float64}}()

    for gen_trace_name in gen_types_e_v
        plot_dict[ string(gen_trace_name) ] = get_gen_trace_vector_by_zone_by_month(gen_m_by_zone_by_type_dic, months_index_v, zones_names_v, string(gen_trace_name))
    end


    traces = [ 
    begin 
        flag_color, m_color = select_color( key )
        if flag_color
            bar( x = [x1,x2], y = plot_dict[key], name = key, marker_color = m_color )
        else
            bar( x = [x1,x2], y = plot_dict[key], name = key )
        end
        
    end
    for key in keys(plot_dict) 
        ]
    if flag_stack
        p = PlotlyJS.plot(traces, Layout(barmode="stack", title="Monthly " * fig_key_name, xaxis_title="Month"))
    else
        p = PlotlyJS.plot(traces, Layout(barmode="unstack", title="Monthly " * fig_key_name, xaxis_title="Month"))
    end
    display(p)

    fig_name =  current_date * "_" * "Monthly " * fig_key_name * "_" * string(steps_sim) * "steps" * ".png"
    savefig(p, rel_path_rvalidation * fig_name )   
end 


function get_gen_names_by_zone_by_type_dict( sys::System )

    zones_names_v, n_zones = get_nzones_and_znames( sys )

    gnames_by_zone_by_type_dic = Dict{String, Dict{String, Vector{String}}}()
    

    for zone in zones_names_v
        gen_types_v = unique( typeof.( get_components( y -> y.bus.load_zone.name == zone , Generator, sys ) ) )

        aux_dic                 = Dict{String, Vector{String}}()
        
        for g_type in gen_types_v
           if g_type == RenewableNonDispatch
                continue
           end
            aux_v = ["DateTime"]
            for gen in get_components(x -> x.bus.load_zone.name == zone , g_type, sys)
                push!( aux_v, gen.name )
            end
           
            aux_dic[ string(g_type) ] = aux_v
        end
        gnames_by_zone_by_type_dic[zone] = aux_dic
    end
    return gnames_by_zone_by_type_dic
end

function get_hourly_gen_values_by_zone_by_type_dict( 
    gnames_by_zone_by_type_dic::Dict, 
    gen_dispatch_dict::Dict,
    sys::System 
    )
    gen_h_by_zone_by_type_dic = Dict{String, Dict{String, DataFrame}}()
    gen_m_by_zone_by_type_dic = Dict{String, Dict{String, Vector{Float64}}}()

    zones_names_v, n_zones = get_nzones_and_znames( sys )

    for zone in zones_names_v
        #@show zone
        aux_dic     = Dict{String, DataFrame}()
        monthly_aux_dic = Dict{String, Vector{Float64}}()
        for g_type in keys( gnames_by_zone_by_type_dic[ zone ] )
            if !any( x -> contains( x, g_type ), collect(keys(gen_dispatch_dict))  )
                continue
            end
            #@show g_type
            names_v = gnames_by_zone_by_type_dic[ zone ][ g_type ]
            # Get the actual column names of the DataFrame
            actual_names = names(gen_dispatch_dict[ "ActivePowerVariable__"*g_type ])
            # Filter the names_v vector to keep only the names that exist in the DataFrame
            filtered_names_v = intersect(names_v, actual_names)

            aux_df = gen_dispatch_dict[ "ActivePowerVariable__"*g_type ][ !, filtered_names_v ]
            modify_df_for_heatmap_plot!( aux_df )
            aux_dic[ string(g_type) ] = aux_df

            result_df = combine(groupby(aux_df, [:Year, :Month]), names(aux_df)[2:end-4] .=> sum)
            monthly_aux_dic[ string(g_type) ] = result_df.Total_sum
        end

        gen_h_by_zone_by_type_dic[zone] = aux_dic
        gen_m_by_zone_by_type_dic[zone] = monthly_aux_dic

    end
    return gen_h_by_zone_by_type_dic, gen_m_by_zone_by_type_dic
end


function replicate_vector_elements(vec::Vector{T}, x::Int) where T
    # Initialize an empty vector to store the results
    result = T[]

    # Loop through each element in the original vector
    for element in vec
        # Append the element x times to the result vector
        append!(result, fill(element, x))
    end

    return result
end


function get_gen_trace_vector_by_zone_by_month( 
    gen_m_by_zone_by_type_dic::Dict,
    months_index_v::Vector{Int64},
    zones_names_v::Vector{String},
    gen_trace_name::String
 )
    aux_v = []
    #gen_trace_name = string( gen_types_e_v[1] )
    for month_index in eachindex(months_index_v)

        for zone in zones_names_v
            if haskey( gen_m_by_zone_by_type_dic[ zone ] , gen_trace_name )
                push!( aux_v , gen_m_by_zone_by_type_dic[ zone ][ gen_trace_name ][ month_index ] )
            else
                push!( aux_v , 0.0 )
            end
        end

    end
    return aux_v

end
