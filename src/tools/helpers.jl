function check_bus_existence(bus::Int64, network_data::Dict{String,Any})
    # Throw an error if the bus doesn't exist; otherwise, do nothing
    if !(string(bus) in keys(network_data["bus"]))
        throw(ErrorException("Bus " * string(bus) * " does not exist. Please try again."))
    end
end

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
