#!/usr/bin/env bash

set -x
set -e

THIS_SCRIPT_DIR=$(dirname $(realpath $0))
source ${THIS_SCRIPT_DIR}/../common.sh



sudo yum -y install yum-utils
sudo yum-builddep -y python3


init_work_dir Python 3.9.16

download_and_extract https://www.python.org/ftp/python/${VERSION}/${SRC_DIR_NAME}.tar.xz

CONFIGURE_OPTS="--enable-optimizations --disable-test-modules"
autotool_build

cd ${WORK_DIR}
curl -L -O https://bootstrap.pypa.io/get-pip.py
${INSTALL_DIR}/bin/python3 get-pip.py

make_archive
