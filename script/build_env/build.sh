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
#pip3 install cmake
# prefere complete installation to have ccmake

CMAKE_VERSION=3.26.3


CMAKE_DIR_NAME=cmake-${CMAKE_VERSION}-linux-x86_64
CMAKE_ARCHIVE=${CMAKE_DIR_NAME}.tar.gz
curl -L -O https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/${CMAKE_ARCHIVE}
tar xvf ${CMAKE_ARCHIVE}

LOCAL_APP_DIR=${HOME}/.local/app
rm -rf ${LOCAL_APP_DIR}/${CMAKE_DIR_NAME}
mkdir -p ${LOCAL_APP_DIR}
mv ${CMAKE_DIR_NAME} ${LOCAL_APP_DIR}

sudo rm -f ${CMAKE_ARCHIVE}

for exe in $(ls -dC1 ${LOCAL_APP_DIR}/${CMAKE_DIR_NAME}/bin/*)
do
    ln -s ${exe} -t ${HOME}/.local/bin
done

####################################################################################################
# conan installation
####################################################################################################
pip3 install --user conan==1.59
PATH=~/.local/bin:${PATH}

conan config init
cp ${THIS_SCRIPT_DIR}/conan/profiles/* ${HOME}/.conan/profiles
