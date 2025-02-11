#!/usr/bin/env bash
# branch="${PYTORCH_BRANCH:-tags/v2.6.0}"
# echo "$(pwd)"
# git clone https://github.com/pytorch/pytorch
cd pytorch/
# git checkout $branch
python3.12 -m venv .venv
source .venv/bin/activate
export PYTORCH_ROCM_ARCH=gfx908
export GPU_ARCHS=gfx908
export USE_CUDA=0
export CFLAGS="-Wno-error=maybe-uninitialized"
export USE_MKLDNN=0
git submodule sync
git submodule update --init --recursive
python -m pip install cmake ninja
python -m pip install --pre torch torchaudio torchvision --index-url https://download.pytorch.org/whl/nightly/rocm6.3
python -m pip install mkl-static mkl-include
make triton
python tools/amd_build/build_amd.py
# python setup.py develop
python setup.py bdist_wheel