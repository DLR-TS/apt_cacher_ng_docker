
ifndef APT_CACHER_NG_DOCKER_MAKEFILE_PATH 

MAKEFLAGS += --no-print-directory

APT_CACHER_NG_DOCKER_MAKEFILE_PATH:=$(shell realpath "$(shell dirname "$(lastword $(MAKEFILE_LIST))")")


MAKEFLAGS += --no-print-directory

.PHONY: start_apt_cacher_ng
start_apt_cacher_ng: ## starts apt-cacher-ng service
	cd "${APT_CACHER_NG_DOCKER_MAKEFILE_PATH}" && make up

.PHONY: stop_apt_cacher_ng
stop_apt_cacher_ng: ## starts apt-cacher-ng service
	cd "${APT_CACHER_NG_DOCKER_MAKEFILE_PATH}" && make down

.PHONY: check_apt_cacher_service
check_apt_cacher_service: ## Returns the status of the apt-cacher ng service
	@cd ${APT_CACHER_NG_DOCKER_MAKEFILE_PATH} && bash check_apt_cacher_service_status.sh

.PHONY: get_cache_statistics
get_cache_statistics: ## Returns the caching statistics of  apt cacher ng
	@cd ${APT_CACHER_NG_DOCKER_MAKEFILE_PATH} && bash get_cache_statistics.sh

endif
