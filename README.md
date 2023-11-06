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
- bad error messages: too large height/width template parameter -> crashes testbench during co-sim but not c-sim
- opencv -> uses shared lib -> does not find opencv on Kria -> different arch -> no simple copying, opencv is already installed but in version 4.5.4d (program wants 4.5) -> create symlinks
- xmutil fails to load image -> daemon logs say "no accel found" -> manually adding in /lib/firmware/xilinx (and renaming xclbin -> bin) works -> starting program -> stuck at loading xclbin file -> reboot helped?
- rotate makes weird stuff with approx 16:9 image

## Ideas

use smartphone gyro sensor with small http server + website -> report via http the device orientation
stick camera to phone with some rubber band


## SSH

```bash
# one time:
sudo ssh-keygen -A
# every time:
echo $VPN_PASSWORD | sudo openconnect vpnstud.hs-pforzheim.de --user=$VPN_USER --passwd-on-stdin --background
sshd
ssh $VPN_USER@$XILINX_SERVER
# one time:
ssh-copy-id $VPN_USER@$XILINX_SERVER
# and to kria too (~/.ssh/authorized_keys)

# on server:
ssh -A -J $HOST_USER@$(echo $SSH_CLIENT | sed 's/ .*//) ubuntu@$KRIA_LOCAL_IP
```
