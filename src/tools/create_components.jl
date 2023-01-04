function create_bus!(
    network_data::Dict{String,Any};
    bus_type::String,
    vm::Union{Float64,Int64},
    va::Union{Float64,Int64},
    base_kv::Union{Float64,Int64},
    vmin::Union{Float64,Int64},
    vmax::Union{Float64,Int64},
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
        "vmax" => float(vmax),
        "source_id" => ["bus", new_bus_num],
        "area" => area,
        "vmin" => float(vmin),
        "index" => new_bus_num,
        "va" => float(va),
        "vm" => float(vm),
        "base_kv" => float(base_kv),
    )
end

function create_load!(
    network_data::Dict{String,Any};
    bus::Int,
    pd::Union{Float64,Int64},
    qd::Union{Float64,Int64},
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
        "qd" => float(qd),
        "pd" => float(pd),
        "index" => new_load_num,
    )
end

function create_generator!(
    network_data::Dict{String,Any};
    bus::Int,
    vg::Union{Float64,Int64},
    pg::Union{Float64,Int64},
    qg::Union{Float64,Int64},
    mbase::Union{Float64,Int64,Nothing}=nothing,
    pmin::Union{Float64,Int64},
    pmax::Union{Float64,Int64},
    qmin::Union{Float64,Int64},
    qmax::Union{Float64,Int64},
    pc1::Union{Float64,Int64}=0.0,
    pc2::Union{Float64,Int64}=0.0,
    qc1min::Union{Float64,Int64}=0.0,
    qc1max::Union{Float64,Int64}=0.0,
    qc2min::Union{Float64,Int64}=0.0,
    qc2max::Union{Float64,Int64}=0.0,
    gen_status::Int64=1,
    ramp_agc::Union{Float64,Int64}=0.0,
    ramp_10::Union{Float64,Int64}=0.0,
    ramp_30::Union{Float64,Int64}=0.0,
    ramp_q::Union{Float64,Int64}=0.0,
    apf::Union{Float64,Int64}=0.0,
    cost_model::Int64=2,
    startup_cost::Union{Float64,Int64}=0.0,
    shutdown_cost::Union{Float64,Int64}=0.0,
    num_cost_points::Int64=3,
    cost::Union{Vector{Float64},Nothing}=nothing,
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
    if !isnothing(cost)
        if length(cost) != num_cost_points
            throw(
                ErrorException(
                    "The provided number of cost values does not match the specified " *
                    "number. Please try again.",
                ),
            )
        end
    end

    # Check that the specified cost model is valid
    if !(cost_model in (1, 2))
        throw(ErrorException("The specified cost model is invalid. Please try again."))
    end

    # Add the new generator to the network data
    new_gen_num = length(network_data["gen"]) + 1
    network_data["gen"][string(new_gen_num)] = Dict{String,Any}(
        "ncost" => num_cost_points,
        "qc1max" => float(qc1max),
        "pg" => float(pg),
        "model" => cost_model,
        "shutdown" => float(shutdown_cost),
        "startup" => float(startup_cost),
        "qc2max" => float(qc2max),
        "ramp_agc" => float(ramp_agc),
        "qg" => float(qg),
        "gen_bus" => bus,
        "pmax" => float(pmax),
        "ramp_10" => float(ramp_10),
        "vg" => float(vg),
        "mbase" => float(mbase),
        "source_id" => ["gen", new_gen_num],
        "pc2" => float(pc2),
        "index" => new_gen_num,
        "cost" => isnothing(cost) ? Vector{Float64}() : cost,
        "qmax" => float(qmax),
        "gen_status" => gen_status,
        "qmin" => float(qmin),
        "qc1min" => float(qc1min),
        "qc2min" => float(qc2min),
        "pc1" => float(pc1),
        "ramp_q" => float(ramp_q),
        "ramp_30" => float(ramp_30),
        "pmin" => float(pmin),
        "apf" => float(apf),
    )
end

function create_line!(
    network_data::Dict{String,Any};
    bus_from::Int64,
    bus_to::Int64,
    r::Union{Float64,Int64},
    x::Union{Float64,Int64},
    b::Union{Float64,Int64},
    g::Union{Float64,Int64}=0.0,
    line_status::Int64=1,
    angmin::Union{Float64,Int64}=-60.0,
    angmax::Union{Float64,Int64}=60.0,
    transformer_enabled::Bool=false,
    transformer_tap_ratio::Union{Float64,Int64}=1.0,
    transformer_phase_shift::Union{Float64,Int64}=0.0,
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
        "br_r" => float(r),
        "shift" => float(transformer_phase_shift),
        "br_x" => float(x),
        "g_to" => g / 2,
        "g_fr" => g / 2,
        "source_id" => ["branch", new_line_num],
        "b_fr" => b / 2,
        "f_bus" => bus_from,
        "br_status" => line_status,
        "t_bus" => bus_to,
        "b_to" => b / 2,
        "index" => new_line_num,
        "angmin" => float(angmin),
        "angmax" => float(angmax),
        "transformer" => transformer_enabled,
        "tap" => float(transformer_tap_ratio),
    )
end
