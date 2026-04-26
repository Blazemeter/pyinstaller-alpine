REPOSITORY := gcr.io/verdant-bulwark-278/builder
COMPONENT := pyinstaller-alpine
VERSION_ALPINE := 3.18
VERSION_PYTHON := 3.12
VERSION_PYINSTALLER := 6.3.0

TARGET_BIN_DIR := /pyinstaller
DOCKER_TAG := "${REPOSITORY}/${COMPONENT}:${VERSION_PYTHON}_${VERSION_ALPINE}"

help:  ## Show this help.
	@tput bold; echo TARGETS; tput sgr0 && \
	grep '.*:[^#]*  ##.*' $(MAKEFILE_LIST) | grep -v '\bgrep\b' | sed -E "s/([^:]+):.*##(.*)$$/  $(shell tput bold)\1$(shell tput sgr0): \2/g" \
	| column -t -s ':'

build: Dockerfile  ## Build docker image
	time docker build --platform linux/amd64 -t ${DOCKER_TAG} \
		--build-arg VERSION_PYINSTALLER=${VERSION_PYINSTALLER} \
		--build-arg VERSION_ALPINE=${VERSION_ALPINE} \
		--build-arg VERSION_PYTHON=${VERSION_PYTHON} \
		--build-arg TARGET_BIN_DIR=${TARGET_BIN_DIR} \
		.

build-local: Dockerfile  ## Build docker image
	time docker build --platform linux/arm64 -t ${DOCKER_TAG} \
		--build-arg VERSION_PYINSTALLER=${VERSION_PYINSTALLER} \
		--build-arg VERSION_ALPINE=${VERSION_ALPINE} \
		--build-arg VERSION_PYTHON=${VERSION_PYTHON} \
		--build-arg TARGET_BIN_DIR=${TARGET_BIN_DIR} \
		.
push: build  ## Push docker images
	@docker push "${DOCKER_TAG}"
