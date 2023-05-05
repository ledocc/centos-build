#!/usr/bin/env bash

set -e

THIS_SCRIPT_DIR=$(dirname $(realpath $0))


. /opt/rh/devtoolset-10/enable



####################################################################################################
# python installation
####################################################################################################
PYTHON_VERSION=3.9.16

sudo yum -y install yum-utils
sudo yum-builddep -y python3

PYTHON_BUILD_DIR=/tmp/python-${PYTHON_VERSION}-build
mkdir -p ${PYTHON_BUILD_DIR}
pushd ${PYTHON_BUILD_DIR}

PYTHON_DIR_NAME=Python-${PYTHON_VERSION}
PYTHON_ARCHIVE=${PYTHON_DIR_NAME}.tar.xz
curl -L -O https://www.python.org/ftp/python/${PYTHON_VERSION}/${PYTHON_ARCHIVE}
tar xvf ${PYTHON_ARCHIVE}

cd ${PYTHON_DIR_NAME}
./configure --enable-optimizations
make -j $(nproc)
sudo make install

popd
sudo rm -rf ${PYTHON_BUILD_DIR}

python3 -m pip install --upgrade pip


####################################################################################################
# ninja installation
####################################################################################################
pip3 install --user ninja


####################################################################################################
# cmake installation
####################################################################################################
pip3 install cmake


####################################################################################################
# conan installation
####################################################################################################
pip3 install --user conan==1.59
PATH=~/.local/bin:${PATH}

conan config init
cp ${THIS_SCRIPT_DIR}/conan/profiles/* ${HOME}/.conan/profiles
