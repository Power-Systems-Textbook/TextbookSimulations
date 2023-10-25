"""
    check_bus_existence(bus::Int64, network_data::Dict{String,Any})

Checks that a user-specified exists within the network data Dict. Throws an error if the 
specified bus does not exist.
"""
function check_bus_existence(bus::Int64, network_data::Dict{String,Any})
    # Throw an error if the bus doesn't exist; otherwise, do nothing
    if !(string(bus) in keys(network_data["bus"]))
        throw(ErrorException("Bus " * string(bus) * " does not exist. Please try again."))
    end
end

"""
    access_specified_line(
        bus_from::Int64,
        bus_to::Int64,
        network_data::Dict{String,Any},
    )::Union{Int64,Nothing}

Returns the line ID of the line between two user-specified buses. Returns "nothing" if the 
line does not exist (i.e., there is not line between the user-specified buses).
"""
function access_specified_line(
    bus_from::Int64,
    bus_to::Int64,
    network_data::Dict{String,Any},
)::Union{Int64,Nothing}
    # Look up the specified line
    for l in keys(network_data["branch"])
        if (
            (network_data["branch"][l]["f_bus"] == bus_from) &
            (network_data["branch"][l]["t_bus"] == bus_to)
        ) | (
            (network_data["branch"][l]["t_bus"] == bus_from) &
            (network_data["branch"][l]["f_bus"] == bus_to)
        )
            return parse(Int64, l)
        end
    end

    # Return nothing if the specified line does not exist
    return nothing
end

"""
    access_specified_load(
        bus::Int64,
        network_data::Dict{String,Any},
    )::Union{Int64,Nothing}

Returns the load ID of the load associated with the user-specified bus. Returns "nothing" 
if the load does not exist (i.e., there is no load at the user-specified bus).
"""
function access_specified_load(
    bus::Int64,
    network_data::Dict{String,Any},
)::Union{Int64,Nothing}
    # Look up the specified load
    for d in keys(network_data["load"])
        if network_data["load"][d]["load_bus"] == bus
            return parse(Int64, d)
        end
    end

    # Return nothing if the specified load does not exist
    return nothing
end

"""
    access_specified_generator(
        bus::Int64,
        network_data::Dict{String,Any},
    )::Union{Int64,Nothing}

Returns the generator ID of the generator associated with the user-specified bus. Returns 
"nothing" if the generator does not exist (i.e., there is no generator at the user-
specified bus).
"""
function access_specified_generator(
    bus::Int64,
    network_data::Dict{String,Any},
)::Union{Int64,Nothing}
    # Look up the specified generator
    for g in keys(network_data["gen"])
        if network_data["gen"][g]["gen_bus"] == bus
            return parse(Int64, g)
        end
    end

    # Return nothing if the specified generator does not exist
    return nothing
end

"""
    check_generator_for_slack_and_pv_buses(network_data::Dict{String,Any})

Checks that there are generators at the slack and PV buses. Throws an error if a slack or 
PV bus is found to not have a generator.
"""
function check_generator_for_slack_and_pv_buses(network_data::Dict{String,Any})
    # Iterate through the buses
    for b in keys(network_data["bus"])
        # Check if the bus is a slack or PV bus
        if network_data["bus"][b]["bus_type"] in (2, 3)
            # Check if the slack or PV bus is in the list of buses with generators
            if !(
                parse(Int64, b) in
                [network_data["gen"][g]["gen_bus"] for g in keys(network_data["gen"])]
            )
                # Raise an error if the slack or PV bus does not match with any generator
                bus_type = network_data["bus"][b]["bus_type"] == 3 ? "slack" : "PV"
                throw(
                    ErrorException(
                        "Though listed as a " *
                        bus_type *
                        " bus, Bus " *
                        b *
                        " does not contain a generator. Please try again.",
                    ),
                )
            end
        end
    end
end

"""
    check_slack_bus_existence!(
        network_data::Dict{String,Any};
        assign_slack::Union{Int64,Nothing}=nothing,
    )

Checks the existence of the slack bus in the provided network data. If it doesn't exist, 
an error is thrown unless the user specifies a valid existing PV bus to be set as the 
slack bus instead.
"""
function check_slack_bus_existence!(
    network_data::Dict{String,Any};
    assign_slack::Union{Int64,Nothing}=nothing,
)
    # Initialize an empty vector to track PV buses
    pv_buses = zeros(0)

    # Iterate through the buses, keeping track of PV buses or breaking if a slack bus is 
    # identified
    for b in keys(network_data["bus"])
        if network_data["bus"][b]["bus_type"] == 2
            append!(pv_buses, b)
        elseif network_data["bus"][b]["bus_type"] == 3
            return nothing
        end
    end

    # If no slack bus exists, assign an existing bus to be the slack bus, if specified
    if isnothing(assign_slack)
        throw(ErrorException("There is no slack bus specified. Please try again."))
    else
        if assign_slack in pv_buses
            network_data["bus"][b]["bus_type"] = assign_slack
        else
            throw(
                ErrorException(
                    "Bus " *
                    string(assign_slack) *
                    " is not a valid bus to be turned into the slack bus, either because " *
                    "the bus is not a PV bus or because the bus does not exist. Please " *
                    "try again.",
                ),
            )
        end
    end
end

"""
    check_if_bus_is_stranded(bus::Int64, network_data::Dict{String,Any})

Checks if a specified bus is stranded (i.e., the bus is not connected to the other buses 
via any branches). Raises a warning if the specified bus is found to be stranded.
"""
function check_if_bus_is_stranded(bus::Int64, network_data::Dict{String,Any})
    # Check if the specified bus exists
    check_bus_existence(bus, network_data)

    # Iterate through line data to obtain a set of all bus connections
    connected_buses = Set()
    for l = 1:length(network_data["branch"])
        push!(connected_buses, network_data["branch"][string(l)]["f_bus"])
        push!(connected_buses, network_data["branch"][string(l)]["t_bus"])
    end

    # Check if the specified bus is in the connected_buses set
    if !(bus in connected_buses)
        @warn(
            "Bus " *
            string(bus) *
            " is stranded. Please update your network so that all buses are connected " *
            "prior to computing the power flow solution."
        )
    else
        println("Bus " * string(bus) * " is not stranded.")
    end
end

"""
    check_for_stranded_buses(network_data::Dict{String,Any})

Checks all buses in the network data Dict to see if there are any stranded buses (i.e., 
buses that are not connected to the other buses via any branches). Throws an error if a 
stranded bus is located.
"""
function check_for_stranded_buses(network_data::Dict{String,Any})
    # Iterate through line data to obtain a set of all bus connections
    connected_buses = Set()
    for l = 1:length(network_data["branch"])
        push!(connected_buses, network_data["branch"][string(l)]["f_bus"])
        push!(connected_buses, network_data["branch"][string(l)]["t_bus"])
    end

    # Iterate through the buses to see if they're in the connected_buses set
    for b = 1:length(network_data["bus"])
        if !(b in connected_buses)
            throw(
                ErrorException(
                    "Bus " *
                    string(b) *
                    " is stranded. Please update your network so that all buses are " *
                    "connected and try again.",
                ),
            )
        end
    end
end
