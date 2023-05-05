#!/bin/bash -ex

THIS_SCRIPT_DIR=$(realpath $(dirname $0))

ROOT_DIR=$(pwd)
ARCHIVE_DIR=${ROOT_DIR}/archive
SRC_DIR=${ROOT_DIR}/source
BUILD_DIR=${ROOT_DIR}/build
INSTALL_DIR=${ROOT_DIR}/install



function _create_and_cd
{
    mkdir -p $1
    cd $1
}


function _is_done
{
    [[ -f ${1}/.done ]]
}
function _is_dirty
{
    [[ -f ${1}/.dirty ]]
}
function _set_dirty
{
    mkdir -p ${1}
    rm -f ${1}/.done
    touch ${1}/.dirty
}
function _set_done
{
    mkdir -p ${1}
    rm -f ${1}/.dirty
    touch ${1}/.done
}
function _clean_if_dirty_and_set_dirty
{
    _is_dirty ${1} && rm -rf ${1}
    _set_dirty ${1}
}

function _begin_process
{
    if [[ -v _PROCESS_DIR ]]
    then
	echo "Error: _begin_process: process already running !"
	exit
    fi

    _is_done ${1} && return 1

    _PROCESS_DIR=$1
    _clean_if_dirty_and_set_dirty ${_PROCESS_DIR}
}

function _end_process
{
    if [[ ! -v _PROCESS_DIR ]]
    then
	echo "Error: _end_process: no process running !"
	exit
    fi

    _set_done ${_PROCESS_DIR}
    unset _PROCESS_DIR
}

function _disable_env_var
{
    export ${1}_disabled=${!1}
    unset ${1}
}
function _enable_env_var
{
    if [[ ! -v ${1}_disabled ]]
    then
	echo error: enable_env_var: \"${1}\" not previously disabled
	exit
    fi
    
    var=${1}_disabled
    export ${1}=${!var}
}

function build_clang
{
    LLVM_VERSION=${1:-16.0.3}

    LLVM_ARCHIVE_DIR=${ARCHIVE_DIR}/llvm
    LLVM_SRC_DIR=${SRC_DIR}/llvm
    LLVM_GIT_DIR=${LLVM_SRC_DIR}/llvm-git
    LLVM_BUILD_DIR=${BUILD_DIR}/llvm
    LLVM_INSTALL_DIR=${INSTALL_DIR}/llvm

    function clone
    {
	_begin_process ${LLVM_SRC_DIR} || return 0
	
	_create_and_cd ${LLVM_SRC_DIR}
	git clone -b llvmorg-${LLVM_VERSION} https://github.com/llvm/llvm-project.git llvm-git
	
	_end_process
    }

    function build
    {
	_begin_process ${LLVM_BUILD_DIR} || return 0

	cmake \
	    -S ${LLVM_GIT_DIR}/llvm \
	    -B ${LLVM_BUILD_DIR} \
	    -G Ninja \
	    -DCMAKE_BUILD_TYPE=Release \
	    -DLLVM_CCACHE_BUILD=ON \
	    -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra' \
	    -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_DIR}

	cmake \
	    --build \
	    ${LLVM_BUILD_DIR}

	_end_process
    }

    function install
    {
	_begin_process ${LLVM_INSTALL_DIR} || return 0

	cmake \
	    --install \
	    ${LLVM_BUILD_DIR} \
	    --strip

	_end_process
    }

    clone
    build
    install
}


function build_rustc_demangle
{
    RUSTC_DEMANGLE_SRC_DIR=${SRC_DIR}/rustc-demangle
    RUSTC_DEMANGLE_SRC_ROOT=${RUSTC_DEMANGLE_SRC_DIR}/rustc-demangle
    RUSTC_DEMANGLE_INSTALL_DIR=${INSTALL_DIR}/rustc-demangle
    export RUSTC_DEMANGLE_INSTALL_DIR
    
    function clone_and_build
    {
	_begin_process ${RUSTC_DEMANGLE_SRC_DIR} || return 0
	git clone https://github.com/rust-lang/rustc-demangle.git ${RUSTC_DEMANGLE_SRC_ROOT}
	cd ${RUSTC_DEMANGLE_SRC_ROOT}
	cargo build -p rustc-demangle-capi --release
	_end_process
    }

    function install
    {
	_begin_process ${RUSTC_DEMANGLE_INSTALL_DIR} || return 0
	mkdir -p ${RUSTC_DEMANGLE_INSTALL_DIR}
	cp ${RUSTC_DEMANGLE_SRC_ROOT}/target/release/librustc_demangle.so ${RUSTC_DEMANGLE_INSTALL_DIR}
	_end_process
    }

    clone_and_build
    install
}


