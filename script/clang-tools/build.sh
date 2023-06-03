#!/usr/bin/env bash

set -x
set -e


THIS_SCRIPT_DIR=$(realpath $(dirname $0))
source ${THIS_SCRIPT_DIR}/../common.sh




init_work_dir clang-tools 16.0.4


cd ${WORK_DIR}

LLVM_ARCHIVE=$(get_final_archive llvm $VERSION)
[[ -f ${LLVM_ARCHIVE} ]] || ${THIS_SCRIPT_DIR}/../llvm/build.sh

tar xvf ${LLVM_ARCHIVE}


LLVM_INSTALL_DIR_NAME=$(get_install_dir_name llvm ${VERSION})
function install_clang_tool()
{
    cp -a ${LLVM_INSTALL_DIR_NAME}/$1 ${INSTALL_DIR}/$(dirname $1)
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
