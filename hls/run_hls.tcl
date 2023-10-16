# Run project
# F.Kesel, 12.12.22

# Setup project
open_project -reset camera_rotate_proj
#
set_top krnl_vadd
add_files src/krnl_vadd.cpp
add_files -tb src/testbench.cpp

# Use Vitis flow (generate .xo-files)
open_solution -flow_target vitis -reset "solution1"
# Use Ultrascale Zynq (Kria KV260)
set_part {xck26-sfvc784-2LV-c}
# Set clock period (ns)
create_clock -period 10 -name default

# Config interface: No 64 Bit addresses,
# use 32 Bit addresses (otherwise Pynq will not work)
config_interface -m_axi_addr64=0

# Design steps:
csim_design
csynth_design
cosim_design -trace_level port -rtl vhdl
export_design -rtl vhdl -format xo -description "vadd IP Core" -vendor "hspf" -version "1.0" -display_name "vadd"
exit
