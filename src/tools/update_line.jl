function change_line_resistance!(new_r, bus_from, bus_to, network_data)
    # Determine the user-specified line
    l = access_specified_line(bus_from, bus_to, network_data)

    # Update the branch resistance
    network_data["branch"][l]["br_r"] = new_r
end

function change_line_reactance!(new_x, bus_from, bus_to, network_data)
    # Determine the user-specified line
    l = access_specified_line(bus_from, bus_to, network_data)

    # Update the branch reactance
    network_data["branch"][l]["br_x"] = new_x
end

function change_line_susceptance!(new_b, bus_from, bus_to, network_data)
    # Determine the user-specified line
    l = access_specified_line(bus_from, bus_to, network_data)

    # Update the branch resistance
    network_data["branch"][l]["b_fr"] = new_b / 2
    network_data["branch"][l]["b_to"] = new_b / 2
end
