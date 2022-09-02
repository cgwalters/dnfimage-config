#!/bin/bash
set -xeuo pipefail
src=$PWD
cd /srv
mkdir dnfimage
cd dnfimage
cosa init --transient $src
cosa fetch
cosa build ostree
