module TextbookSimulations

using DataFrames
using PowerModels

# Include the following functionality
include("tools/helpers.jl")
include("tools/powermodels_wrappers.jl")
include("tools/update_line.jl")
include("tools/update_bus.jl")
include("tools/create_components.jl")
include("tools/delete_components.jl")
include("tools/organize_results.jl")

# Export functionality from powermodels_wrappers.jl
export load_network_data
export compute_ac_pf

# Export functionality from helpers.jl
export check_if_bus_is_stranded

# Export functionality from update_line.jl
export change_line_resistance!
export change_line_reactance!
export change_line_susceptance!

# Export functionality from update_bus.jl
export change_bus_real_power_demand!
export change_bus_reactive_power_demand!
export change_bus_real_power_generation!
export change_bus_voltage_magnitude!
export change_bus_voltage_angle!

# Export functionality from create_components.jl
export create_bus!
export create_load!
export create_generator!
export create_line!

# Export functionality from delete_components.jl
export delete_bus!
export delete_load!
export delete_generator!
export delete_line!

# Export functionality from organize_results.jl
export organize_bus_results
export organize_line_results

end
