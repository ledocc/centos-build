#!/usr/bin/env bash

set -x
set -e


THIS_SCRIPT_DIR=$(realpath $(dirname $0))
source ${THIS_SCRIPT_DIR}/../common.sh




init_work_dir git-flow 1.12.3

download https://raw.githubusercontent.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh

PREFIX=${INSTALL_DIR} bash ${WORK_DIR}/gitflow-installer.sh install version ${VERSION}

make_archive
