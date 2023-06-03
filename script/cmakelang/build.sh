#!/usr/bin/env bash

set -x
set -e

THIS_SCRIPT_DIR=$(dirname $(realpath $0))
source ${THIS_SCRIPT_DIR}/../common.sh


pip_download_and_make_archive cmakelang

    
