function set_upstream(sys::PSY.System, mapping::DataFrames.DataFrame)
    make_array(x) = ismissing(x) ? [] : split(strip(x, ['(', ')']), ",")
    for device in PSY.get_components(HydroEnergyCascade, sys)
        for upstream_device in
            make_array(mapping[findall(in([device.name]), mapping.hydrounit), :].upstream[1])
            if !isnothing(PSY.get_component(HydroEnergyCascade, sys, upstream_device))
                push!(
                    device.upstream,
                    PSY.get_component(HydroEnergyCascade, sys, upstream_device),
                )
            end
        end
    end
end
