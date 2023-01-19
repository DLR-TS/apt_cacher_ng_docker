#!/usr/bin/env sh


if [ -f /.dockerenv ]; then
    url='http://host.docker.internal:3142/'
else
    url='http://127.0.0.1:3142/'
fi

## curl 'http://127.0.0.1:3142/acng-report.html?abortOnErrors=aOe&incomAsDamaged=iad&justRemoveDamaged=Delete+damaged&calcSize=cs&asNeeded=an#bottom' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:108.0) Gecko/20100101 Firefox/108.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'Connection: keep-alive' -H 'Referer: http://127.0.0.1:3142/acng-report.html' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1'

## curl 'http://127.0.0.1:3142/acng-report.html?abortOnErrors=aOe&byPath=bP&byChecksum=bS&incomAsDamaged=iad&justRemoveDamaged=Delete+damaged&calcSize=cs&asNeeded=an#bottom' -H 'User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:108.0) Gecko/20100101 Firefox/108.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'Connection: keep-alive' -H 'Referer: http://127.0.0.1:3142/acng-report.html' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1'

status=$(curl --silent \
              -H "Referer: ${url}/acng-report.html" \
              --retry 5 \
              --retry-max-time 2 \
              --output /dev/null \
              --head \
              --location \
              --connect-timeout 5 \
              --fail \
              --write-out %{http_code} ${url} \
              "${url}/acng-report.html?abortOnErrors=aOe&byPath=bP&byChecksum=bS&incomAsDamaged=iad&justRemoveDamaged=Delete+damaged&calcSize=cs&asNeeded=an#bottom"
        )

case $status in
  (40*) echo "Purged apt cacher ng damaged packages.";;
  (*) echo "Apt-Cacher service is DOWN, cannot purge damaged packages." && exit 1;;
esac

