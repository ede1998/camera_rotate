```bash
source setup.sh
pushd hls
vitis_hls run_hls.tcl 
popd

pushd dtbo/
./create_dtbo.sh
popd

./deploy.sh
```
