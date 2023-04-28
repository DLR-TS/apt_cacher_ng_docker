
ifeq ($(filter apt_cacher_ng_docker.mk, $(notdir $(MAKEFILE_LIST))), apt_cacher_ng_docker.mk)

MAKEFLAGS += --no-print-directory

APT_CACHER_NG_DOCKER_MAKEFILE_PATH:=$(shell realpath "$(shell dirname "$(lastword $(MAKEFILE_LIST))")")

.EXPORT_ALL_VARIABLES:
DOCKER_CONFIG:=${APT_CACHER_NG_DOCKER_MAKEFILE_PATH}

.PHONY: start_apt_cacher_ng
start_apt_cacher_ng: _start_apt_cacher_ng check_apt_cacher_service ## Starts the apt-cacher-ng service, same as `up`

.PHONY: stop_apt_cacher_ng
stop_apt_cacher_ng: get_cache_statistics _stop_apt_cacher_ng ## Stops the apt-cacher-ng service, same as `down`

.PHONY: _start_apt_cacher_ng
_start_apt_cacher_ng:
	cd "${APT_CACHER_NG_DOCKER_MAKEFILE_PATH}" && \
	make up

.PHONY: _stop_apt_cacher_ng
_stop_apt_cacher_ng:
	cd "${APT_CACHER_NG_DOCKER_MAKEFILE_PATH}" && make down

.PHONY: clean_apt_cacher_ng_cache
clean_apt_cacher_ng_cache: ## Clears/deletes the apt cacher ng apt cache
	cd "${APT_CACHER_NG_DOCKER_MAKEFILE_PATH}" && make _clean_apt_cacher_ng_cache 

.PHONY: check_apt_cacher_service
check_apt_cacher_service: ## Returns the status of the apt-cacher ng service
	@cd ${APT_CACHER_NG_DOCKER_MAKEFILE_PATH} && bash check_apt_cacher_service_status.sh
	@cd ${APT_CACHER_NG_DOCKER_MAKEFILE_PATH} && bash purge_apt_cacher_damaged_packages.sh 

.PHONY: get_cache_statistics
get_cache_statistics: ## Returns the caching statistics of  apt cacher ng
	@cd ${APT_CACHER_NG_DOCKER_MAKEFILE_PATH} && bash get_cache_statistics.sh

endif
