
#FUNCTIONS FOR SYSTEM MODIFYING ACCORDING TO CASES DICT 
function set_active_bess!( sys::System, active_bess_name, power::Float64, cap_h::Float64 )
    batteries_v =  get_components( EnergyReservoirStorage, sys )

    for battery in batteries_v
        if battery.name == active_bess_name
            set_fixed_bess!( sys::System, active_bess_name, power::Float64, cap_h::Float64 )
        else 
            battery.available = false
            set_rating!( battery , 0.0 )
            set_input_active_power_limits!( battery , (min = 0.0, max = 0.0) )
            set_output_active_power_limits!( battery , (min = 0.0, max = 0.0) )
            set_storage_capacity!( battery , 0.0 )

        end
    end
end

function set_fixed_bess!( sys::System, active_bess_name, power::Float64, cap_h::Float64 )
    battery =  get_component( EnergyReservoirStorage, sys, active_bess_name  )
    battery.available = true
    set_rating!( battery , power )
    set_input_active_power_limits!( battery , (min = 0.0, max = power/battery.base_power) )
    set_output_active_power_limits!( battery , (min = 0.0, max = power/battery.base_power) )
    set_storage_capacity!( battery , (cap_h * power)/battery.base_power )
end


#STRINGS FOR FOLDER NAMING
function get_bess_string( battery::EnergyReservoirStorage )
    @show rating   = get_rating( battery )
    @show cap      = get_storage_capacity( battery )
    @show bat_bus  = get_number( get_bus(battery) )
    return string( bat_bus ) * "_" * string( Int( round( rating ) ) ) * "MW" * string( Int( round( cap ) ) ) * "h"
end

function get_complete_bess_str( sys::System )
    bess_str = ""
    for battery in get_components( x -> x.rating > 0.0, EnergyReservoirStorage, sys )
        aux_str = get_bess_string( battery )
        bess_str = bess_str * "--" * aux_str
    end
    return bess_str
end


#GET DICT FOR SIMULATED CASES
function get_cases_dict_parallel( bess_names_v, capacity_h_v, power_mw_v, fixed_bess_df,sys_location )
    cases_dict = Dict(
        "sys_location" =>String,
        "BESS_name" => String[],
        "Capacity_h" => Float64[],
        "Power_MW" => Float64[],
        "Fixed_BESS_df" => DataFrame
    )
    cases = []
    
    i = 1
    for bess_name in bess_names_v
        for cap_h in capacity_h_v
            for power in power_mw_v
                if power == 0.0
                    if cap_h != last( capacity_h_v )
                        continue
                    end
                    cap_h = 0.0
                end
                push!( cases_dict["BESS_name"], bess_name )
                push!( cases_dict["Capacity_h"], cap_h )
                push!( cases_dict["Power_MW"], power )
                push!( cases, i )
                i = i + 1
            end
        end
    end
    cases_dict["Fixed_BESS_df"] = fixed_bess_df
    cases_dict["sys_location"]  = sys_location
    return cases_dict, cases
end