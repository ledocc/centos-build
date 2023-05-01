
TAG=centos7-builder:latest


_build.done: Dockerfile
	docker build -t $(TAG) .
	touch _build.done

build: _build.done

run: build
	docker run -ti $(TAG)

run-dev:
	docker run -ti \
	-v $(CURDIR)/script:/tmp/script2 \
	-v $(shell readlink -f ${SSH_AUTH_SOCK}):/ssh-agent \
	-e SSH_AUTH_SOCK=/ssh-agent \
	$(TAG) \
	bash
