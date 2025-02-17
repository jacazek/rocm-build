#!/usr/bin/env bash
OUTPUT_ROOT_PATH="$(pwd)"
PATCH_FOLDER="patches"
PATCH_OUTPUT_PATH="${OUTPUT_ROOT_PATH}/${PATCH_FOLDER}"

if [ -z "${ROCM_ROOT_PATH}" ]; then
    echo "ROCM_ROOT_PATH environment variable must be set".
    exit 1
fi

for patch_folder in $(ls -d ${PATCH_OUTPUT_PATH}/*); do
    patch_name=`basename $patch_folder`
    patch_file="${patch_folder}/${patch_name}.patch"
    if [ -n "$patch_file" ]; then
        source_path="${ROCM_ROOT_PATH}/${patch_name}"
        echo "Applying $patch_file to $source_path..."
        cd $source_path
        git apply $patch_file
        cd ${OUTPUT_ROOT_PATH}
    fi
done