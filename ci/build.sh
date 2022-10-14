#!/bin/bash
set -xeuo pipefail
target=$1
shift
src=$PWD
cd /srv
mkdir dnfimage
cd dnfimage
cosa init --transient $src
cosa fetch
cosa build --prepare-only
exec rpm-ostree compose image --format=registry --layer-repo tmp/repo src/config/manifest.yaml "${target}"

