#!/usr/bin/env bash

if [ ! -d "${ROCM_ROOT_PATH}" ]; then
    echo "ROCM_ROOT_PATH environment variable must be set and directory must exist".
    exit 1
fi

if [ ! -d "${LOCAL_RPM_REPO_PATH}" ]; then
    echo "LOCAL_RPM_REPO_PATH environment variable must be set and directory must exist".
    exit 1
fi

if [ -z "${ROCM_VERSION}" ]; then
    echo "ROCM_VERSION environment variable must be set".
    exit 1
fi

rpm_output_directory="${ROCM_ROOT_PATH}/out/${DISTRO_ID}/${DISTRO_RELEASE}/rpm"

if [ ! -d "${rpm_output_directory}" ]; then
    echo "RPM output directory does not exist. ${rpm_output_directory}"
    exit 1
fi

rpm_repo_folder="${LOCAL_RPM_REPO_PATH}/x86_64"
mkdir -p $rpm_repo_folder

# ls "${rpm_output_directory}/*/**.rpm"
rpms=$(find ${rpm_output_directory} -type f -name "*.rpm")
for rpm in $rpms; do
    # echo $rpm
    rpm_filename=$(basename $rpm)
    cp -f $rpm $rpm_repo_folder/$rpm_filename
done

if [ -d "${LOCAL_RPM_REPO_PATH}/repodata" ]; then
    createrepo --update $LOCAL_RPM_REPO_PATH
else
    createrepo $LOCAL_RPM_REPO_PATH
fi