function compute_ac_pf(network_data::Dict{String,Any})::Dict{String,Any}
    # Prior to computation, check if any buses are stranded
    check_for_stranded_buses(network_data)

    # Solve the AC power-flow model using PowerModels
    result = PowerModels.compute_ac_pf(network_data)

    # Take a copy of the network data for use in calculating the line flows
    _network_data = deepcopy(network_data)
    PowerModels.update_data!(_network_data, result["solution"])

    # Calculate the line flows
    result["solution"]["line_flows"] = PowerModels.calc_branch_flow_ac(_network_data)

    # Return the results Dictionary
    return result
end
