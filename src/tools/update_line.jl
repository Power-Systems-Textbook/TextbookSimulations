function change_line_resistance!(
    new_r::Union{Float64,Int64},
    bus_from::Int64,
    bus_to::Int64,
    network_data::Dict{String,Any},
)
    # Check that the specified buses exist
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
                ". Please try again or create a new branch.",
            ),
        )
    end

    # Update the branch resistance
    network_data["branch"][string(l)]["br_r"] = float(new_r)
end

function change_line_reactance!(
    new_x::Union{Float64,Int64},
    bus_from::Int64,
    bus_to::Int64,
    network_data::Dict{String,Any},
)
    # Check that the specified buses exist
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
                ". Please try again or create a new branch.",
            ),
        )
    end

    # Update the branch reactance
    network_data["branch"][string(l)]["br_x"] = float(new_x)
end

function change_line_susceptance!(
    new_b::Union{Float64,Int64},
    bus_from::Int64,
    bus_to::Int64,
    network_data::Dict{String,Any},
)
    # Check that the specified buses exist
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
                ". Please try again or create a new branch.",
            ),
        )
    end

    # Update the branch resistance
    network_data["branch"][string(l)]["b_fr"] = new_b / 2
    network_data["branch"][string(l)]["b_to"] = new_b / 2
end
