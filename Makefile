.PHONY: help build clean push_images create_manifest build_amd64 build_arm64 build_armv6 build_armv7 build_ppc64le build_s390x
.DEFAULT_GOAL := help

SHELL = /bin/sh
BUILD_DIR = build

ARCHITECTURES = amd64 arm64 arm/v6 arm/v7 s390x ppc64le

BRANCH = $(shell git branch --show-current)

ifeq ($(BRANCH),main)
	IMAGE_TAG = latest
else
	IMAGE_TAG = $(BRANCH)
endif

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z0-9_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

help: ## Displays this message.
	@echo "Please use \`make <target>\` where <target> is one of:"
	@python3 -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: ## Cleans the build directory
	rm -rfv simh-master master.zip

master.zip:
	wget -c https://github.com/open-simh/simh/archive/refs/heads/master.zip

simh-master: master.zip
	unzip master.zip

build_amd64: simh-master ## Builds the Docker image for amd64
	docker build -t ${USER}/simh-base:${IMAGE_TAG}-amd64 --platform=linux/amd64 --file ./Dockerfile --progress plain .

build_arm64: simh-master ## Builds the Docker image for arm64
	docker build -t ${USER}/simh-base:${IMAGE_TAG}-arm64 --platform=linux/arm64 --file ./Dockerfile --progress plain .

build_armv6: simh-master ## Builds the Docker image for armv6
	docker build -t ${USER}/simh-base:${IMAGE_TAG}-armv6 --platform=linux/arm/v6 --file ./Dockerfile --progress plain .

build_armv7: simh-master ## Builds the Docker image for armv7
	docker build -t ${USER}/simh-base:${IMAGE_TAG}-armv7 --platform=linux/arm/v7 --file ./Dockerfile --progress plain .

build_ppc64le: simh-master ## Builds the Docker image for ppc64le
	docker build -t ${USER}/simh-base:${IMAGE_TAG}-ppc64le --platform=linux/ppc64le --file ./Dockerfile --progress plain .	

build_s390x: simh-master ## Builds the Docker image for s390x
	docker build -t ${USER}/simh-base:${IMAGE_TAG}-s390x --platform=linux/s390x --file ./Dockerfile --progress plain .

build: build_amd64 build_arm64 build_armv6 build_armv7 build_ppc64le build_s390x ## Builds the Docker images

push_images: build ## Uploads the local docker images
	docker image push ${USER}/simh-base:${IMAGE_TAG}-amd64
	docker image push ${USER}/simh-base:${IMAGE_TAG}-arm64
	docker image push ${USER}/simh-base:${IMAGE_TAG}-armv6
	docker image push ${USER}/simh-base:${IMAGE_TAG}-armv7
	docker image push ${USER}/simh-base:${IMAGE_TAG}-s390x
	docker image push ${USER}/simh-base:${IMAGE_TAG}-ppc64le

create_manifest: push_images ## Uploads the manifest
	docker manifest create ${USER}/simh-base:${IMAGE_TAG} \
		--amend ${USER}/simh-base:${IMAGE_TAG}-amd64 \
		--amend ${USER}/simh-base:${IMAGE_TAG}-arm64 \
		--amend ${USER}/simh-base:${IMAGE_TAG}-armv6 \
		--amend ${USER}/simh-base:${IMAGE_TAG}-armv7 \
		--amend ${USER}/simh-base:${IMAGE_TAG}-s390x \
		--amend ${USER}/simh-base:${IMAGE_TAG}-ppc64le
	docker manifest push ${USER}/simh-base:${IMAGE_TAG}
