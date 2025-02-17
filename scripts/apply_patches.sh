#!/usr/bin/env bash
OUTPUT_ROOT_PATH="$(pwd)"
PATCH_FOLDER="patches"
PATCH_OUTPUT_PATH="${OUTPUT_ROOT_PATH}/${PATCH_FOLDER}"

if [ -z "${ROCM_ROOT_PATH}" ]; then
    echo "ROCM_ROOT_PATH environment variable must be set".
    exit 1
fi

mkdir -p ${PATCH_OUTPUT_PATH}

for patch in $@; do
    patch_file="${PATCH_OUTPUT_PATH}/${patch}/${patch}.patch"
    if [ -n "$patch_file" ]; then
        source_path="${ROCM_ROOT_PATH}/${patch}"
        echo "Applying $patch_file to $source_path..."
        cd $source_path
        git apply $patch_file
        cd ${OUTPUT_ROOT_PATH}
    fi
done