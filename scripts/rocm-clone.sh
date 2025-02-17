#!/usr/bin/env bash

ROCM_DIR="./third_party/ROCm_long_pathname_so_that_rpms_can_package_the_debug_info"
source .env.local
# if [ ! -d $ROCM_DIR ]; then
mkdir -p $ROCM_DIR
# fi
cd $ROCM_DIR
echo `pwd`
~/bin/repo init -u http://github.com/ROCm/ROCm.git -b develop -m tools/rocm-build/rocm-${ROCM_VERSION}.xml
~/bin/repo sync