#!/usr/bin/env bash

set -x
set -e


sudo yum -y install \
     perl-IPC-Cmd \
     perl-Digest-SHA


THIS_SCRIPT_DIR=$(dirname $(realpath $0))
source ${THIS_SCRIPT_DIR}/../common.sh


qt_version=$(grep qt/ ${THIS_SCRIPT_DIR}/conanfile.txt | sed "s#qt/\([.0-9]*\)@#\1#")


init_work_dir qt ${qt_version}
mkdir -p ${INSTALL_DIR}
cd ${INSTALL_DIR}

conan remove -t '*'
conan install ${THIS_SCRIPT_DIR} -pr:h centos7-gcc-9 -pr:b default -b outdated
conan info ${THIS_SCRIPT_DIR} -pr:h centos7-gcc-9 -pr:b default -g qt.dot

CMAKE_CONFIG_DIR=${INSTALL_DIR}/cmake
mkdir -p ${CMAKE_CONFIG_DIR}
mv ${INSTALL_DIR}/*.cmake ${CMAKE_CONFIG_DIR}

CONAN_HOME=$(conan config home)
sed -i "s}\"${CONAN_HOME}.*\"}\"\$\{CMAKE_CURRENT_LIST_DIR\}/..\"}" ${CMAKE_CONFIG_DIR}/*.cmake


. ${THIS_SCRIPT_DIR}/fix_runpath.sh
set +e
set +x
set_runpath_on_dir ${INSTALL_DIR}/bin '$ORIGIN/../lib'
set_runpath_on_dir ${INSTALL_DIR}/lib '$ORIGIN'

set -x
make_archive
