#!/usr/bin/env bash

set -x
set -e


THIS_SCRIPT_DIR=$(realpath $(dirname $0))
source ${THIS_SCRIPT_DIR}/../common.sh




init_work_dir cppcheck 2.10

download_and_extract https://github.com/danmar/${PROJECT_NAME}/archive/${VERSION}.tar.gz

cmake_build

make_archive
