"""
    load_network_data(
        file_path::String,
        case_name::String,
        file_type::String,
    )::Dict{String,Any}

Creates a wrapper around functionality from PowerModels.jl to read in .m and .json files 
that are in the MATPOWER case style.
"""
function load_network_data(
    file_path::String,
    case_name::String,
    file_type::String,
)::Dict{String,Any}
    # Check that an appropriate file type has been provided
    if !(file_type in (".m", ".json"))
        throw(
            ErrorException(file_type * " is not an accepted file type. Please try again."),
        )
    end

    # Return the network data from the user-specified .m file
    return PowerModels.parse_file(joinpath(file_path, case_name * file_type))
end

"""
    create_blank_network(
        case_name::String,
        base_mva::Int64,
        per_unit::Bool=true,
        mpc_version::Int64=2,
    )::Dict{String,Any}

Creates a blank network data Dict that allows users specify buses, lines, loads, and 
generators independent of a .m or .json file that is in the MATPOWER case style. Users 
provide a case name and a base power for the system (in MVA). Users can also indicate 
whether the system is in per-unit; per-unit is defaulted to being enabled. Finally, users 
can specify the MATPOWER case (MPC) version if they desire; since this is not something 
with which users need to concern themselves, this parameter is defaulted to MPC version 2.
"""
function create_blank_network(
    case_name::String,
    base_mva::Int64,
    per_unit::Bool=true,
    mpc_version::Int64=2,
)::Dict{String,Any}
    # Check that an appropriate matpower case (mpc) version has been provided
    if !(mpc_version in (1, 2))
        throw(
            ErrorException(
                string(mpc_version) *
                " is not an accepted MATPOWER case version. Please try again.",
            ),
        )
    end

    # Create Dict with the necessary keys for a network data representation
    network_data = Dict{String,Any}(
        "bus" => Dict{String,Any}(),
        "source_type" => "matpower",
        "name" => case_name,
        "dcline" => Dict{String,Any}(),
        "source_version" => mpc_version,
        "gen" => Dict{String,Any}(),
        "branch" => Dict{String,Any}(),
        "storage" => Dict{String,Any}(),
        "switch" => Dict{String,Any}(),
        "baseMVA" => base_mva,
        "per_unit" => per_unit,
        "shunt" => Dict{String,Any}(),
        "load" => Dict{String,Any}(),
    )

    # Return the blank network data representation
    return network_data
end
