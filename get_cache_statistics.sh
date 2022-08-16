#!/usr/bin/env bash

function echoerr { echo "$@" >&2; exit 1;}
SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"


if [ -f /.dockerenv ]; then
    url='http://host.docker.internal:3142/'
else
    url='http://127.0.0.1:3142/'
fi

cache_statistics=$(curl --silent "${url}/acng-report.html?doCount=Count+Data#stats" | \
                   sed -e "s|<td|\n<td|g" | \
                   grep td | \
                   grep colcont | \
                   grep -v style | \
                   sed -n 's:.*<td.*>\(.*\)</td>.*:\1:p'
                  )

#echo -n "${cache_statistics}"

#IFS=$'\n' readarray -t cache_datetime cache_requests_hits cache_requests_misses cache_requests_total cache_data_hits cache_data_misses cache_data_total <<< $cache_statistics
IFS=$'\n' read -ra cache_statistics -d $'\0' <<< "$cache_statistics"
#cache_datetime=$(cut -d'\n' -f1 <<< "$cache_statistics")
#cache_requests_hits=$(cut -d'\n' -f1 <<< "$cache_statistics")
#cache_requests_misses=$(cut -d'\n' -f1 <<< "$cache_statistics")
#cache_requests_total=$(cut -d'\n' -f1 <<< "$cache_statistics")
#cache_data_hits=$(cut -d'\n' -f1 <<< "$cache_statistics")
#cache_data_misses=$(cut -d'\n' -f1 <<< "$cache_statistics")
#cache_data_total=$(cut -d'\n' -f1 <<< "$cache_statistics")


cache_datetime="${cache_statistics[0]}"
cache_request_hits="${cache_statistics[1]}"
cache_request_misses="${cache_statistics[2]}"
cache_request_total="${cache_statistics[3]}"
cache_data_hits="${cache_statistics[4]}"
cache_data_misses="${cache_statistics[5]}"
cache_data_total="${cache_statistics[6]}"

echo "APT Cacher NG"

if [[ "${cache_datetime}" == "" ]]; then
    echo "    no cache recorded"
else
    printf "  Cache statistics(request hits, request misses, total requests, data hits, data misses, total data): \n                  (%s, %s, %s, %s, %s, %s)" \
    "${cache_request_hits}" "${cache_request_misses}" "${cache_request_total}" "${cache_data_hits}" "${cache_data_misses}" "${cache_data_total}"
fi
echo ""
