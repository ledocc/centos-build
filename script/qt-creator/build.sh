#!/bin/bash -ex

THIS_SCRIPT_DIR=$(realpath $(dirname $0))
source ${THIS_SCRIPT_DIR}/../common.sh




function build_rustc_demangle
{
    init_work_dir rustc-demangle 0.1.23

    download_and_extract https://github.com/rust-lang/${PROJECT_NAME}/archive/refs/tags/${VERSION}.tar.gz

    cd ${SRC_DIR}
    cargo build -p rustc-demangle-capi --release

    mkdir -p ${INSTALL_DIR}
    cp ${SRC_DIR}/target/release/librustc_demangle.so ${INSTALL_DIR}
    
    rustc_demangle_dir=${INSTALL_DIR}
}


function install_dmd
{
    init_work_dir dmd 2.104.0

    download_and_extract https://downloads.dlang.org/releases/2.x/${VERSION}/dmd.${VERSION}.linux.tar.xz
    overload_src_dir_name dmd2

    PATH=${SRC_DIR}/linux/bin64:${PATH}
}


function build_d_demangler
{
    init_work_dir d_demangler 0.0.2

    download_and_extract https://github.com/lievenhey/${PROJECT_NAME}/archive/refs/tags/version-${VERSION}.tar.gz
    overload_src_dir_name ${PROJECT_NAME}-version-${VERSION}

    cd ${SRC_DIR}
    make

    mkdir -p ${INSTALL_DIR}
    cp ${SRC_DIR}/libd_demangle.so ${INSTALL_DIR}

    d_demangler_dir=${INSTALL_DIR}
}


function run_conan()
{
    local QTC_SRC_DIR=$1
    local QTC_BUILD_DIR=$2
    
    QT_VERSION=$(grep "qt/.*@" ${QTC_SRC_DIR}/conanfile.txt | cut -c 4-8)
    QTC_CONAN_PROFILE_OPT="-pr:h centos7-gcc-10 -pr:b default"

    cd ${QTC_BUILD_DIR}
    conan remove -t '*'
    conan install ${QTC_SRC_DIR} ${QTC_CONAN_PROFILE_OPT} 
    rm -f ${QTC_BUILD_DIR}/Qt6*

    QT_BUILD_DIR=$(conan info ${QTC_SRC_DIR} ${QTC_CONAN_PROFILE_OPT} -j --paths 2>/dev/null| \
		       jq -r ".[]|select(.reference==\"qt/${QT_VERSION}\")|.build_folder")/build/Release

    QT_INSTALL_DIR=$(conan info ${QTC_SRC_DIR} ${QTC_CONAN_PROFILE_OPT} -j --paths 2>/dev/null| \
			 jq -r ".[]|select(.reference==\"qt/${QT_VERSION}\")|.package_folder")

    # regenerate Qt's cmake script in install dir
    cmake --install ${QT_BUILD_DIR}

}

function build_qt_creator
{
    PATCH_DIR=${THIS_SCRIPT_DIR}/patch
    
    
    init_work_dir qt-creator 10.0.2
    VERSION_MAJOR_MINOR=$(echo ${VERSION} | sed "s/^\([0-9]*\.[0-9]*\)\..*$/\1/")

    
    overload_src_dir_name ${PROJECT_NAME}-opensource-src-${VERSION}
    download_and_extract https://download.qt.io/official_releases/qtcreator/${VERSION_MAJOR_MINOR}/${VERSION}/${SRC_DIR_NAME}.tar.xz
	
    cd ${SRC_DIR}
    patch -p1 < ${PATCH_DIR}/0001-chore-cmake-add-centos-7-build-support.patch
    

    run_conan ${SRC_DIR} ${BUILD_DIR}


    # use by qt-creator Find*.cmake script to found d_demangler and rustc_demangle
    export LIBRARY_PATH=${d_demangler_dir}:${rustc_demangle_dir}
    
    cmake_build \
	-DCMAKE_PREFIX_PATH="${BUILD_DIR};${QT_INSTALL_DIR}" \
	-DClang_DIR=${llvm_dir}/lib/cmake/clang

    cmake --install ${BUILD_DIR} --component Dependencies
    
    cp ${clazy_dir}/bin/clazy-standalone ${INSTALL_DIR}/libexec/qtcreator/clang/bin
    cp ${clazy_dir}/lib64/ClazyPlugin.so ${INSTALL_DIR}/libexec/qtcreator/clang/lib
    cp ${THIS_SCRIPT_DIR}/.profile_qt-creator ${INSTALL_DIR}
	

    make_archive
}

llvm_dir=$(install_final_archive llvm)
clazy_dir=$(install_final_archive clazy)

build_rustc_demangle
install_dmd
build_d_demangler

build_qt_creator


