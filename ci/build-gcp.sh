#!/bin/bash
set -euo pipefail

cd /srv/dnfimage
cosa build

arch=$(arch)
buildid=$(readlink builds/latest)
bd="builds/${buildid}/${arch}"
target=$bd/gcp-image-$buildid.tar.gz
qemu=$(ls $bd/*qemu*.qcow2)
set -x
rm -f tmp/image*.qcow2 tmp/image.tar*
cp --reflink=auto "${qemu}" tmp/image.qcow2
# Forcibly override the platform to metal, to prevent Ignition from running
/usr/lib/coreos-assembler/gf-set-platform tmp/image.qcow2 tmp/image-platform.qcow2 metal
qemu-img 'convert' '-f' 'qcow2' '-O' 'raw' tmp/image-platform.qcow2 '-o' 'preallocation=off' tmp/disk.raw
tar '--owner=0' '--group=0' '-C' tmp '-Sch' '--format=oldgnu' '-f' tmp/image.tar disk.raw
rm -f tmp/image*.qcow2 tmp/disk.raw
gzip tmp/image.tar
mv tmp/image.tar.gz $target
echo "Generated: $target"

