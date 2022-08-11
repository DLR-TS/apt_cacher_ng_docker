#!/usr/bin/env sh

url='http://host.docker.internal:3142/'
status=$(curl --silent \
              --output /dev/null \
              --head \
              --location \
              --connect-timeout 5 \
              --fail \
              --write-out %{http_code} ${url}
        )

case $status in
  (40*) echo "Apt-Cacher service is: UP";;
  (*) echo "Apt-Cacher service is: DOWN start it with 'make start_apt_cacher_ng'" && exit 1;;
esac

