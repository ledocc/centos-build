#!/usr/bin/env bash

set -x
set -e


sudo yum -y install \
    librsvg2-devel \
    cairo-devel \
    pango-devel \
    poppler-devel \
    libwebp-devel
    


GRAPHVIZ_VERSION=8.0.5
GRAPHVIZ_SRC_DIR=graphviz-${GRAPHVIZ_VERSION}
GRAPHVIZ_ARCHIVE=${GRAPHVIZ_SRC_DIR}.tar.xz
GRAPHVIZ_INSTALL_DIRNAME=${GRAPHVIZ_SRC_DIR}-$(uname)-$(uname -p)
GRAPHVIZ_INSTALL_DIR=/tmp/install/${GRAPHVIZ_INSTALL_DIRNAME}
GRAPHVIZ_FINAL_ARCHIVE_PATH=${GRAPHVIZ_INSTALL_DIR}.tar.xz


curl -L -O https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/${GRAPHVIZ_VERSION}/${GRAPHVIZ_ARCHIVE}
tar xvf ${GRAPHVIZ_ARCHIVE}
cd ${GRAPHVIZ_SRC_DIR}
./configure --enable-static --prefix ${GRAPHVIZ_INSTALL_DIR}
make ${nproc}
make install

tar Jcvf ${GRAPHVIZ_FINAL_ARCHIVE_PATH} \
    -C $(dirname ${GRAPHVIZ_INSTALL_DIR}) \
    $(basename ${GRAPHVIZ_INSTALL_DIR})
