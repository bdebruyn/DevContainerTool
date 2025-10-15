#!/bin/bash

bootloader=imx-boot-imx8mq-var-dart-sd.bin-flash_evk
imgdir=/home/ubuntu/Projects/git/var-fslc-dunfell/build_x11wayland/tmp/deploy/images/imx8mq-var-dart
img=$(sshpass -p abcd123 ssh ubuntu@192.168.10.100 ls $imgdir | grep -E "^fsl-image-gui-imx8mq-var-dart-[[:digit:]]{14}.rootfs.wic.gz$")
echo $img
sshpass -p abcd123 scp ubuntu@192.168.10.100:$imgdir/$img .
if [ $? -eq 0 ]
then
    echo "Download successful"
else
    echo "Error downloading image"
    exit 1
fi
echo "Decompressing image..."
uncompressed=${img%.gz}
gunzip -k $img 
echo "done"
#sudo uuu -b emmc_all $bootloader $uncompressed

