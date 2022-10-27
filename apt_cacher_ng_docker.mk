
ROOT_DIR=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")
apt_cacher_ng_docker.mk_MAKEFILE_PATH:= $(shell dirname "$(abspath "$(lastword $(MAKEFILE_LIST))")")


MAKEFLAGS += --no-print-directory

.PHONY: start_apt_cacher_ng
start_apt_cacher_ng: ## starts apt-cacher-ng service
	cd "${apt_cacher_ng_docker.mk_MAKEFILE_PATH}" && make up

.PHONY: stop_apt_cacher_ng
stop_apt_cacher_ng: ## starts apt-cacher-ng service
	cd "${apt_cacher_ng_docker.mk_MAKEFILE_PATH}" && make down

.PHONY: check_apt_cacher_service
check_apt_cacher_service: ## Returns the status of the apt-cacher ng service
	@cd ${apt_cacher_ng_docker.mk_MAKEFILE_PATH} && bash check_apt_cacher_service_status.sh

.PHONY: get_cache_statistics
get_cache_statistics: ## Returns the caching statistics of  apt cacher ng
	@cd ${apt_cacher_ng_docker.mk_MAKEFILE_PATH} && bash get_cache_statistics.sh
