#!/usr/bin/env bash
HIPCXX="$(hipconfig -l)/clang" HIP_PATH="$(hipconfig -R)" \
    cmake -S . -B build -DGGML_HIP=ON -DAMDGPU_TARGETS="gfx1100;gfx908" -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build --config Release -- -j 64