.PHONY: help build clean push_images create_manifest build_amd64 build_arm64 build_armv6 build_armv7 build_ppc64le build_s390x
.DEFAULT_GOAL := help
.NOTPARALLEL:

SHELL = /bin/sh
BUILD_DIR = build
DOCKER_IMAGE ?= $(USER)/simh-base
ARCHITECTURES = amd64 arm64 arm/v6 arm/v7 s390x ppc64le

#PROVENANCE_FLAG = --provenance false
PROVENANCE_FLAG = 

BRANCH = $(shell git branch --show-current)

# Verify required tools are installed
REQUIRED_BINS := docker wget unzip
$(foreach bin,$(REQUIRED_BINS),\
    $(if $(shell command -v $(bin) 2> /dev/null),,$(error Please install `$(bin)`)))

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
	@rm -rfv simh-master master.zip

master.zip: ## Downloads the SIMH source code
	@echo "Downloading SIMH source code..."
	@wget -c https://github.com/open-simh/simh/archive/refs/heads/master.zip || \
		(echo "Failed to download source code"; exit 1)
	@touch master.zip

simh-master: master.zip
	@echo "Extracting source code..."
	@unzip -o master.zip || (echo "Failed to extract archive"; exit 1)
	@touch simh-master

build_amd64: simh-master ## Builds the Docker image for amd64
	docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG}-amd64 --platform=linux/amd64 ${PROVENANCE_FLAG} --file ./Dockerfile --progress plain .

build_arm64: simh-master ## Builds the Docker image for arm64
	docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG}-arm64 --platform=linux/arm64 ${PROVENANCE_FLAG} --file ./Dockerfile --progress plain .

build_armv6: simh-master ## Builds the Docker image for armv6
	docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG}-armv6 --platform=linux/arm/v6 ${PROVENANCE_FLAG} --file ./Dockerfile --progress plain .

build_armv7: simh-master ## Builds the Docker image for armv7
	docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG}-armv7 --platform=linux/arm/v7 ${PROVENANCE_FLAG} --file ./Dockerfile --progress plain .

build_ppc64le: simh-master ## Builds the Docker image for ppc64le
	docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG}-ppc64le --platform=linux/ppc64le ${PROVENANCE_FLAG} --file ./Dockerfile --progress plain .	

build_s390x: simh-master ## Builds the Docker image for s390x
	docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG}-s390x --platform=linux/s390x ${PROVENANCE_FLAG} --file ./Dockerfile --progress plain .

build: $(addprefix build_,$(subst /,,${ARCHITECTURES})) ## Builds Docker images for all architectures

push_images: build ## Uploads the local docker images
	@for arch in $(subst /,,${ARCHITECTURES}); do \
		echo "Pushing ${DOCKER_IMAGE}:${IMAGE_TAG}-$$arch"; \
		docker image push ${DOCKER_IMAGE}:${IMAGE_TAG}-$$arch || exit 1; \
	done

push_manifest: push_images ## Creates and uploads the manifest
	@echo "Creating manifest for ${DOCKER_IMAGE}:${IMAGE_TAG}"
	docker manifest create ${DOCKER_IMAGE}:${IMAGE_TAG} \
		$(foreach arch,$(subst /,,${ARCHITECTURES}),--amend ${DOCKER_IMAGE}:${IMAGE_TAG}-$(arch))
	docker manifest push ${DOCKER_IMAGE}:${IMAGE_TAG}
