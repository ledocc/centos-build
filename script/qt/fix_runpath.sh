#!/usr/bin/env bash

sudo yum -y install \
     chrpath \
     file \
     patchelf

function is_elf()
{
    local file_type=$(file -b $1 | cut -d " " -f 1)
    [[ ${file_type} == "ELF" ]]
}


function set_runpath()
{
    local file=$1
    local new_runpath=$2

    is_elf ${file} || return 1

    chrpath -r ${new_runpath} ${file} && return 0

    patchelf --remove-rpath ${file} || return 2
    patchelf --set-rpath ${new_runpath} ${file} || return 3
}


function set_runpath_on_dir()
{
    local dir=$1
    local new_runpath=$2

    for f in $(ls -d -1 ${dir}/*)
    do
	set_runpath ${f} ${new_runpath} 
    done
}
