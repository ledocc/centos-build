#!/usr/bin/env bash

set -x
set -e

THIS_SCRIPT_DIR=$(dirname $(realpath $0))
source ${THIS_SCRIPT_DIR}/../common.sh


sudo yum -y install \
     automake \
     byacc \
     libevent-devel \
     ncurse-devel

init_work_dir tmux 3.3a

download_and_extract https://github.com/tmux/tmux/archive/refs/tags/${VERSION}.tar.gz

autotool_build

make_archive
