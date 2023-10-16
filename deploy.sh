#!/bin/bash

set -o errexit;
set -o nounset;
set -o xtrace

cd "$(dirname $0)"

rm -r target || true
mkdir target
cp -r dtbo/pl.dtbo vitis/{camera_rotate/Hardware/camera_rotate,camera_rotate_system_hw_link/Hardware/binary_container_1.xclbin} jupyter_zynq/ target/
cat > target/shell.json << EOF
{
"shell_type" : "XRT_FLAT",
"num_slots": "1"
}
EOF


