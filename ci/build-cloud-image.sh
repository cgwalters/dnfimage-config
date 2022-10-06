#!/bin/bash
set -euo pipefail

cosa build

arch=$(arch)
buildid=$(readlink builds/latest)
bd="builds/${buildid}/${arch}"
target=$bd/dnfimage-openstack-$buildid.qcow2
qemu=$(ls $bd/*qemu*.qcow2)
set -x
rm -f tmp/image*.qcow2 tmp/image.tar*
cp --reflink=auto "${qemu}" tmp/image.qcow2
# Forcibly override the platform to metal, to prevent Ignition from running
/usr/lib/coreos-assembler/gf-set-platform tmp/image.qcow2 tmp/image-platform.qcow2 metal
mv tmp/image-platform.qcow2 $target
zstd $target
rm -f tmp/image*.qcow2 
echo "Generated: $target.zst"

