#!/usr/bin/env bash

OUTPUT_ROOT_PATH="$(pwd)"
PATCH_FOLDER="patches"
PATCH_OUTPUT_PATH="${OUTPUT_ROOT_PATH}/${PATCH_FOLDER}"

if [ -z "${ROCM_ROOT_PATH}" ]; then
    echo "ROCM_ROOT_PATH environment variable must be set".
    exit 1
fi

mkdir -p ${PATCH_OUTPUT_PATH}


cd ${ROCM_ROOT_PATH}
for file in $(ls ${ROCM_ROOT_PATH}); do
    if [ -d $file ]; then
        echo $file
        patch_path="${PATCH_OUTPUT_PATH}/${file}"
        
        cd $file
        if [ -d ./.git ]; then
            patch=$(git diff 2> /dev/null)
            if [ -n "$patch" ]; then
                mkdir -p $patch_path
                echo "$patch" > "${patch_path}/${file}.patch"
            fi
        fi
        cd ..
    fi
done