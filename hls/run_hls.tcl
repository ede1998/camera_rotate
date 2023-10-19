# Run project

set VISION_PATH /home/heneri/Dokumente/Vitis_Libraries/vision/L1/include
set OPENCV_PATH /opt/opencv/include/opencv4/
# Set linker flags (for csim and cosim)
set CFLAGS  "-I${VISION_PATH} -I${OPENCV_PATH} -std=c++14"
set LD_FLAGS "-L/opt/opencv/lib -lopencv_core -lopencv_imgproc -lopencv_imgcodecs -lopencv_highgui"

# Setup project
open_project -reset camera_rotate_proj
#
set_top krnl_vadd
add_files src/krnl_vadd.cpp -cflags "${CFLAGS}"
add_files -tb src/testbench.cpp -cflags "${CFLAGS}"

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
csim_design -ldflags "${LD_FLAGS}"
csynth_design
cosim_design -trace_level port -rtl vhdl -ldflags "${LD_FLAGS}"
export_design -rtl vhdl -format xo -description "vadd IP Core" -vendor "hspf" -version "1.0" -display_name "vadd"
exit
