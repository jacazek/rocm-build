.PHONY: build rebuild build_sandbox apply_patches get_patches rpm_to_repo

opensuse_tumbleweed.sif:
	apptainer pull opensuse_tumbleweed.sif docker://opensuse/tumbleweed

rocm-base.sif: opensuse_tumbleweed.sif rocm-base.def
	apptainer build rocm-base.sif rocm-base.def

build: rocm-build.def rocm-base.sif
	apptainer build rocm-build.sif rocm-build.def

rebuild: rocm-build.def rocm-base.sif
	apptainer build --force rocm-build.sif rocm-build.def

apply_patches:
	./apply_patches.sh ${PATCHES}

export_patches:
	./export_patches.sh

rpm_to_repo:
	./rpm_to_repo.sh

build_sandbox:
	apptainer build --sandbox rocm-build/ rocm-build.def
