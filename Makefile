
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))

CACHE_DIR=$(mkfile_dir)/.cache

TAG=centos7-builder:latest

SCRIPT_DOCKER_VOLUME_OPT=-v $(mkfile_dir)/script:/tmp/script
INSTALL_DOCKER_VOLUME_OPT=-v $(mkfile_dir)/install:/tmp/install

HOST_CCACHE_DIR=$(CACHE_DIR)/ccache
HOST_CONAN_CACHE_DIR=$(CACHE_DIR)/conan_cache

build: Dockerfile
	docker build -t $(TAG) .

run:
	docker run -ti \
	$(SCRIPT_DOCKER_VOLUME_OPT) \
	$(INSTALL_DOCKER_VOLUME_OPT) \
	$(TAG)


run-dev:
	mkdir -p $(HOST_CCACHE_DIR)
	docker run -ti \
	$(SCRIPT_DOCKER_VOLUME_OPT) \
	$(INSTALL_DOCKER_VOLUME_OPT) \
	-v $(shell readlink -f ${SSH_AUTH_SOCK}):/ssh-agent \
	-e SSH_AUTH_SOCK=/ssh-agent \
	-v $(HOST_CCACHE_DIR):/home/builder/.ccache \
	-v $(HOST_CONAN_CACHE_DIR):/home/builder/.conan \
	$(TAG) \
	bash
