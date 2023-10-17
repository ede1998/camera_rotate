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
