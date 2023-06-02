#!/usr/bin/env bash

set -e
set -x

THIS_SCRIPT_DIR=$(dirname $(realpath $0))
source ${THIS_SCRIPT_DIR}/../common.sh




sudo yum -y install \
     asciidoc \
     tcl-devel \
     tk-devel \
     xmlto

init_work_dir git 2.41.0


SRC_DIR_NAME=git-${VERSION}
GIT_ARCHIVE=${GIT_DIR_NAME}.tar.gz

download_and_extract https://www.kernel.org/pub/software/scm/git/${SRC_DIR_NAME}.tar.gz
autotool_build ${WORK_DIR}/${SRC_DIR_NAME}
make -j $(nproc) all man
make install install-man

cp ${THIS_SCRIPT_DIR}/.profile_git ${INSTALL_DIR}

make_archive
