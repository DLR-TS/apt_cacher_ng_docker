SHELL:=/bin/bash

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=

DOCKER_VOLUME_NAME=apt-cacher-ng-cache
DOCKER_VOLUME_MOUNT_POINT=/var/cache/apt-cacher-ng

PROJECT="apt-cacher-ng"
VERSION="latest"
TAG="${PROJECT}:${VERSION}"

DOCKER_GID=$(shell getent group docker | cut -d: -f3)
UID := $(shell id -u)
GID := $(shell id -g)

DEFAULT_GOAL := build_apt_cacher_ng

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: create_docker_volume
create_docker_volume: ## creates the apt_cacher_ng cache docker volume
	docker volume create --name ${DOCKER_VOLUME_NAME}

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
up: ## start apt_cacher_ng service
	docker compose up --detach --no-recreate && echo "Apt-Cacher NG statistics dashboard is located at: http://127.0.0.1:3142/acng-report.html"
	@sleep 1s && make check_apt_cacher_service --no-print-directory

.PHONY: down
down: get_cache_statistics ## stop apt_cacher_ng service
	docker compose down

.PHONY: clean
clean: clean_apt_cacher_ng_cache

.PHONY: start_apt_cacher_ng
start_apt_cacher_ng: up## starts apt-cacher-ng service

.PHONY: stop_apt_cacher_ng
stop_apt_cacher_ng: down ## starts apt-cacher-ng service

.PHONY: clean_apt_cacher_ng_cache
clean_apt_cacher_ng_cache: ## clears the apt cacher ng apt cache
	docker volume rm ${DOCKER_VOLUME_NAME} || true

.PHONY: check_apt_cacher_service
check_apt_cacher_service: ## returns the status of the apt-cacher ng service
	@bash check_apt_cacher_service_status.sh

.PHONY: get_cache_statistics
get_cache_statistics:
	@bash get_cache_statistics.sh
