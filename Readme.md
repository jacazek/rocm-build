## Manual steps

**REVISE THESE**

1. copy all packages from rocm docker build pacakges
2. Replace "build-essentials" with "devel_basis"
3. Replace "libpython3-dev" with "python-devel"
4. Replace "-dev" with "-devel"

## Images

### Base image

Base image containing most dependencies. Exists to avoid re-installing a lot of dependencies if a missing dependency identified during build of ROCm.

Build the base tumbleweed image running `make rocm-base.sif`

This will build the base image for development. It is from this image you can build the ROCm build image. It provides a base image on top of which additional packages may be installed to minimize build types if a build dependency is missing.

### Build image

Image used to build ROCm.

Build the build image running `make build` or `make rebuild` to overwrite existing build image.

Add any missing dependencies to %post build script and rebuild to quickly generate new build image.

Example run command:
`GPU_ARCHS="gfx908;gfx1100" GFXLIST="gfx908;gfx1100" NOBUILD=rocprofiler-systems apptainer shell --rocm --bind opt/rocm-${ROCM_VERSION}:/opt/rocm-${ROCM_VERSION} rocm-build.sif`

Should be run from the root working directory of ROCm project. Apptainer has readonly filesystem (unless run in sandbox mode) so binding an output directory for build artifacts.

### Dev image

Image includes ROCm binaries, libraries, headers needed for development against ROCm.

### Run image

Image includes ROCm binaries and libraries needed for running ROCm applications.

## References

https://github.com/lamikr/rocm_sdk_builder/blob/master/README.md
https://github.com/ROCm/ROCm?tab=readme-ov-file#building-the-rocm-source-code

## nobuild

1. rocprofile-systems. Need to sort out dependency issue.

## Project issues

### General issue

1. Setting GPU_ARCHS does not seem to carry over to openmp-extras GFXLIST. That environment variable needs set independently

### openmp-extras

RPM test build script has an invalid empty `Requires:` attributes. Is should be removed.

### aqlprofile

Build script only runs if on ubuntu as it pulls binary from radeon apt repo. Should consider repackaging into RPM or see if AMD publishes and RPM somewhere.

Not sure how they support REHL or Fedora if aqlprofile is unavailble.

Manually copied and extracted lib. https://repo.radeon.com/rocm/apt/6.3.1/pool/main/h/hsa-amd-aqlprofile/hsa-amd-aqlprofile_1.0.0.60301-48~24.04_amd64.deb

Consider just retrieving and bundling the library in the base image and create a script to extract archive, untar the files and copy library to /usr

```sh
file="hsa-amd-aqlprofile_1.0.0.60301-48~24.04_amd64.deb"
wget https://repo.radeon.com/rocm/apt/6.3.1/pool/main/h/hsa-amd-aqlprofile/$file
ar $file
tar -xzf data.tar.gz
mv

```

### rocprofiler and sdk?

Needs aqlprofile.

### rocprofiler-systems

Has issue linking to libpapi has problem finding pfmlib_common.o when compiling libpapi.  
The issue seems to be that the `ar xv` command is not executing, is not finding libpfm.a, is is executing from within the wrong directory.

For some reason, the following in `Makefile.inc` for papi

```makefile
$(LIBRARY): $(OBJECTS)
	rm -f $(LIBRARY)
	$(AR) $(ARG64) rv $(LIBRARY) $(OBJECTS)
```

Does not trigger the following for `Rules.pfm4_pe`:

```makefile
$(PFM_OBJS): $(PFM_LIB_PATH)/libpfm.a
	$(AR) xv $<
```

There seems to be a disconnect between `$(OBJECTS)` and `$(PFM_OBJS)`
So modifying the `Makefile.inc` as follows makes it work:

```diff
$(LIBRARY): $(OBJECTS)
	rm -f $(LIBRARY)
+	$(AR) xv $(PFM_LIB_PATH)/libpfm.a
	$(AR) $(ARG64) rv $(LIBRARY) $(OBJECTS)
```

or

```diff
# Rules.pfm4_pe
+pfm_objs: $(PFM_LIB_PATH)/libpfm.a
+	$(AR) xv $<
+.PHONY: pfm_objs

# Makefile.inc
-$(LIBRARY): $(OBJECTS)
+$(LIBRARY): pfm_objs $(OBJECTS)
	rm -f $(LIBRARY)
	$(AR) $(ARG64) rv $(LIBRARY) $(OBJECTS)
```

### hipblaslt

needs cmake update to look for msgpack-c-config.cmake instead of msgpack-config.cmake

symlinked msgpack-c-config.cmake to msgpack-config.cmake in /usr/lib/cmake/msgpack-c

### rocblas

Need to make sure blas libraries are installed for the rocblas linking. There are specific versions specified in the rocblas client CMakeLists.txt.

Reference here for installer, but may need to ajdust version numbers. https://amd.com/en/developer/aocl.html.

### rccl

distributed processing does not work in recent kernels. Patching is necessary to not use legacy mode.  
https://github.com/ROCm/rccl/issues/1454  
https://gist.github.com/LunNova/1aeafef9239e129985714b8edbcfd58f

Run with env var `HSA_ENABLE_IPC_MODE_LEGACY=0` to disable legacy mode.

RCCL is not copied into the opt/rocm-6.3.1 directory for building the package. Looks like other dependencies are also not copied. Will need to probably run package installers in apptainer image or on local machine to make sure all libraries are installed.

### MIOpen

Need to remove device_mha_operations from CMakeLists.txt and src/CMakeLists.txt. (also moved linker flags up to same location as find pkg)

Apparently MHA operations are unsupported on gfx908. Not sure what is MHA and why it is unsupported.

## Post container build

1. create a working directory for ROCm
2. create a folder call opt/rocm-[version] in that working directory (e.g. `mkdir -p opt/rocm-6.3.1`)
3. start an instance of the build container (rocm-build.sif) within the ROCm working directory and bind opt/rocm-x.y.z to the containers /opt/rocm-x.y.z
4. create a python virtual environment using build container's python in the work directory
5. activate the virtual environment
6. Follow rocm build instructions
   1. Before building, apply any patches by setting ROCM_ROOT_PATH environment variable pointing to the ROCm build directory in order to export or apply patches. Some commands run using sudo and elevating privliges is not permitted in apptainer container. Some patches remove sudo from command or remove command entirely if not needed.

## Note about pytorch

Installation of pytorch via nightly rocm builds will include many of the rocm libraries when installed.  
May need to do a custom build of pytorch to use my libraries.  
Could also just drop local libraries into torch lib folder...

## Note about vllm

Building vllm fails to find certain algorithm dependencies.
Look into why it fails to find them. maybe a g++-14 issue so maybe only install g++-13?
