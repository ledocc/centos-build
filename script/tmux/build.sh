#!/usr/bin/env bash

set -x

sudo yum -y install \
     automake \
     byacc \
     libevent-devel \
     ncurse-devel
     

TMUX_VERSION=3.3a
TMUX_ARCHIVE=${TMUX_VERSION}.tar.gz
TMUX_SRC_DIR=tmux-${TMUX_VERSION}
TMUX_INSTALL_DIR=/tmp/install/${TMUX_SRC_DIR}-$(uname)-$(uname -p)
TMUX_FINAL_ARCHIVE_PATH=/tmp/install/${TMUX_SRC_DIR}.tar.xz

curl -L -O https://github.com/tmux/tmux/archive/refs/tags/${TMUX_ARCHIVE}
tar xvf ${TMUX_ARCHIVE}
cd ${TMUX_SRC_DIR}
./autogen.sh
./configure --prefix ${TMUX_INSTALL_DIR}
make ${nproc}
make install

tar Jcvf ${TMUX_FINAL_ARCHIVE_PATH} \
    -C $(dirname ${TMUX_INSTALL_DIR}) \
    $(basename ${TMUX_INSTALL_DIR})
