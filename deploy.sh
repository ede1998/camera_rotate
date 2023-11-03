#!/bin/bash

set -o errexit;
set -o nounset;
set -o xtrace

cd "$(dirname $0)"

rm -r target || true
mkdir target

cp -r shell.json load_kernel.bash dtbo/pl.dtbo vitis/{camera_rotate/Hardware/camera_rotate,camera_rotate_system_hw_link/Hardware/binary_container_1.xclbin} jupyter_zynq/ target/

scp -r -A -J erik@$REVERSE_SSH_IP target/ ubuntu@192.168.140.252:/home/ubuntu/projects/camera_rotate-$(date +"%Y-%m-%dT%H-%M-%S")
