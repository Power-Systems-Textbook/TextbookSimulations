function change_bus_real_power_demand!(
    new_pd::Union{Float64,Int64},
    bus::Int64,
    network_data::Dict{String,Any},
)
    # Check if the specified bus exists
    check_bus_existence(bus, network_data)

    # Determine the user-specified load
    d = access_specified_load(bus, network_data)

    # Raise an error if the specified load does not exist
    if isnothing(d)
        throw(
            ErrorException(
                "A load does not exist at Bus " *
                string(bus) *
                ". Please try again or create a new load.",
            ),
        )
    end

    # Update the real-power demand, in per-unit
    network_data["load"][string(d)]["pd"] = float(new_pd)
end

function change_bus_reactive_power_demand!(
    new_qd::Union{Float64,Int64},
    bus::Int64,
    network_data::Dict{String,Any},
)
    # Check if the specified bus exists
    check_bus_existence(bus, network_data)

    # Determine the user-specified load
    d = access_specified_load(bus, network_data)

    # Raise an error if the specified load does not exist
    if isnothing(d)
        throw(
            ErrorException(
                "A load does not exist at Bus " *
                string(bus) *
                ". Please try again or create a new load.",
            ),
        )
    end

    # Update the reactive-power demand, in per-unit
    network_data["load"][string(d)]["qd"] = float(new_qd)
end

function change_bus_real_power_generation!(
    new_pg::Union{Float64,Int64},
    bus::Int64,
    network_data::Dict{String,Any},
)
    # Check if the specified bus exists
    check_bus_existence(bus, network_data)

    # Determine the user-specified generator
    g = access_specified_generator(bus, network_data)

    # Raise an error if the specified generator does not exist
    if isnothing(g)
        throw(
            ErrorException(
                "A generator does not exist at Bus " *
                string(bus) *
                ". Please try again or create a new generator.",
            ),
        )
    end

    # Update the real-power generation, in per-unit
    network_data["gen"][string(g)]["pg"] = float(new_pg)
end

function change_bus_voltage_magnitude!(
    new_vm::Union{Float64,Int64},
    bus::Int64,
    network_data::Dict{String,Any},
)
    # Check if the specified bus exists
    check_bus_existence(bus, network_data)

    # Check if the bus is a slack bus or a PV bus
    if network_data["bus"][string(bus)]["bus_type"] in (2, 3)
        # Determine the generator id at the user-specified bus
        g = access_specified_generator(bus, network_data)

        # Raise an error if the specified generator does not exist
        if isnothing(g)
            throw(
                ErrorException(
                    "A generator does not exist at Bus " *
                    string(bus) *
                    ". Please try again or create a new generator.",
                ),
            )
        end

        # Update the voltage magnitude of the user-specified bus's generator, in per-unit
        network_data["gen"][string(g)]["vg"] = float(new_vm)
    end

    # Update the voltage magnitude at the user-specified bus, in per-unit
    network_data["bus"][string(bus)]["vm"] = float(new_vm)
end

function change_bus_voltage_angle!(
    new_va::Union{Float64,Int64},
    bus::Int64,
    network_data::Dict{String,Any},
)
    # Check if the specified bus exists
    check_bus_existence(bus, network_data)

    # Assuming the voltage angle is provided in degrees, convert to radians
    new_va = new_va * π / 180

    # Update the voltage angle at the user-specified bus, in radians
    network_data["bus"][string(bus)]["va"] = float(new_va)
end
