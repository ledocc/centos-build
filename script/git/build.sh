#!/usr/bin/env bash

set -e
set -x

THIS_SCRIPT_DIR=$(dirname $(realpath $0))

. /opt/rh/devtoolset-10/enable


sudo yum -y install \
     asciidoc \
     xmlto


GIT_VERSION=2.40.1

GIT_BUILD_DIR=/tmp/git-${GIT_VERSION}-build
mkdir -p ${GIT_BUILD_DIR}
pushd ${GIT_BUILD_DIR}

GIT_DIR_NAME=git-${GIT_VERSION}
GIT_ARCHIVE=${GIT_DIR_NAME}.tar.gz
curl -L -O https://www.kernel.org/pub/software/scm/git/${GIT_ARCHIVE}
tar xvf ${GIT_ARCHIVE}

GIT_INSTALL_DIR=${GIT_BUILD_DIR}/install/git-${GIT_VERSION}-$(uname)-$(uname -p)
cd ${GIT_DIR_NAME}
./configure --prefix=${GIT_INSTALL_DIR}
make -j $(nproc) all man

make install install-man
cp ${THIS_SCRIPT_DIR}/.profile_git ${GIT_INSTALL_DIR}

GIT_FINAL_ARCHIVE_PATH=${GIT_INSTALL_DIR}.txz
tar Jcvf ${GIT_FINAL_ARCHIVE_PATH} \
    -C $(dirname ${GIT_INSTALL_DIR}) \
    $(basename ${GIT_INSTALL_DIR})

cp ${GIT_FINAL_ARCHIVE_PATH} /tmp/install

popd
