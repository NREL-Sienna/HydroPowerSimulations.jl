using PowerNetworkMatrices

function validate_all_positive_ts(t_series)
    flag = true
    for val in t_series
        if val[2] < 0
            flag = false
            #break
        end
    end
    return flag
end

function validate_all_negative_ts(t_series)
    flag = true
    for val in t_series
        if val[2] > eps()
            flag = false 
            break
        end
    end
    return flag
end

function validate_float_ts(t_series)
    flag = true
    for val in t_series
        if typeof(val[2]) != Float64
            flag = false 
            break
        end
    end
    return flag
end

function validate_components_ts(component, sys)
    component_one_negative = []
    component_all_negative = []
    component_float        = []
    for element in get_components( component, sys )
        ts = get_time_series_array(SingleTimeSeries, element, "max_active_power")
        if !validate_all_positive_ts(ts)
            push!(component_one_negative, element.name )
        end
        if validate_all_negative_ts(ts)
            push!(component_all_negative, element.name )
        end
        if !validate_float_ts(ts)
            push!(component_float, element.name )
        end
    end
    return component_one_negative, component_all_negative, component_float
end

function remove_connected_devices_to_isolated_bus!( sys::System, devices )
    for device in devices
        @info "Removing device $(device.name) because it is connected to an isolated bus."
        remove_component!(sys, device)
    end
end

function remove_devices_in_isolated_bus!(
    sys::System, 
    node::ACBus, 
    Rgen_in_buses::Vector{RenewableDispatch},
    Tgen_in_buses::Vector{ThermalStandard},
    Loads_in_buses::Vector{PowerLoad}
    )
    remove_component!(sys, node)
    remove_connected_devices_to_isolated_bus!( sys, Rgen_in_buses )
    remove_connected_devices_to_isolated_bus!( sys, Tgen_in_buses )
    remove_connected_devices_to_isolated_bus!( sys, Loads_in_buses )
end

function check_elements_connected( buses_v, sys::System, remove_flag::Bool )
    Lines_in_buses  = Dict{String, Vector{Line}}()
    Trafos_in_buses = Dict{String, Vector{Transformer2W}}()
    Loads_in_buses  = Dict{String, Vector{PowerLoad}}()
    Tgen_in_buses   = Dict{String, Vector{ThermalStandard}}()
    Rgen_in_buses   = Dict{String, Vector{RenewableDispatch}}()
    for node in buses_v
        Lines_in_buses[node.name]  = collect(get_components(x-> x.arc.from.number==node.number || x.arc.to.number==node.number, Line, sys))
        Trafos_in_buses[node.name] = collect(get_components(x-> x.arc.from.number==node.number || x.arc.to.number==node.number, Transformer2W, sys))
        Loads_in_buses[node.name]  = collect(get_components(x-> x.bus.number==node.number, PowerLoad, sys))
        Tgen_in_buses[node.name]   = collect(get_components(x-> x.bus.number==node.number, ThermalStandard, sys))
        Rgen_in_buses[node.name]   = collect(get_components(x-> x.bus.number==node.number, RenewableDispatch, sys))
        
        if remove_flag
            remove_devices_in_isolated_bus!( sys, node , Rgen_in_buses[node.name], Tgen_in_buses[node.name], Loads_in_buses[node.name] )
        end
    end
    return Lines_in_buses, Trafos_in_buses, Loads_in_buses, Tgen_in_buses, Rgen_in_buses
end

function get_string_element_connected(elements_in_bus)
    elements_in_bus_str = ""
    for element in elements_in_bus
        elements_in_bus_str = elements_in_bus_str * " + " * element.name
    end
    #println(elements_in_bus_str)
    return elements_in_bus_str

end

function get_strings_elements_connected(Lines_in_bus, Trafos_in_bus, Loads_in_bus, Tgen_in_bus, Rgen_in_bus)
    lines_str = get_string_element_connected(Lines_in_bus)
    trafos_str= get_string_element_connected(Trafos_in_bus)
    loads_str = get_string_element_connected(Loads_in_bus)
    Tgen_str  = get_string_element_connected(Tgen_in_bus)
    Rgen_str  = get_string_element_connected(Rgen_in_bus)
    return [lines_str, trafos_str, loads_str, Tgen_str, Rgen_str]
end


