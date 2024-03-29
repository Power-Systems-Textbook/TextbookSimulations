"""
    organize_bus_results(
        result::Dict{String,Any},
        network_data::Dict{String,Any};
        save_data::Bool=false,
        file_path::Union{String,Nothing}=nothing,
    )::DataFrames.DataFrame

Organizes the bus-level results from the power-flow solution to present relevant voltage 
and power information. Users can indicate if they would like to save this data to a .csv 
file.
"""
function organize_bus_results(
    result::Dict{String,Any},
    network_data::Dict{String,Any};
    save_data::Bool=false,
    file_path::Union{String,Nothing}=nothing,
)::DataFrames.DataFrame
    # Find the real and reactive power demand at each bus
    pd_by_bus = zeros(length(network_data["bus"]))
    qd_by_bus = zeros(length(network_data["bus"]))
    for l in keys(network_data["load"])
        pd_by_bus[network_data["load"][l]["load_bus"]] = network_data["load"][l]["pd"]
        qd_by_bus[network_data["load"][l]["load_bus"]] = network_data["load"][l]["qd"]
    end

    # Find the real and reactive power generated at each bus
    pg_by_bus = zeros(length(network_data["bus"]))
    qg_by_bus = zeros(length(network_data["bus"]))
    for g in keys(network_data["gen"])
        pg_by_bus[network_data["gen"][g]["gen_bus"]] = result["solution"]["gen"][g]["pg"]
        qg_by_bus[network_data["gen"][g]["gen_bus"]] = result["solution"]["gen"][g]["qg"]
    end

    # Create DataFrame of the relevant bus-related solutions
    bus_data = DataFrame(
        "Bus Number" => 1:length(network_data["bus"]),
        "Bus Type" => [
            network_data["bus"][string(i)]["bus_type"] == 3 ? "Slack" :
            (network_data["bus"][string(i)]["bus_type"] == 2 ? "PV" : "PQ") for
            i = 1:length(network_data["bus"])
        ],
        "Voltage Magnitude (p.u.)" => [
            result["solution"]["bus"][string(i)]["vm"] for
            i = 1:length(network_data["bus"])
        ],
        "Voltage Angle (degrees)" =>
            [
                result["solution"]["bus"][string(i)]["va"] for
                i = 1:length(network_data["bus"])
            ] .* 180 ./ π,
        "Real Power Generated (MW)" => pg_by_bus .* network_data["baseMVA"],
        "Reactive Power Generated (MVAR)" => qg_by_bus .* network_data["baseMVA"],
        "Real Power Load (MW)" => pd_by_bus .* network_data["baseMVA"],
        "Reactive Power Load (MVAR)" => qd_by_bus .* network_data["baseMVA"],
    )

    # If specified, save the bus-level results
    if save_data
        if isnothing(file_path)
            throw(
                ErrorException(
                    "A file path is not provided. Please provide a file path if you want " *
                    "the bus-level results to be saved.",
                ),
            )
        else
            CSV.write(joinpath(file_path, "bus_results.csv"), bus_data)
        end
    end

    # Return the DataFrame
    return bus_data
end

"""
    organize_line_results(
        result::Dict{String,Any},
        network_data::Dict{String,Any};
        save_data::Bool=false,
        file_path::Union{String,Nothing}=nothing,
    )::DataFrames.DataFrame

Organizes the line-level results from the power-flow solution to present relevant line flow 
information. Users can indicate if they would like to save this data to a .csv file.
"""
function organize_line_results(
    result::Dict{String,Any},
    network_data::Dict{String,Any};
    save_data::Bool=false,
    file_path::Union{String,Nothing}=nothing,
)::DataFrames.DataFrame
    # Create DataFrame of the relevant line-related solutions
    line_data = DataFrame(
        "Bus i" => [
            network_data["branch"][string(i)]["f_bus"] for
            i = 1:length(network_data["branch"])
        ],
        "Bus j" => [
            network_data["branch"][string(i)]["t_bus"] for
            i = 1:length(network_data["branch"])
        ],
        "Real Power Flow from Bus i to Bus j (MW)" =>
            [
                result["solution"]["line_flows"]["branch"][string(i)]["pf"] for
                i = 1:length(network_data["branch"])
            ] .* network_data["baseMVA"],
        "Real Power Flow from Bus j to Bus i (MW)" =>
            [
                result["solution"]["line_flows"]["branch"][string(i)]["pt"] for
                i = 1:length(network_data["branch"])
            ] .* network_data["baseMVA"],
        "Real Power Flow Losses (MW)" =>
            [
                result["solution"]["line_flows"]["branch"][string(i)]["pf"] +
                result["solution"]["line_flows"]["branch"][string(i)]["pt"] for
                i = 1:length(network_data["branch"])
            ] .* network_data["baseMVA"],
        "Reactive Power Flow from Bus i to Bus j (MVAR)" =>
            [
                result["solution"]["line_flows"]["branch"][string(i)]["qf"] for
                i = 1:length(network_data["branch"])
            ] .* network_data["baseMVA"],
        "Reactive Power Flow from Bus j to Bus i (MVAR)" =>
            [
                result["solution"]["line_flows"]["branch"][string(i)]["qt"] for
                i = 1:length(network_data["branch"])
            ] .* network_data["baseMVA"],
        "Reactive Power Flow Losses (MVAR)" =>
            [
                result["solution"]["line_flows"]["branch"][string(i)]["qf"] +
                result["solution"]["line_flows"]["branch"][string(i)]["qt"] for
                i = 1:length(network_data["branch"])
            ] .* network_data["baseMVA"],
    )

    # If specified, save the line-level results
    if save_data
        if isnothing(file_path)
            throw(
                ErrorException(
                    "A file path is not provided. Please provide a file path if you want " *
                    "the line-level results to be saved.",
                ),
            )
        else
            CSV.write(joinpath(file_path, "line_results.csv"), line_data)
        end
    end

    # Return the DataFrame
    return line_data
end

"""
    save_network_data(
        network_data::Dict{String,Any},
        file_path::String,
        case_name::String,
        file_type::String,
        overwrite_file::Bool=false,
    )

Creates a wrapper around functionality from PowerModels.jl to allow the network data Dict 
to be saved to a .m or a .json file. Checks to see if a file with the same name already 
exists, and gives users the ability to specify whether or not they would like preexisting 
files to be overwritten.
"""
function save_network_data(
    network_data::Dict{String,Any},
    file_path::String,
    case_name::String,
    file_type::String,
    overwrite_file::Bool=false,
)
    # Check that an appropriate file type has been provided
    if !(file_type in (".m", ".json"))
        throw(
            ErrorException(file_type * " is not an accepted file type. Please try again."),
        )
    end

    # Check if a file of the same name already exists in the provided file path
    if isfile(joinpath(file_path, case_name * file_type))
        # Overwrite the existing file if allowed by the user; otherwise, throw an error
        if overwrite_file
            # Update the case name in the network data
            network_data["name"] = case_name

            # Save the network data as the specified file type in the specified file path
            PowerModels.export_file(
                joinpath(file_path, case_name * file_type),
                network_data,
            )
        else
            throw(
                ErrorException(
                    "A file with the same case name already exists in the specified file " *
                    "path. Please allow the file to be overwritten or choose a new case " *
                    "name.",
                ),
            )
        end
    else
        # Update the case name in the network data
        network_data["name"] = case_name

        # Save the network data as the specified file type in the specified file path
        PowerModels.export_file(joinpath(file_path, case_name * file_type), network_data)
    end
end
