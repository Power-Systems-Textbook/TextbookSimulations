function delete_bus!(
    bus::Int64,
    network_data::Dict{String,Any};
    auto_delete_load::Bool=false,
    auto_delete_generator::Bool=false,
    auto_delete_lines::Bool=false,
)
    # Check if the specified bus exists
    check_bus_existence(bus, network_data)

    # Check if there is a load connected to the specified bus; delete if specified
    if !isnothing(access_specified_load(bus, network_data))
        if auto_delete_load
            delete_load!(bus, network_data)
        else
            throw(
                ErrorException(
                    "Bus " *
                    string(bus) *
                    " contains a load. Please remove this load before deleting this bus.",
                ),
            )
        end
    end

    # Check if there is a generator connected to the specified bus; delete if specified
    if !isnothing(access_specified_generator(bus, network_data))
        if auto_delete_generator
            delete_generator!(bus, network_data)
        else
            throw(
                ErrorException(
                    "Bus " *
                    string(bus) *
                    " contains a generator. Please remove this generator before deleting " *
                    "this bus.",
                ),
            )
        end
    end

    # Check if there are lines connected to the specified bus
    for l in keys(network_data["branch"])
        other_buses = Set()
        if (network_data["branch"][l]["f_bus"] == bus) |
           (network_data["branch"][l]["t_bus"] == bus)
            push!(
                other_buses,
                network_data["branch"][l]["f_bus"] != bus ?
                network_data["branch"][l]["f_bus"] : network_data["branch"][l]["t_bus"],
            )
        end
    end

    # If specified, delete all lines that are connected to the specified bus
    if !(isempty(other_buses))
        if auto_delete_lines
            for other_bus in other_buses
                delete_line!(bus, other_bus, network_data)
            end
        else
            throw(
                ErrorException(
                    "Bus " *
                    string(bus) *
                    " has lines connecting to it. Please remove any conected lines " *
                    "before deleting this bus.",
                ),
            )
        end
    end

    # Remove the specified bus
    delete!(network_data["bus"], string(bus))

    # Reorganize the order of the bus IDs
    for i = 1:length(network_data["bus"])
        if i >= bus
            network_data["bus"][string(i)] = pop!(network_data["bus"], string(i + 1))
            network_data["bus"][string(i)]["bus_i"] = i
            network_data["bus"][string(i)]["source_id"] = ["bus", i]
            network_data["bus"][string(i)]["index"] = i
        end
    end

    # Update the bus IDs in the load data
    for i = 1:length(network_data["load"])
        if network_data["load"][string(i)]["load_bus"] >= bus
            network_data["load"][string(i)]["source_id"][2] -= 1
            network_data["load"][string(i)]["load_bus"] -= 1
        end
    end

    # Update the bus IDs in the generator data
    for i = 1:length(network_data["gen"])
        if network_data["gen"][string(i)]["gen_bus"] >= bus
            network_data["gen"][string(i)]["gen_bus"] -= 1
        end
    end

    # Update the bus IDs in the line data
    for i = 1:length(network_data["branch"])
        if network_data["branch"][string(i)]["b_fr"] >= bus
            network_data["branch"][string(i)]["b_fr"] -= 1
        end
        if network_data["branch"][string(i)]["t_fr"] >= bus
            network_data["branch"][string(i)]["t_fr"] -= 1
        end
    end
end

function delete_load!(bus::Int64, network_data::Dict{String,Any})
    # Check if the specified bus exists
    check_bus_existence(bus, network_data)

    # Determine the user-specified load
    d = access_specified_load(bus, network_data)

    # Raise an error if the specified load does not exist
    if isnothing(d)
        throw(
            ErrorException(
                "A load does not exist at Bus " * string(bus) * ". Please try again.",
            ),
        )
    end

    # Remove the load at the specified bus from the network data
    delete!(network_data["load"], string(d))

    # Reorganize the order of load IDs
    for i = 1:length(network_data["load"])
        if i >= d
            network_data["load"][string(i)] = pop!(network_data["load"], string(i + 1))
            network_data["load"][string(i)]["index"] = i
        end
    end
end

function delete_generator!(bus::Int64, network_data::Dict{String,Any})
    # Check if the specified bus exists
    check_bus_existence(bus, network_data)

    # Determine the user-specified generator
    g = access_specified_generator(bus, network_data)

    # Raise an error if the specified generator does not exist
    if isnothing(g)
        throw(
            ErrorException(
                "A generator does not exist at Bus " * string(bus) * ". Please try again.",
            ),
        )
    end

    # Remove the generator at the specified bus from the network data
    delete!(network_data["gen"], string(g))

    # Reorganize the order of generator IDs
    for i = 1:length(network_data["gen"])
        if i >= g
            network_data["gen"][string(i)] = pop!(network_data["gen"], string(i + 1))
            network_data["gen"][string(i)]["source_id"] = ["gen", i]
            network_data["gen"][string(i)]["index"] = i
        end
    end
end

function delete_line!(bus_from::Int64, bus_to::Int64, network_data::Dict{String,Any})
    # Check if the specified buses exist
    for bus in (bus_from, bus_to)
        check_bus_existence(bus, network_data)
    end

    # Determine the user-specified line
    l = access_specified_line(bus_from, bus_to, network_data)

    # Raise an error if the specified branch does not exist
    if isnothing(l)
        throw(
            ErrorException(
                "A branch does not exist between Bus " *
                string(bus_from) *
                " and Bus " *
                string(bus_to) *
                ". Please try again.",
            ),
        )
    end

    # remove the line between the specified buses in the network data
    delete!(network_data["branch"], string(l))

    # Reorganize the order of branch IDs
    for i = 1:length(network_data["branch"])
        if i >= l
            network_data["branch"][string(i)] = pop!(network_data["branch"], string(i + 1))
            network_data["branch"][string(i)]["source_id"] = ["branch", i]
            network_data["branch"][string(i)]["index"] = i
        end
    end

    # Check if removing the specified line strands either of the specified buses
    check_if_bus_is_stranded(bus_from, network_data)
    check_if_bus_is_stranded(bus_to, network_data)
end
