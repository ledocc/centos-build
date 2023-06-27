#!/usr/bin/env bash

set -x
set -e


THIS_SCRIPT_DIR=$(realpath $(dirname $0))
source ${THIS_SCRIPT_DIR}/../common.sh




init_work_dir llvm 16.0.4

SRC_DIR=llvm-project-${VERSION}.src
download_and_extract https://github.com/llvm/llvm-project/releases/download/llvmorg-${VERSION}/${SRC_DIR}.tar.xz


SRC_DIR=${SRC_DIR}/llvm
cmake_build \
    -DBUILD_SHARED_LIBS=OFF \
    -DLLVM_CCACHE_BUILD=ON \
    -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra' \
    -DLLVM_ENABLE_RTTI=ON

make_archive
