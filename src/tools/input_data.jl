function load_network_data(
    filepath::String,
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
    return PowerModels.parse_file(joinpath(filepath, case_name * file_type))
end

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
