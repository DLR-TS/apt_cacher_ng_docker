SHELL:=/bin/bash

include apt_cacher_ng_docker.mk

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")
MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=

DOCKER_VOLUME_NAME=apt-cacher-ng-cache
DOCKER_VOLUME_MOUNT_POINT=/var/cache/apt-cacher-ng
DOCKER_VOLUME_MOUNT_POINT=${ROOT_DIR}/.cache

PROJECT="apt-cacher-ng"
VERSION="latest"
TAG="${PROJECT}:${VERSION}"

DOCKER_GID=$(shell getent group docker | cut -d: -f3)
UID := $(shell id -u)
GID := $(shell id -g)

DEFAULT_GOAL := help

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: create_docker_volume
create_docker_volume: ## creates the apt_cacher_ng cache docker volume
	mkdir -p "${DOCKER_VOLUME_MOUNT_POINT}"
	docker volume create --driver local \
      --opt type=none \
      --opt device=${DOCKER_VOLUME_MOUNT_POINT} \
      --opt o=bind \
      ${DOCKER_VOLUME_NAME}



.PHONY: build_apt_cacher_ng_consumer1_example
build_apt_cacher_ng_consumer1_example: ## builds a apt cacher consumer1 example
	docker build --network host --file Dockerfile.apt_cacher_ng_consumer1 .

.PHONY: build_apt_cacher_ng_consumer2_example
build_apt_cacher_ng_consumer2_example: ## builds a apt cacher consumer2 example
	source proxy.env; \
    docker build --network host \
                 --build-arg HTTP_PROXY="${HTTP_PROXY}" \
                 --build-arg HTTPS_PROXY="${HTTPS_PROXY}" \
                 --file Dockerfile.apt_cacher_ng_consumer2 .

.PHONY: up
up: create_docker_volume## start apt_cacher_ng service
	docker compose up --detach --no-recreate && echo "Apt-Cacher NG statistics dashboard is located at: http://127.0.0.1:3142/acng-report.html"
	@sleep 1s && make check_apt_cacher_service --no-print-directory

.PHONY: down
down: get_cache_statistics ## stop apt_cacher_ng service
	docker compose down

.PHONY: clean
clean: clean_apt_cacher_ng_cache
	docker rm $$(docker ps -a -q --filter "ancestor=${TAG}") 2> /dev/null || true
	docker rmi $$(docker images -q ${PROJECT}) 2> /dev/null || true

.PHONY: clean_apt_cacher_ng_cache
clean_apt_cacher_ng_cache: ## clears the apt cacher ng apt cache
	docker run -v ${DOCKER_VOLUME_MOUNT_POINT}:/var/cache/apt-cacher-ng -it apt-cacher-ng /bin/bash -c 'rm -rf /var/cache/apt-cacher-ng/*'
	docker run -v ${DOCKER_VOLUME_MOUNT_POINT}:/var/cache/apt-cacher-ng -it apt-cacher-ng /bin/bash -c 'ls -la /var/cache/apt-cacher-ng/ && pwd'
	docker volume rm ${DOCKER_VOLUME_NAME} 2> /dev/null || true
	rm -rf "${DOCKER_VOLUME_MOUNT_POINT}" || true