function install_dmd
{
    DMD_VERSION=${1:-2.103.0}

    DMD_ARCHIVE_DIR=${SRC_DIR}/dmd
    DMD_INSTALL_DIR=${INSTALL_DIR}/dmd
    DMD_BIN_DIR=${DMD_INSTALL_DIR}/dmd2/linux/bin64
    export PATH=${DMD_BIN_DIR}:${PATH}


    function download
    {
	_begin_process ${DMD_ARCHIVE_DIR} || return 0

	_create_and_cd ${DMD_ARCHIVE_DIR}
	curl -L -O https://downloads.dlang.org/releases/2.x/${DMD_VERSION}/dmd.${DMD_VERSION}.linux.tar.xz

	_end_process
    }

    function install
    {
	_begin_process ${DMD_INSTALL_DIR} || return 0

	_create_and_cd ${DMD_INSTALL_DIR}
	tar xvf ${DMD_ARCHIVE_DIR}/dmd.${DMD_VERSION}.linux.tar.xz

	_end_process
    }

    download
    install
}


function build_d_demangler
{
    D_DEMANGLER_SRC_DIR=${SRC_DIR}/rustc-demangle
    D_DEMANGLER_SRC_ROOT=${SRC_DIR}/rustc-demangle
    D_DEMANGLER_INSTALL_DIR=${INSTALL_DIR}/rustc-demangle
    export D_DEMANGLER_INSTALL_DIR
    
    function clone_and_build
    {
	_begin_process ${D_DEMANGLER_SRC_DIR} || return 0

	_create_and_cd ${D_DEMANGLER_SRC_DIR}
	git clone https://github.com/lievenhey/d_demangler.git ${D_DEMANGLER_SRC_ROOT}
	cd ${D_DEMANGLER_SRC_ROOT}
	make 

	_end_process
    }

    function install
    {
	_begin_process ${D_DEMANGLER_INSTALL_DIR} || return 0

	mkdir -p ${D_DEMANGLER_INSTALL_DIR}
	cp ${D_DEMANGLER_SRC_ROOT}/libd_demangler.so ${D_DEMANGLER_INSTALL_DIR}

	_end_process
    }

    which dmd &>/dev/null || install_dmd
    clone_and_build
    install
}

function build_clazy
{
    CLAZY_VERSION=${1:-1.11}

    CLAZY_SRC_DIR=${SRC_DIR}/clazy
    CLAZY_GIT_DIR=${CLAZY_SRC_DIR}/clazy
    CLAZY_BUILD_DIR=${BUILD_DIR}/clazy
    CLAZY_INSTALL_DIR=${INSTALL_DIR}/clazy


    function clone
    {
	_begin_process ${CLAZY_SRC_DIR} || return 0
	git clone https://github.com/KDE/clazy.git ${CLAZY_GIT_DIR}
	_end_process
    }

    function build
    {
	_begin_process ${CLAZY_BUILD_DIR} || return 0

	cmake \
	    -G Ninja \
	    -S ${CLAZY_GIT_DIR} \
	    -B ${CLAZY_BUILD_DIR} \
	    -DCMAKE_INSTALL_PREFIX=${CLAZY_INSTALL_DIR} \
	    -DCMAKE_BUILD_TYPE=Release \
	    -DLLVM_ROOT=${LLVM_INSTALL_DIR}
	    
	cmake --build ${CLAZY_BUILD_DIR}
	_end_process
    }

    function install
    {
	_begin_process ${CLAZY_INSTALL_DIR} || return 0
	cmake --install ${CLAZY_BUILD_DIR}
	_end_process
    }

    clone
    build
    install
}


