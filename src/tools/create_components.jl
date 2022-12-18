function create_bus!(
    network_data::Dict{String,Any};
    bus_type::String,
    vm::Float64,
    va::Float64,
    base_kv::Float64,
    vmin::Float64,
    vmax::Float64,
    zone::Int64=1,
    area::Int64=1,
)
    # Check the input bus type
    if !(lowercase(bus_type) in ("slack", "pv", "pq"))
        throw(ErrorException(bus_type * " is not a valid bus type. Please try again."))
    end

    # Assuming the voltage angle is provided in degrees, convert to radians
    va = va * π / 180

    # Check that vmin is not greater than vmax
    if vmin > vmax
        throw(
            ErrorException(
                "The minimum voltage magnitude should not exceed the maximum voltage " *
                "magnitude. Please try again",
            ),
        )
    end

    # Add the new bus to the network data
    new_bus_num = length(network_data["bus"]) + 1
    network_data["bus"][string(new_bus_num)] = Dict{String,Any}(
        "zone" => zone,
        "bus_i" => new_bus_num,
        "bus_type" =>
            lowercase(bus_type) == "slack" ? 3 : (lowercase(bus_type) == "pv" ? 2 : 1),
        "vmax" => vmax,
        "source_id" => ["bus", new_bus_num],
        "area" => area,
        "vmin" => vmin,
        "index" => new_bus_num,
        "va" => va,
        "vm" => vm,
        "base_kv" => base_kv,
    )
end

function create_load!(
    network_data::Dict{String,Any};
    bus::Int,
    pd::Float64,
    qd::Float64,
    status::Int64=1,
)
    # Check if the specified bus exists
    check_bus_existence(bus, network_data)

    # Check if the specified bus already has a load
    for d in keys(network_data["load"])
        if network_data["load"][d]["load_bus"] == bus
            throw(
                ErrorException(
                    "Bus " * string(bus) * " already has a load defined. Please try again.",
                ),
            )
        end
    end

    # Check that the status is a valid value
    if !(status in (0, 1))
        throw(ErrorException("The provided status value is invalid. Please try again."))
    end

    # Assuming that pd and qd are provided in MW and MVAR, respectively, convert to per-unit
    pd = pd / network_data["baseMVA"]
    qd = qd / network_data["baseMVA"]

    # Add the new load to the network data
    new_load_num = length(network_data["load"]) + 1
    network_data["load"][string(new_load_num)] = Dict{String,Any}(
        "source_id" => ["bus", bus],
        "load_bus" => bus,
        "status" => status,
        "qd" => qd,
        "pd" => pd,
        "index" => new_load_num,
    )
end

function create_generator!(
    network_data::Dict{String,Any};
    bus::Int,
    vg::Float64,
    pg::Float64,
    qg::Float64,
    mbase::Union{Float64,Nothing}=nothing,
    pmin::Float64,
    pmax::Float64,
    qmin::Float64,
    qmax::Float64,
    pc1::Float64=0.0,
    pc2::Float64=0.0,
    qc1min::Float64=0.0,
    qc1max::Float64=0.0,
    qc2min::Float64=0.0,
    qc2max::Float64=0.0,
    gen_status::Int64=1,
    ramp_agc::Float64=0.0,
    ramp_10::Float64=0.0,
    ramp_30::Float64=0.0,
    ramp_q::Float64=0.0,
    apf::Float64=0.0,
    cost_model::Int64=2,
    startup_cost::Float64=0.0,
    shutdown_cost::Float64=0.0,
    num_cost_points::Int64=3,
    cost::Vector{Float64}=[0.0, 0.0, 0.0],
)
    # Check if the specified bus exists
    check_bus_existence(bus, network_data)

    # Check if the specified bus already has a generator
    for g in keys(network_data["gen"])
        if network_data["gen"][g]["gen_bus"] == bus
            throw(
                ErrorException(
                    "Bus " *
                    string(bus) *
                    " already has a generator defined. Please try again.",
                ),
            )
        end
    end

    # Check that the generator status is a valid value
    if !(gen_status in (0, 1))
        throw(
            ErrorException(
                "The provided generator status value is invalid. Please try again.",
            ),
        )
    end

    # Check that the generator voltage equals that of the specified bus
    if vg != network_data["bus"][string(bus)]["vm"]
        throw(
            ErrorException(
                "The generator's voltage does not match the voltage at Bus " *
                string(bus) *
                ". Please try again.",
            ),
        )
    end

    # If the base MVA value is nothing, set it to the system's base MVA value
    if isnothing(mbase)
        mbase = network_data["baseMVA"]
    end

    # Assuming that real and reactive powers are provided in MW and MVAR, respectively, 
    # convert to per-unit
    pg = pg / mbase
    qg = qg / mbase
    pmin = pmin / mbase
    pmax = pmax / mbase
    qmin = qmin / mbase
    qmax = qmax / mbase
    pc1 = pc1 / mbase
    pc2 = pc2 / mbase
    qc1min = qc1min / mbase
    qc1max = qc1max / mbase
    qc2min = qc2min / mbase
    qc2max = qc2max / mbase

    # Check that pmin is not greater than pmax
    if pmin > pmax
        throw(
            ErrorException(
                "The minimum real power output should not exceed the maximum real power " *
                "output. Please try again",
            ),
        )
    end

    # Check that qmin is not greater than qmax
    if qmin > qmax
        throw(
            ErrorException(
                "The minimum reactive power output should not exceed the maximum " *
                "reactive power output. Please try again",
            ),
        )
    end

    # Check that qc1min is not greater than qc1max
    if qc1min > qc1max
        throw(
            ErrorException(
                "The minimum reactive power output at the lower real power output of " *
                "the PQ capability curve (Pc1) should not exceed the maximum reactive " *
                "power output at Pc1. Please try again",
            ),
        )
    end

    # Check that qc2min is not greater than qc2max
    if qc2min > qc2max
        throw(
            ErrorException(
                "The minimum reactive power output at the upper real power output of " *
                "the PQ capability curve (Pc2) should not exceed the maximum reactive " *
                "power output at Pc2. Please try again",
            ),
        )
    end

    # Check that the cost vector has the specified number of values
    if length(cost) != num_cost_points
        throw(
            ErrorException(
                "The provided number of cost values does not match the specified " *
                "number. Please try again.",
            ),
        )
    end

    # Check that the specified cost model is valid
    if !(cost_model in (1, 2))
        throw(ErrorException("The specified cost model is invalid. Please try again."))
    end

    # Add the new generator to the network data
    new_gen_num = length(network_data["gen"]) + 1
    network_data["gen"][string(new_load_num)] = Dict{String,Any}(
        "ncost" => num_cost_points,
        "qc1max" => qc1max,
        "pg" => pg,
        "model" => cost_model,
        "shutdown" => shutdown_cost,
        "startup" => startup_cost,
        "qc2max" => qc2max,
        "ramp_agc" => ramp_agc,
        "qg" => qg,
        "gen_bus" => bus,
        "pmax" => pmax,
        "ramp_10" => ramp_10,
        "vg" => vg,
        "mbase" => mbase,
        "source_id" => ["gen", new_gen_num],
        "pc2" => pc2,
        "index" => new_gen_num,
        "cost" => cost == zeros(num_cost_points) ? Vector{Float64}() : cost,
        "qmax" => qmax,
        "gen_status" => gen_status,
        "qmin" => qmin,
        "qc1min" => qc1min,
        "qc2min" => qc2min,
        "pc1" => pc1,
        "ramp_q" => ramp_q,
        "ramp_30" => ramp_30,
        "pmin" => pmin,
        "apf" => apf,
    )
