
TAG=centos7-builder:latest

SCRIPT_DOCKER_VOLUME_OPT=-v $(CURDIR)/script:/tmp/script
INSTALL_DOCKER_VOLUME_OPT=-v $(CURDIR)/install:/tmp/install



build: Dockerfile
	docker build -t $(TAG) .

run:
	docker run -ti \
	$(SCRIPT_DOCKER_VOLUME_OPT) \
	$(INSTALL_DOCKER_VOLUME_OPT) \
	$(TAG)

run-dev:
	docker run -ti \
	$(SCRIPT_DOCKER_VOLUME_OPT) \
	$(INSTALL_DOCKER_VOLUME_OPT) \
	-v $(shell readlink -f ${SSH_AUTH_SOCK}):/ssh-agent \
	-e SSH_AUTH_SOCK=/ssh-agent \
	-v /tmp/centos7-build/ccache:/home/builder/.ccache \
	$(TAG) \
	bash
