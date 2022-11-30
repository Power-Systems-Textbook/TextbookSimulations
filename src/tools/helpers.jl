function access_specified_line(bus_from, bus_to, network_data)
    # Look up the specified line
    for l in keys(network_data["branch"])
        if (
            (network_data["branch"][l]["f_bus"] == bus_from) &
            (network_data["branch"][l]["t_bus"] == bus_to)
        ) | (
            (network_data["branch"][l]["t_bus"] == bus_from) &
            (network_data["branch"][l]["f_bus"] == bus_to)
        )
            return l
        end
    end

    # Raise an error if the specified branch does not exist
    throw(
        ErrorException(
            "A branch does not exist between bus " *
            string(bus_from) *
            " and bus " *
            string(bus_to) *
            ". Please try again or create a new branch.",
        ),
    )
end

function access_specified_load(bus, network_data)
    # Look up the specified load
    for d in keys(network_data["load"])
        if network_data["load"][d]["load_bus"] == bus
            return d
        end
    end

    # Raise an error if the specified branch does not exist
    throw(
        ErrorException(
            "A load does not exist at bus " *
            string(bus) *
            ". Please try again or create a new bus.",
        ),
    )
end

function access_specified_generator(bus, network_data)
    # Look up the specified generator
    for g in keys(network_data["gen"])
        if network_data["gen"][g]["gen_bus"] == bus
            return g
        end
    end

    # Raise an error if the specified branch does not exist
    throw(
        ErrorException(
            "A generator does not exist at bus " *
            string(bus) *
            ". Please try again or create a new generator.",
        ),
    )
end
