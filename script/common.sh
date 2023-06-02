#!/usr/bin/env bash


THIS_SCRIPT_DIR=$(realpath $(dirname $0))


function init_work_dir()
{
    PROJECT_NAME=$1
    
    WORK_DIR=/tmp/${PROJECT_NAME}
    BUILD_DIR=${WORK_DIR}/build


    VERSION=$2
    SRC_DIR_NAME=${PROJECT_NAME}-${VERSION}
    INSTALL_DIR_NAME=${PROJECT_NAME}-${VERSION}-$(uname)-$(uname -p)
    INSTALL_DIR=${WORK_DIR}/${INSTALL_DIR_NAME}
    FINAL_ARCHIVE=/tmp/install/${INSTALL_DIR_NAME}.tar.xz

    
    echo "Do work in \"${WORK_DIR}\"."
    rm -rf ${WORK_DIR}
    mkdir -p ${WORK_DIR}
    cd ${WORK_DIR}
}

function download()
{
    URL=$1

    cd ${WORK_DIR}
    curl -L -O ${URL}
}

function download_and_extract()
{
    URL=$1

    download ${URL}
    tar xvf $(basename ${URL})
}


function autotool_build()
{
    SRC_DIR=${1:-${WORK_DIR}/${SRC_DIR_NAME}}
    
    cd ${SRC_DIR}
    if [[ ! -f configure  ]]
    then
	./autogen.sh
    fi

    ./configure --prefix=${INSTALL_DIR} ${CONFIGURE_OPTS}
    make -j$(nproc)
    make install
}

function cmake_build()
{
    SRC_DIR=$1
    shift
    
    cmake \
	-S ${SRC_DIR} \
	-B ${BUILD_DIR} \
	-G Ninja \
	-DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
	-DCMAKE_BUILD_TYPE=Release $@
	
    
    cmake --build ${BUILD_DIR}
    cmake --install ${BUILD_DIR} --strip
}


function make_archive()
{
    tar Jc -C ${WORK_DIR} -f ${FINAL_ARCHIVE} ${INSTALL_DIR_NAME}
}
