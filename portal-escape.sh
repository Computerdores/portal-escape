#!/usr/bin/env bash

# prepare logger
function log() {
    logger -s -t portal-escape "$@"
}

log "portal-escape.sh called with '$1' '$2' '$CONNECTIVITY_STATE'"

# exit if wrong event / network state
if [ "$2" != "connectivity-change" ] || [ "$CONNECTIVITY_STATE" != "PORTAL" ]; then
    exit
fi

log "captive portal present - acting"

# disable VPNs to prevent IP collision and make sure they are reenabled on exit
WGQ_UNITS=$(systemctl list-units --state=active 'wg-quick-*' --no-legend | awk '{print $1}')
function reenable_wg-quick() {
    for unit in $WGQ_UNITS; do
        systemctl start $unit
        log "reenabled $unit"
    done
}
trap 'reenable_wg-quick' EXIT
for unit in $WGQ_UNITS; do
    systemctl stop $unit
    log "disabled $unit"
done

# detect type of portal
DETECT_URL="http://detectportal.firefox.com/canonical.html"
read HTTP_CODE REDIRECT_URL <<<"$(curl -so /dev/null -w '%{http_code} %{redirect_url}' $DETECT_URL)"
log "Got: $HTTP_CODE with loc '$REDIRECT_URL' on $DETECT_URL"

if [ "$HTTP_CODE" -ne 302 ]; then
    log "ERROR: HTTP code $HTTP_CODE can't be handled!"
    exit
fi

# answer according to detected type
case "$REDIRECT_URL" in
    https://wifi.bahn.de*)
        # TODO: final test
        curl -X POST 'https://wifi.bahn.de/cna/logon'
        ;;
    http://login.wifionice.de/cna/*)
        # TODO: below is original command and simplified command; test that simplified works
        # curl 'https://login.wifionice.de/cna/logon' -X POST -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:144.0) Gecko/20100101 Firefox/144.0' -H 'Accept: */*' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br, zstd' -H 'Content-type: application/json' -H 'X-Requested-With: XMLHttpRequest' -H 'X-Csrf-Token: csrf' -H 'X-Reserve-Id: 1' -H 'Origin: https://login.wifionice.de' -H 'Connection: keep-alive' -H 'Referer: https://login.wifionice.de/cna/' -H 'Sec-Fetch-Dest: empty' -H 'Sec-Fetch-Mode: cors' -H 'Sec-Fetch-Site: same-origin' -H 'DNT: 1' -H 'Sec-GPC: 1' -H 'Priority: u=0' -H 'TE: trailers' --data-raw '{}'
        curl -X POST 'https://login.wifionice.de/cna/logon'
        ;;
    *)
        log "ERROR: unknown captive portal type"
        ;;
esac

