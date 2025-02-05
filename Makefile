CONTAINER_LOCAL_REPO=/opt/local_repo
.PHONY: build rebuild build_sandbox apply_patches get_patches rpm_to_repo

opensuse_tumbleweed.sif:
	apptainer pull opensuse_tumbleweed.sif docker://opensuse/tumbleweed

rocm-base.sif: rocm-base.def opensuse_tumbleweed.sif
	apptainer build $@ $<

rocm-build.sif: rocm-build.def rocm-base.sif
	apptainer build $@ $<

build: rocm-build.def rocm-base.sif
	apptainer build rocm-build.sif $<
	
rebuild: rocm-build.def rocm-base.sif
	apptainer build --force rocm-build.sif rocm-build.def

rocm-dev.sif: rocm-dev.def pytorch-build.sh # rocm-build.sif
	# echo ${CONTAINER_LOCAL_REPO}
	apptainer build --bind ${LOCAL_RPM_REPO_PATH}:${CONTAINER_LOCAL_REPO} --build-arg CONTAINER_LOCAL_REPO=${CONTAINER_LOCAL_REPO} $@ $<

apply_patches:
	./apply_patches.sh ${PATCHES}

export_patches:
	./export_patches.sh

rpm_to_repo:
	./rpm_to_repo.sh

build_sandbox:
	apptainer build --sandbox rocm-build/ rocm-build.def
