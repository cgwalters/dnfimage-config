#!/bin/bash
# Prepare the build container
set -xeuo pipefail
cp -a coreos-continuous.repo /etc/yum.repos.d
dnf -y upgrade ostree rpm-ostree
