# Camera rotate

## Setup

```bash
source setup.sh

pushd hls
vitis_hls run_hls.tcl 
vitis_hls -p camera_rotate_proj/
vitis_hls run_hls.tcl
popd

vitis vitis/
# build stuff

pushd dtbo/
./create_dtbo.sh
popd

./deploy.sh
```

## Actions

Potentially useful:

[remap](https://xilinx.github.io/Vitis_Libraries/vision/2022.1/api-reference.html#remap) relocates pixels in an image. Could maybe suport 4k30fps
[rotate](https://xilinx.github.io/Vitis_Libraries/vision/2022.1/api-reference.html#rotate) only for multiples of 90 degree.

## Trouble
- bad documentation: headers not well documented for vision library
- assumption: vision library already installed on system
- bad error messages: input pixel width must be power of 2 -> weird runtime errors
