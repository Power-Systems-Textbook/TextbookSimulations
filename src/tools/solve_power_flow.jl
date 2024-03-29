"""
    compute_ac_pf(
        network_data::Dict{String,Any};
        show_trace::Bool=false,
    )::Dict{String,Any}

Creates a wrapper around functionality from PowerModels.jl to solve the AC power-flow 
problem. Line flows are also calculated and returned along with the typical bus-level 
solutions.
"""
function compute_ac_pf(
    network_data::Dict{String,Any};
    show_trace::Bool=false,
)::Dict{String,Any}
    # Check that buses listed as slack and PV buses have generators
    check_generator_for_slack_and_pv_buses(network_data)

    # Check that there is a slack bus
    check_slack_bus_existence!(network_data)

    # Prior to computation, check if any buses are stranded
    check_for_stranded_buses(network_data)

    # Solve the AC power-flow model using PowerModels
    result = PowerModels.compute_ac_pf(network_data; show_trace=show_trace)

    # Take a copy of the network data for use in calculating the line flows
    _network_data = deepcopy(network_data)
    PowerModels.update_data!(_network_data, result["solution"])

    # Calculate the line flows
    result["solution"]["line_flows"] = PowerModels.calc_branch_flow_ac(_network_data)

    # Return the results Dictionary
    return result
end
