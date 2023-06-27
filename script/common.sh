#!/usr/bin/env bash


THIS_SCRIPT_DIR=$(realpath $(dirname $0))


FINAL_ARCHIVE_PREFIX=/tmp/archive
FINAL_ARCHIVE_EXTENSION=tar.xz
TAR_COMPRESS_OPT=J

PACKAGE_INSTALL_PREFIX=/tmp/install

function get_final_archive_path_for()
{
    ls -1 ${FINAL_ARCHIVE_PREFIX}/*$1*|tail -n1
}
function get_or_create_final_archive_path_for()
{
    local final_archive_path__=$(get_final_archive_path_for $2)
    if [[ -f ${final_archive_path__} ]]
    then
	eval $1=${final_archive_path__}
	return
    fi
    
    /tmp/script/$2/build.sh
    final_archive_path__=$(get_final_archive_path_for $2)
}

function package_dir_name_from_archive()
{
    echo $(tar -t $1 | head -n1 | cut -d/ -f1)
}

function install_final_archive()
{
    get_or_create_final_archive_path_for final_archive_path $1
    
    local final_archive_name=$(basename ${final_archive_path})
    local package_dir_name=${final_archive_name%.${FINAL_ARCHIVE_EXTENSION}}

    package_dir=${PACKAGE_INSTALL_PREFIX}/${package_dir_name}

    if [[ ! -d ${package_dir} ]]
    then
	mkdir -p ${PACKAGE_INSTALL_PREFIX}
	tar x -C ${PACKAGE_INSTALL_PREFIX} -f $(get_final_archive_path_for $1)
    fi
    
    echo ${package_dir}
}


function get_install_dir_name()
{
    local PROJECT_NAME=$1
    local VERSION=$2

    echo ${PROJECT_NAME}-${VERSION}-$(uname)-$(uname -p)
}

function get_final_archive_name()
{
    echo $(get_install_dir_name $@).${FINAL_ARCHIVE_EXTENSION}
}

function get_final_archive()
{
    echo ${FINAL_ARCHIVE_PREFIX}/$(get_final_archive_name $@)
}

function overload_src_dir_name()
{
    SRC_DIR_NAME=$1
    SRC_DIR=${WORK_DIR}/${SRC_DIR_NAME}
}

function init_work_dir()
{
    PROJECT_NAME=$1

    VERSION=$2
    VERSION_UNDERSCORED=$(echo ${VERSION} | tr . _)

    WORK_DIR=/tmp/${PROJECT_NAME}
    BUILD_DIR=${WORK_DIR}/build

    SRC_DIR_NAME=${PROJECT_NAME}-${VERSION}
    SRC_DIR=${WORK_DIR}/${SRC_DIR_NAME}
    
    INSTALL_DIR_NAME=$(get_install_dir_name ${PROJECT_NAME} ${VERSION})
    INSTALL_DIR=${WORK_DIR}/${INSTALL_DIR_NAME}

    
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
    FINAL_ARCHIVE=$(get_final_archive $PROJECT_NAME $VERSION)
    tar c${TAR_COMPRESS_OPT} -C ${WORK_DIR} -f ${FINAL_ARCHIVE} ${INSTALL_DIR_NAME}
}


function pip_download_and_make_archive()
{
    PROJECT_NAME=$1
    VERSION=${2:-latest}

    WORK_DIR=/tmp/${PROJECT_NAME}
    INSTALL_DIR_NAME=${PROJECT_NAME}-${VERSION}

    rm -rf ${WORK_DIR}
    mkdir -p ${WORK_DIR}/${INSTALL_DIR_NAME}
    cd ${WORK_DIR}/${INSTALL_DIR_NAME}
    
    pip download ${PROJECT_NAME}${2:+==${2}}
    make_archive
}
