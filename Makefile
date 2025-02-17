CONTAINER_LOCAL_REPO=/opt/local_repo
OPENSUSE_BASE_IMAGE=opensuse/tumbleweed
.PHONY: build rebuild build_sandbox apply_patches get_patches rpm_to_repo opensuse_tumbleweed.docker opensuse_tumbleweed.sif

# docker
opensuse_tumbleweed.docker:
	docker pull ${OPENSUSE_BASE_IMAGE}

rocm-base.dockerfile:
	docker build -t rocm-build:latest -t rocm-build:${ROCM_VERSION} -f docker/rocm-base/$@ docker/rocm-base 

rocm-dev.dockerfile:
# Start a file server to serve the ROCm packages built by the build image and pass the URL as build-arg
	docker build -t rocm-dev:latest -t rocm-dev:${ROCM_VERSION} --network=host -f docker/rocm-dev/$@ --build-arg LOCAL_ROCM_PACKAGE_REPO_URL=${LOCAL_ROCM_PACKAGE_REPO_URL} docker/rocm-dev

rocm-run.dockerfile:
# Start a file server to serve the ROCm packages built by the build image and pass the URL as build-arg
	docker build -t rocm-run:latest -t rocm-run:${ROCM_VERSION} --network=host -f docker/rocm-run/$@ --build-arg LOCAL_ROCM_PACKAGE_REPO_URL=${LOCAL_ROCM_PACKAGE_REPO_URL} docker/rocm-run


#apptainer
opensuse_tumbleweed.sif:
	if [ ! -f "opensuse_tumbleweed.sif" ]; then \
		apptainer pull opensuse_tumbleweed.sif docker://${OPENSUSE_BASE_IMAGE}; \
	fi

rocm-base.sif: rocm-base.def opensuse_tumbleweed.sif
	apptainer build $@ $<

rocm-build.sif: rocm-build.def rocm-base.sif
	apptainer build $@ $<

build: rocm-build.def rocm-base.sif
	apptainer build rocm-build.sif $<
	
rebuild: rocm-build.def rocm-base.sif
	apptainer build --force rocm-build.sif rocm-build.def

rocm-dev.sif: rocm-dev.def # scripts/pytorch-build.sh # rocm-build.sif
	# echo ${CONTAINER_LOCAL_REPO}
	apptainer build --build-arg LOCAL_ROCM_PACKAGE_REPO_URL=${LOCAL_ROCM_PACKAGE_REPO_URL} $@ $<

rocm-run.sif: rocm-run.def # scripts/pytorch-build.sh # rocm-build.sif
	# echo ${CONTAINER_LOCAL_REPO}
	apptainer build --build-arg LOCAL_ROCM_PACKAGE_REPO_URL=${LOCAL_ROCM_PACKAGE_REPO_URL} $@ $<

open-webui.sif: open-webui.def #rocm-dev.sif
	apptainer build $@ $<

apply_patches:
	./apply_patches.sh ${PATCHES}

export_patches:
	./export_patches.sh

rpm_to_repo:
	./rpm_to_repo.sh

build_sandbox:
	apptainer build --sandbox rocm-build/ rocm-build.def
