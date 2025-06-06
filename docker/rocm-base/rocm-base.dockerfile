# Start with a base image
FROM opensuse/tumbleweed AS base

# Install required packages
RUN zypper mr -e repo-source && \
    zypper refresh && \
    zypper --non-interactive dup && \
    zypper --non-interactive install rpm-build aria2 autoconf automake bc bison bridge-utils bzip2 libcheck0 chrpath cifs-utils cmake cpio curl devscripts dos2unix doxygen fakeroot flex freeglut-devel gawk gcc glibc-devel gcc-fortran git-lfs gnupg graphviz kmod lbzip2 less libass-devel atlascpp-devel babeltrace-devel boost-devel libboost_filesystem-devel libboost_program_options-devel libboost_system-devel libbz2-devel libc++-devel libc++1 libc++abi-devel libc++abi1 libcap-devel libcurl-devel libdrm-devel libdw-devel libdw1 libdwarf-devel libelf-devel libelf1 libexpat-devel fftw3-devel perl-File-Find-Rule gflags-devel glew-devel gmp-devel glog-devel hdf5-devel libjpeg-devel leveldb-devel lmdb-devel lzma-sdk-devel mpfr-devel mpich-devel msgpack-c-devel ncurses-devel libnuma-devel libomp-devel openblas-common-devel opencv-devel libpci3 libpci3 libpciaccess-devel libpciaccess0 pciutils protobuf-devel patterns-devel-python-devel_python3 readline-devel snappy-devel libopenssl-devel suitesparse-devel systemd-devel libtool perl-URI libva-devel libvirt-client libvirt-daemon yaml-cpp-devel llvm llvm-devel llvm Mesa-devel mpich ocaml ocaml-findlib ocl-icd-devel patchelf pigz pkg-config python312-devel python312-myst-parser python312-pip python312-Sphinx python312-pip-wheel python312-requests python312-pyaml re2c rpm rsync openssh strace sudo systemtap-sdt-devel texinfo texlive texlive-extratools texlive-plain texlive-xetex unzip vim wget xsltproc xxd pciutils python312-setuptools python312-setuptools_scm texlive-scheme-medium texlive-hanging python312-lxml python312-poetry libpfm-devel msgpack-cxx-devel fmt-devel python312-pipx ninja gcc13 gcc13-c++ gcc13-fortran && \
    zypper --non-interactive install -t pattern devel_basis devel_C_C++ && \
    zypper --non-interactive remove gcc14 gcc14-c++ gcc14-fortran && \
    rm -f /usr/bin/python /usr/bin/python3 /usr/bin/python-config && \
    ln -s /usr/bin/python3.12 /usr/bin/python && \
    ln -s /usr/bin/python3.12 /usr/bin/python3 && \
    ln -s /usr/bin/python3.12-config /usr/bin/python-config && \
    ln -s /usr/lib64/cmake/msgpack-c/msgpack-c-config.cmake /usr/lib64/cmake/msgpack-c/msgpack-config.cmake

# Build BareCTF
RUN mkdir -p /tmp/barectf && cd /tmp/barectf && \
    git clone https://github.com/efficios/barectf.git . && \
    poetry build && \
    cd dist && \
    python3 -m pip install --break-system-packages barectf-3.2.0.dev0-py3-none-any.whl && \
    rm -rf /tmp/barectf

# Build Google Test Framework
RUN mkdir -p /tmp/gtest && cd /tmp/gtest && \
    wget https://github.com/google/googletest/archive/refs/tags/v1.14.0.zip -O googletest.zip && \
    unzip googletest.zip && \
    cd googletest-1.14.0/ && mkdir build && cd build && \
    cmake .. && make -j$(nproc) && make install && \
    rm -rf /tmp/gtest

# Build LAPACK
RUN lapack_version=3.9.1 && lapack_srcdir=lapack-$lapack_version && \
    lapack_blddir=lapack-$lapack_version-bld && \
    mkdir -p /tmp/lapack && cd /tmp/lapack && rm -rf "$lapack_srcdir" "$lapack_blddir" && \
    wget -O - https://github.com/Reference-LAPACK/lapack/archive/refs/tags/v3.9.1.tar.gz | tar xzf - && \
    cmake -H$lapack_srcdir -B$lapack_blddir \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_Fortran_FLAGS=-fno-optimize-sibling-calls -DBUILD_TESTING=OFF -DCBLAS=ON -DLAPACKE=OFF && \
    make -j$(nproc) -C "$lapack_blddir" && \
    make -C "$lapack_blddir" install && \
    cd $lapack_blddir && cp -r ./include/* /usr/local/include/ && \
    cp -r ./lib/* /usr/local/lib && cd / && rm -rf /tmp/lapack

# Install AOCL
RUN mkdir -p /tmp/aocl && cd /tmp/aocl && \
    wget https://download.amd.com/developer/eula/aocl/aocl-4-1/aocl-linux-aocc-4.1.0-1.x86_64.rpm && \
    zypper --non-interactive --no-gpg-checks install aocl-linux-aocc-4.1.0-1.x86_64.rpm && \
    echo "export C_INCLUDE_PATH=/opt/AMD/aocl/aocl-linux-aocc-4.1.0/aocc/include:\$C_INCLUDE_PATH" >> /etc/profile && \
    echo "export CPLUS_INCLUDE_PATH=/opt/AMD/aocl/aocl-linux-aocc-4.1.0/aocc/include:\$CPLUS_INCLUDE_PATH" >> /etc/profile && \
    echo "/opt/AMD/aocl/aocl-linux-aocc-4.1.0/aocc/lib" > /etc/ld.so.conf.d/aocl.conf && \
    ldconfig && cd / && rm -rf /tmp/aocl

# Install Repo tool
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/bin/repo && \
    chmod a+x /usr/bin/repo

# Clean up
RUN zypper -n clean