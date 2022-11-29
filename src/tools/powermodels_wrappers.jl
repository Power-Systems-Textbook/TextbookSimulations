function load_network_data(filepath::String, case_name::String)
    # Return the network data from the user-specified .m file
    return PowerModels.parse_file(joinpath(filepath, case_name * ".m"))
end

function compute_ac_pf(network_data)
    # Solve the AC power-flow model using PowerModels
    return PowerModels.compute_ac_pf(network_data)
end
