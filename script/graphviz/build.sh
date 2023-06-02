#!/usr/bin/env bash

set -x
set -e


THIS_SCRIPT_DIR=$(dirname $(realpath $0))
source ${THIS_SCRIPT_DIR}/../common.sh


sudo yum -y install \
    librsvg2-devel \
    cairo-devel \
    pango-devel \
    poppler-devel \
    libwebp-devel
    

init_work_dir graphviz 8.0.5

download_and_extract https://gitlab.com/api/v4/projects/4207231/packages/generic/graphviz-releases/${VERSION}/${SRC_DIR_NAME}.tar.xz

CONFIGURE_OPTS="--disable-shared --enable-static"
autotool_build

make_archive
