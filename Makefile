# This file is managed via modulesync

DOCKER_IMAGE_TAG:=7
DOCKER_IMAGE=registry.icts.kuleuven.be/lnx/puppet-spec:$(DOCKER_IMAGE_TAG)
PWD=$(shell pwd)
UID=$(shell id -u)
GID=$(shell id -g)
BASE_DIR=$(shell git rev-parse --show-toplevel)
MODULE_NAME=$(shell basename "$(BASE_DIR)")
GITROOT=$(shell git rev-parse --show-toplevel)
ifeq ($(GITROOT),)
GITROOT=$(shell dirname "$(PWD)")
endif
ifneq (,$(wildcard /usr/bin/docker-ssh))
        DOCKER_BIN:=docker-ssh run -v '$(GITROOT)/librarian-git-config':/etc/gitconfig:ro
else ifneq ($(NOMAD_TASK_NAME),)
        DOCKER_BIN:=docker run -v $$WORKSPACE/.netrc:/home/.netrc:ro
else
        DOCKER_BIN:=docker run -v '$(GITROOT)/librarian-git-config':/etc/gitconfig:ro -v '$(SSH_AUTH_SOCK):$(SSH_AUTH_SOCK)' -e 'SSH_AUTH_SOCK=$(SSH_AUTH_SOCK)'
endif
DOCKER_CMD=$(DOCKER_BIN) -t --rm -e GIT_COMMITTER_NAME=icts -e GIT_COMMITTER_EMAIL=icts@kuleuven.be -w /data/$(MODULE_NAME) -v "$(PWD)":/data/$(MODULE_NAME) $(DOCKER_PARAMS) $(DOCKER_IMAGE)
PULL_IMAGE:=yes

pull:
ifeq ($(PULL_IMAGE),yes)
	-docker pull $(DOCKER_IMAGE) >/dev/null
endif

tasks: pull
	$(DOCKER_CMD) rake -T

strings: pull
	$(DOCKER_CMD) rake strings:generate

validate: pull
	$(DOCKER_CMD) rake validate

spec: pull
	$(DOCKER_CMD) rake spec

test: pull
	$(DOCKER_CMD) rake test

fix-lint:
	@$(MAKE) lint DOCKER_PARAMS="-e PUPPET_LINT_FIX=yes"

lint: pull
	$(DOCKER_CMD) rake lint

debug:
	$(DOCKER_CMD) bash

acceptance: pull
	$(DOCKER_CMD) rake acceptance DOCKER_HOST=tcp://172.17.0.1:4243

acceptance-debug:
	$(DOCKER_CMD) rake acceptance DOCKER_HOST=tcp://172.17.0.1:4243 RS_DESTROY=no

acceptance-local:
	$(DOCKER_CMD) rake acceptance DOCKER_HOST=tcp://172.17.0.1:4243 DOCKER_BUILDARGS="http_proxy=http://172.17.0.1:8118 https_proxy=http://172.17.0.1:8118"

acceptance-local-debug:
	$(DOCKER_CMD) rake acceptance DOCKER_HOST=tcp://172.17.0.1:4243 DOCKER_BUILDARGS="http_proxy=http://172.17.0.1:8118 https_proxy=http://172.17.0.1:8118" RS_DESTROY=no

contributors: pull
	$(DOCKER_CMD) rake contributors


# vim: syntax=make
