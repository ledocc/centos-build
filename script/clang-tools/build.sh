#!/usr/bin/env bash

set -x
set -e


THIS_SCRIPT_DIR=$(realpath $(dirname $0))
source ${THIS_SCRIPT_DIR}/../common.sh




init_work_dir clang-tools 16.0.4

SRC_DIR=llvm-project-${VERSION}.src
download_and_extract https://github.com/llvm/llvm-project/releases/download/llvmorg-${VERSION}/${SRC_DIR}.tar.xz

cmake_build \
    ${SRC_DIR}/llvm \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}_all \
    -DBUILD_SHARED_LIBS=OFF \
    -DLLVM_CCACHE_BUILD=ON \
    -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra' \
    -DLLVM_ENABLE_RTTI=ON


function install_clang_tool()
{
    cp -a ${INSTALL_DIR}_all/$1 ${INSTALL_DIR}/$(dirname $1)
}

mkdir -p ${INSTALL_DIR}/{bin,share/clang}
install_clang_tool bin/clang-format
install_clang_tool bin/clang-include-cleaner
install_clang_tool bin/clang-include-fixer
install_clang_tool bin/clang-tidy
install_clang_tool bin/clangd
install_clang_tool bin/git-clang-format
install_clang_tool share/clang/clang-format-diff.py
install_clang_tool share/clang/clang-format.py
install_clang_tool share/clang/clang-include-fixer.py
install_clang_tool share/clang/clang-tidy-diff.py


make_archive
