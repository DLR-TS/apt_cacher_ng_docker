#!/usr/bin/env sh

printf "Auto-purging Apt cacher ng damaged packages...\n"
request="acng-report.html?abortOnErrors=aOe&byPath=bP&byChecksum=bS&truncNow=tN&incomAsDamaged=iad&purgeNow=pN&doExpire=Start+Scan+and%2For+Expiration&calcSize=cs&asNeeded=an#bottom"

url='http://127.0.0.1:3142/'
(curl --silent \
     --retry 2 \
     --retry-delay 1 \
     --retry-max-time 2 \
     --output /dev/null \
     --head \
     --location \
     --connect-timeout 5 \
     --fail \
     ${url}${request} & )

url='http://host.docker.internal:3142/'
(curl --silent \
     --retry 2 \
     --retry-delay 1 \
     --retry-max-time 2 \
     --output /dev/null \
     --head \
     --location \
     --connect-timeout 5 \
     --fail \
     ${url}${request} & )










