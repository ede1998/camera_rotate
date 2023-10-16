#!/bin/bash
echo "Create device tree dtbo"

#Define path to Vitis installation
vitis_path=/opt/Xilinx/Vitis/current/

source ${vitis_path}settings64.sh
xsct dts.tcl
dtc -@ -O dtb -o pl.dtbo devicetree/devicetree/kv260_platform/psu_cortexa53_0/device_tree_domain/bsp/pl.dtsi
