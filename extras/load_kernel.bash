#!/bin/bash

set -o errexit;
set -o nounset;
set -o xtrace

cd "$(dirname $0)"

PROJ_NAME=$(dirname $(realpath "$0") | sed 's/-[0-9T-]*$//' | sed 's:^.*/::')

if [[ -z "$PROJ_NAME" ]]; then
  exit 1;
fi

sudo rm -r "/usr/lib/firmware/xilinx/$PROJ_NAME" || true
sudo mkdir "/usr/lib/firmware/xilinx/$PROJ_NAME"
sudo cp pl.dtbo shell.json "/usr/lib/firmware/xilinx/$PROJ_NAME"
sudo cp binary_container_1.xclbin "/usr/lib/firmware/xilinx/$PROJ_NAME/binary_container_1.bin"