function get_gentype_basic_data_df!( df, capacity_v, gen_type, sys )
    gen_capacity = 0
    if gen_type == ThermalStandard
        gtype = "ThermalStandard"
    elseif gen_type == HydroDispatch
        gtype = "HydroDispatch"
    elseif gen_type == RenewableDispatch
        gtype = "RenewableDispatch"
    else
        gtype = "NA"
    end
    for gen in get_components(gen_type, sys)
        push!(df, (GenName=gen.name, Type=gtype, Rating=gen.rating, BusName=gen.bus.name, BusNumber=gen.bus.number, Area=gen.bus.area.name) )
        gen_capacity = gen_capacity + gen.rating
    end
    push!( capacity_v, gen_capacity )
end

#------------------------------------------------------


subnetworks_dict = find_subnetworks(sys)
isolated_buses_numbers_v = Int64[]
for (key, set_val) in subnetworks_dict
    if length( set_val ) <= 1
        push!( isolated_buses_numbers_v, key )
    end
end

isolated_buses_v = collect( get_components( x-> x.number in isolated_buses_numbers_v, ACBus, sys ) )
Lines_in_isolated_buses, Trafos_in_isolated_buses, Loads_in_isolated_buses, Tgen_in_isolated_buses, Rgen_in_isolated_buses = check_elements_connected( isolated_buses_v, sys, true )

buses138_v = collect( get_components( x-> x.base_voltage==138.0, ACBus, sys ) )
buses230_v = collect( get_components( x-> x.base_voltage==230.0, ACBus, sys ) )
buses345_v = collect( get_components( x-> x.base_voltage==345.0, ACBus, sys ) )
buses69_v  = collect( get_components( x-> x.base_voltage==69.0, ACBus, sys ) )

df_bus_topology = DataFrame(BusName = String[], BusNumber = Int64[], Bvoltage = Float64[], BusType = ACBusTypes[], Lines = String[], Trafos=String[], Loads=String[], TGens=String[], RGens=String[])
buses_all_v = get_components(ACBus, sys)

Lines_in_all_buses, Trafos_in_all_buses, Loads_in_all_buses, Tgen_in_all_buses, Rgen_in_all_buses = check_elements_connected( buses_all_v, sys, false )
i = 0
for node in buses_all_v
    connections_str_v = get_strings_elements_connected(Lines_in_all_buses[node.name], Trafos_in_all_buses[node.name], Loads_in_all_buses[node.name], Tgen_in_all_buses[node.name], Rgen_in_all_buses[node.name])
    #println(connections_str_v)
    push!( df_bus_topology , ( BusName=node.name, BusNumber = node.number, Bvoltage = node.base_voltage, BusType = node.bustype, Lines=connections_str_v[1], Trafos=connections_str_v[2], Loads=connections_str_v[3], TGens=connections_str_v[4], RGens=connections_str_v[5] ) )
end
sort!(df_bus_topology,:Bvoltage, rev = true)
CSV.write("Check_topologia.csv", df_bus_topology)




#Check time series
Rgen_1neg, Rgen_aneg, Rgen_float = validate_components_ts(RenewableDispatch, sys)
load_1neg, load_aneg, load_float = validate_components_ts(PowerLoad, sys)
Hgen_1neg, Hgen_aneg, Hgen_float = validate_components_ts(HydroDispatch, sys)



#Make a dataframe for loads time series
df_load = DataFrame()
load    = first(get_components(PowerLoad, sys))
ts      = get_time_series_array(SingleTimeSeries, load, "max_active_power")
tstamps = timestamp(ts)
df_load[!, "DateTime"] = tstamps
for l in get_components(PowerLoad, sys)
    name = get_name(l)
    tseries = get_time_series_array(SingleTimeSeries, l, "max_active_power")
    vals = values(tseries)
    df_load[!, name] = vals
end




#Check models of generator_active_power_keys
gen_basic_data_df = DataFrame(GenName=String[], Type=String[], Rating=Float64[], BusName=String[], BusNumber=Int[], Area=String[]) 
gen_components_v  = [ ThermalStandard, HydroDispatch, RenewableDispatch ]
gen_capacity_v    = []

for i in eachindex(gen_components_v)
    get_gentype_basic_data_df!( gen_basic_data_df, gen_capacity_v, gen_components_v[i], sys )
end
sort!(gen_basic_data_df,[:Type, :Area, :Rating], rev = true)
CSV.write("Check_gen_basic_data_df.csv", gen_basic_data_df)
grouped_gen_df = combine(groupby(gen_basic_data_df, [:Type, :Area]), :Rating => sum)
#------------------------------------------------------