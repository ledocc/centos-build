
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))
top_level_dir := $(shell realpath $(mkfile_dir)/..)

CACHE_DIR=$(top_level_dir)/.cache


IMAGE_NAME=centos7-builder
CENTOS_7_7_TAG=7.7.1908
CENTOS_7_9_TAG=7.9.2009

CENTOS_VERSION=7.9
CENTOS_VERSION_UNDERSCORE=$(shell echo ${CENTOS_VERSION}|tr . _)

IMAGE_TAG=$(CENTOS_$(CENTOS_VERSION_UNDERSCORE)_TAG)

SCRIPT_DOCKER_VOLUME_OPT=-v $(top_level_dir)/script:/tmp/script
INSTALL_DOCKER_VOLUME_OPT=-v $(top_level_dir)/archive:/tmp/archive

HOST_CCACHE_DIR=$(CACHE_DIR)/ccache
HOST_CONAN_CACHE_DIR=$(CACHE_DIR)/conan_cache


build: Dockerfile
	docker build --build-arg CENTOS_VERSION=$(IMAGE_TAG) -t $(IMAGE_NAME):$(IMAGE_TAG) .

create_volume_dir:
	mkdir -p $(top_level_dir)/archive
	mkdir -p $(HOST_CCACHE_DIR)
	mkdir -p $(HOST_CONAN_CACHE_DIR)

run: create_volume_dir
	docker run -ti \
	$(SCRIPT_DOCKER_VOLUME_OPT) \
	$(INSTALL_DOCKER_VOLUME_OPT) \
	$(IMAGE_NAME):$(IMAGE_TAG)


run-dev: create_volume_dir
	mkdir -p $(HOST_CCACHE_DIR)
	docker run -ti \
	$(SCRIPT_DOCKER_VOLUME_OPT) \
	$(INSTALL_DOCKER_VOLUME_OPT) \
	-v $(shell readlink -f ${SSH_AUTH_SOCK}):/ssh-agent \
	-e SSH_AUTH_SOCK=/ssh-agent \
	-v $(HOST_CCACHE_DIR):/home/builder/.ccache \
	-v $(HOST_CONAN_CACHE_DIR):/home/builder/.conan \
	$(IMAGE_NAME):$(IMAGE_TAG) \
	bash