function build_qt_creator
{
    QTC_VERSION=${1:-10.0.0}

    
    QTC_SRC_DIR=${SRC_DIR}/qt-creator
    QTC_SRC_ROOT=${QTC_SRC_DIR}/qt-creator
    QTC_PATCH_DIR=${THIS_SCRIPT_DIR}/patch
    QTC_BUILD_DIR=${BUILD_DIR}/qt-creator
    QTC_INSTALL_DIR=${INSTALL_DIR}/qt-creator-${QTC_VERSION}



    function clone
    {
	_begin_process ${QTC_SRC_DIR} || return 0

	git clone \
	    --recursive \
	    -b v${QTC_VERSION} \
	    --depth 1 \
	    https://code.qt.io/qt-creator/qt-creator.git ${QTC_SRC_ROOT}
	
	cd ${QTC_SRC_ROOT}
	patch -p1 < ${QTC_PATCH_DIR}/0001-chore-cmake-add-centos-7-build-support.patch

	_end_process
    }


    function build
    {
	_begin_process ${QTC_BUILD_DIR} || return 0

	QT_VERSION=$(grep "qt/.*@" ${QTC_SRC_ROOT}/conanfile.txt | cut -c 4-8)
	QTC_CONAN_PROFILE_OPT="-pr:h centos7-gcc-10 -pr:b default"

	_create_and_cd ${QTC_BUILD_DIR}
	conan install ${QTC_SRC_ROOT} ${QTC_CONAN_PROFILE_OPT} -b
	rm -f ${QTC_BUILD_DIR}/Qt6*

	QT_BUILD_DIR=$(conan info ${QTC_SRC_ROOT} ${QTC_CONAN_PROFILE_OPT} -j --paths 2>/dev/null| \
            jq -r ".[]|select(.reference==\"qt/${QT_VERSION}\")|.build_folder")/build/Release

	QT_INSTALL_DIR=$(conan info ${QTC_SRC_ROOT} ${QTC_CONAN_PROFILE_OPT} -j --paths 2>/dev/null| \
            jq -r ".[]|select(.reference==\"qt/${QT_VERSION}\")|.package_folder")

	# regenerate Qt's cmake script in install dir
	cmake --install ${QT_BUILD_DIR}


	# use by qt-creator Find*.cmake script to found d_demangler and rustc_demangle
	export LIBRARY_PATH=${D_DEMANGLER_INSTALL_DIR}:${RUSTC_DEMANGLE_INSTALL_DIR}

	cmake \
	    -S ${QTC_SRC_ROOT} \
	    -B ${QTC_BUILD_DIR} \
	    -G Ninja \
	    -DCMAKE_BUILD_TYPE=Release \
	    -DCMAKE_PREFIX_PATH="${QTC_BUILD_DIR};${QT_INSTALL_DIR}" \
	    -DCMAKE_INSTALL_PREFIX="${QTC_INSTALL_DIR}" \
	    -DClang_DIR=${LLVM_INSTALL_DIR}/lib/cmake/clang
    
	cmake --build ${QTC_BUILD_DIR} 

	_end_process
    }

    function install
    {
	_begin_process ${QTC_INSTALL_DIR} || return 0

	QTC_FINAL_ARCHIVE_PATH=${QTC_INSTALL_DIR}.txz
	
	cmake --install ${QTC_BUILD_DIR} --strip
	cmake --install ${QTC_BUILD_DIR} --component Dependencies
	cp ${CLAZY_INSTALL_DIR}/bin/clazy-standalone ${QTC_INSTALL_DIR}/libexec/qtcreator/clang/bin
	cp ${CLAZY_INSTALL_DIR}/lib64/ClazyPlugin.so ${QTC_INSTALL_DIR}/libexec/qtcreator/clang/lib
	cp ${THIS_SCRIPT_DIR}/.profile_qt-creator.sh ${QTC_INSTALL_DIR}
	
	tar Jcvf ${QTC_FINAL_ARCHIVE_PATH} \
	    -C $(dirname ${QTC_INSTALL_DIR}) \
	    $(basename ${QTC_INSTALL_DIR})

	_end_process
    }

    clone
    build
    install
}


LLVM_VERSION=16.0.2
CLAZY_VERSION=1.11
DMD_VERSION=2.103.0
QTC_VERSION=10.0.0

export CONAN_COLOR_DARK=1

build_clang ${LLVM_VERSION}
build_rustc_demangle
install_dmd ${DMD_VERSION} 
build_d_demangler
build_clazy ${CLAZY_VERSION}
build_qt_creator ${QTC_VERSION}

mkdir -p /tmp/install
cp ${QTC_FINAL_ARCHIVE_PATH} /tmp/install

