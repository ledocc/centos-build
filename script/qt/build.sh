#!/usr/bin/env bash

set -x
set -e

sudo yum -y install devtoolset-9
source /opt/rh/devtoolset-9/enable

sudo yum -y install perl-IPC-Cmd perl-Digest-SHA


THIS_SCRIPT_DIR=$(dirname $(realpath $0))

PROJECT_NAME=qt
VERSION=5.15.9

WORK_DIR=/tmp/${PROJECT_NAME}-${VERSION}-$(uname)-$(uname -p)
FINAL_ARCHIVE=/tmp/install/$(basename ${WORK_DIR}).tar.xz


rm -rf ${WORK_DIR}
mkdir -p ${WORK_DIR}
cd ${WORK_DIR}


conan remove -t '*'
conan install ${THIS_SCRIPT_DIR} -pr:h centos7-gcc-9 -pr:b default -b outdated
#conan info ${THIS_SCRIPT_DIR} -pr:h centos7-gcc-9 -pr:b default -g qt.dot

WORK_GENERATOR_DIR=${WORK_DIR}/generators
mkdir -p ${WORK_GENERATOR_DIR}
mv ${WORK_DIR}/*.cmake ${WORK_GENERATOR_DIR}

CONAN_HOME=$(conan config home)
sed -i "s}\"${CONAN_HOME}.*\"}\"/sitr/qt5.15.9\"}" ${WORK_GENERATOR_DIR}/*

tar Jc -C $(dirname ${WORK_DIR}) -f ${FINAL_ARCHIVE} $(basename ${WORK_DIR})
