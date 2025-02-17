FROM rocm-build AS base

ARG LOCAL_ROCM_PACKAGE_REPO_URL

RUN curl http://localhost:8008/repodata/repomd.xml && \
    zypper --non-interactive addrepo -f ${LOCAL_ROCM_PACKAGE_REPO_URL} local_repo && \
    zypper --non-interactive --no-gpg-checks refresh && \
    zypper --non-interactive --no-gpg-checks install `zypper search -r local_repo | grep -v -i 'tests\|client\|benchmark\|debuginfo\|sample\|devel\|gfx90a\|gfx900\|gfx906\|gfx942\|gfx1030\|nvidia\|rocprofiler-sdk' | cut -d '|' -f 2 | tr -d ' \t' | tail -n +6` &&  \
    zypper -n clean
