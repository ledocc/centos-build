
TAG=centos7-builder:latest

SCRIPT_DOCKER_VOLUME_OPT=-v $(CURDIR)/script:/tmp/script
INSTALL_DOCKER_VOLUME_OPT=-v $(CURDIR)/install:/tmp/install

HOST_CCACHE_DIR=/tmp/centos7-build/ccache

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
	$(TAG) \
	bash
