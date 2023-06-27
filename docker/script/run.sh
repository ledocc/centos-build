#!/usr/bin/env bash

set -e

THIS_SCRIPT_DIR=$(dirname $(realpath $0))

${THIS_SCRIPT_DIR}/build_env/build.sh
${THIS_SCRIPT_DIR}/update_bashrc.sh