end

function create_line!(
    network_data::Dict{String,Any};
    bus_from::Int64,
    bus_to::Int64,
    r::Float64,
    x::Float64,
    b::Float64,
    g::Float64=0.0,
    line_status::Int64=1,
    angmin::Float64=-60.0,
    angmax::Float64=60.0,
    transformer_enabled::Bool=false,
    transformer_tap_ratio::Float64=1.0,
    transformer_phase_shift::Float64=0.0,
)
    # Check that the specified buses exist
    for bus in (bus_from, bus_to)
        check_bus_existence(bus, network_data)
    end

    # Check if the specified line already exists
    for l in keys(network_data["branch"])
        if (
            (network_data["branch"][l]["f_bus"] == bus_from) &
            (network_data["branch"][l]["t_bus"] == bus_to)
        ) | (
            (network_data["branch"][l]["t_bus"] == bus_from) &
            (network_data["branch"][l]["f_bus"] == bus_to)
        )
            throw(
                ErrorException(
                    "There is already a line between Bus " *
                    string(bus_from) *
                    " and Bus " *
                    string(bus_to) *
                    ". Please try again.",
                ),
            )
        end
    end

    # Check that the line status is a valid value
    if !(line_status in (0, 1))
        throw(
            ErrorException("The provided line status value is invalid. Please try again."),
        )
    end

    # Check that angmin and angmax do not exceed the bounds imposed by PowerModels.jl
    if angmin < -60
        @warn(
            "PowerModels.jl only supports minimum angle differences no smaller than -60 " *
            "degrees. Resetting the minimum angle difference to -60 degrees."
        )
        angmin = -60
    end
    if angmax > 60
        @warn(
            "PowerModels.jl only supports maximum angle differences no larger than 60 " *
            "degrees. Resetting the maximum angle difference to 60 degrees."
        )
        angmax = 60
    end

    # Check that angmin is not greater than angmax
    if angmin > angmax
        throw(
            ErrorException(
                "The minimum angle difference should not exceed the maximum " *
                "angle difference. Please try again",
            ),
        )
    end

    # Assuming that angles are provided in degrees, convert to radians
    angmin = angmin * π / 180
    angmax = angmax * π / 180
    transformer_phase_shift = transformer_phase_shift * π / 180

    # Add the new line to the network data
    new_line_num = length(network_data["branch"]) + 1
    network_data["branch"][string(new_line_num)] = Dict{String,Any}(
        "br_r" => r,
        "shift" => transformer_phase_shift,
        "br_x" => x,
        "g_to" => g / 2,
        "g_fr" => g / 2,
        "source_id" => ["branch", new_line_num],
        "b_fr" => b / 2,
        "f_bus" => bus_from,
        "br_status" => line_status,
        "t_bus" => bus_to,
        "b_to" => b / 2,
        "index" => new_line_num,
        "angmin" => angmin,
        "angmax" => angmax,
        "transformer" => transformer_enabled,
        "tap" => transformer_tap_ratio,
    )
end
