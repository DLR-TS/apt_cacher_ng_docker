#!/usr/bin/env sh

url='http://127.0.0.1:3142/'
status=$(curl --silent \
              --retry 2 \
              --retry-delay 1 \
              --retry-max-time 2 \
              --output /dev/null \
              --head \
              --location \
              --connect-timeout 5 \
              --fail \
              --write-out %{http_code} ${url}
        )

case $status in
  (40*) echo "Apt-Cacher service is: UP" && exit 0;;
esac

url='http://host.docker.internal:3142/'
status=$(curl --silent \
              --retry 2 \
              --retry-delay 1 \
              --retry-max-time 2 \
              --output /dev/null \
              --head \
              --location \
              --connect-timeout 5 \
              --fail \
              --write-out %{http_code} ${url}
        )

case $status in
  (40*) echo "Apt-Cacher service is: UP" && exit 0;;
  (*) echo "Apt-Cacher service is: DOWN start it with 'make start_apt_cacher_ng'" && exit 1;;
esac
