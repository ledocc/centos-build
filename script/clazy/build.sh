#!/usr/bin/env bash

set -x
set -e


THIS_SCRIPT_DIR=$(realpath $(dirname $0))
source ${THIS_SCRIPT_DIR}/../common.sh


llvm_dir=$(install_final_archive llvm)


init_work_dir clazy master

#download_and_extract https://github.com/KDE/${PROJECT_NAME}/archive/refs/tags/v${VERSION}.tar.gz

# use git instead of last available version (1.11) to have llvm 16 support
git clone https://github.com/KDE/${PROJECT_NAME}
overload_version $(date -u +%Y-%m-%d)-$(cd ${WORK_DIR}/clazy; git rev-parse --short HEAD)
overload_src_dir_name ${PROJECT_NAME}



cmake_build \
    -DLLVM_ROOT="${llvm_dir}"

make_archive
