#!/usr/bin/env sh


if [ -f /.dockerenv ]; then
    url='http://host.docker.internal:3142/'
else
    url='http://127.0.0.1:3142/'
fi

status=$(curl --silent \
              --retry 5 \
              --retry-all-errors \
              --retry-max-time 2 \
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

