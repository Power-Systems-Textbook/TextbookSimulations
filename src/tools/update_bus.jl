function change_bus_real_power_demand!(
    new_pd::Float64,
    bus::Int64,
    network_data::Dict{String,Any},
)
    # Determine the user-specified load
    d = access_specified_load(bus, network_data)

    # Update the real-power demand, in per-unit
    network_data["load"][d]["pd"] = new_pd
end

function change_bus_reactive_power_demand!(
    new_qd::Float64,
    bus::Int64,
    network_data::Dict{String,Any},
)
    # Determine the user-specified load
    d = access_specified_load(bus, network_data)

    # Update the reactive-power demand, in per-unit
    network_data["load"][d]["qd"] = new_qd
end

function change_bus_real_power_generation!(
    new_pg::Float64,
    bus::Int64,
    network_data::Dict{String,Any},
)
    # Determine the user-specified generator
    g = access_specified_generator(bus, network_data)

    # Update the real-power generation, in per-unit
    network_data["gen"][g]["pg"] = new_pg
end

function change_bus_voltage_magnitude!(
    new_vm::Float64,
    bus::Int64,
    network_data::Dict{String,Any},
)
    # Check if the bus is a slack bus or a PV bus
    if network_data["bus"][string(bus)]["bus_type"] in (2, 3)
        # Determine the generator id at the user-specified bus
        g = access_specified_generator(bus, network_data)

        # Update the voltage magnitude of the user-specified bus's generator, in per-unit
        network_data["gen"][g]["vg"] = new_vm
    end

    # Update the voltage magnitude at the user-specified bus, in per-unit
    network_data["bus"][string(bus)]["vm"] = new_vm
end

function change_bus_voltage_angle!(
    new_va::Float64,
    bus::Int64,
    network_data::Dict{String,Any},
)
    # Assuming the voltage angle is provided in degrees, convert to radians
    new_va = new_va * π / 180

    # Update the voltage angle at the user-specified bus, in radians
    network_data["bus"][string(bus)]["va"] = new_va
end
