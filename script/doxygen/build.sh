#!/usr/bin/env bash

set -x
set -e


THIS_SCRIPT_DIR=$(realpath $(dirname $0))
source ${THIS_SCRIPT_DIR}/../common.sh

sudo yum -y install \
     bison \
     flex 

llvm_dir=$(install_final_archive llvm)
graphviz_dir=$(install_final_archive graphviz)

init_work_dir doxygen 1.9.7

ARCHIVE_NAME=Release_${VERSION_UNDERSCORED}
overload_src_dir_name doxygen-${ARCHIVE_NAME}

download_and_extract https://github.com/${PROJECT_NAME}/${PROJECT_NAME}/archive/refs/tags/${ARCHIVE_NAME}.tar.gz

sed -i "s/find_package(Qt\([56]\)Core/find_package(Qt\1 COMPONENTS Core/" ${SRC_DIR}/addon/doxywizard/CMakeLists.txt
sed -i "s/Qt\([56]\)Core_FOUND/Qt\1_FOUND/g" ${SRC_DIR}/addon/doxywizard/CMakeLists.txt

cmake_build \
    -DCMAKE_PREFIX_PATH="${llvm_dir};${graphviz_dir};${qt_dir}/cmake" \
    -Dstatic_libclang=ON \
    -Duse_libclang=ON


make_archive
