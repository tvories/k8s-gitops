#!/usr/bin/env bash
# Re-add the LAN to the cluster catalog zone's Zone Transfer ACL.
#
# tdns2 (k8s) pulls every catalogued zone from homebox over AXFR, and the pod's
# masqueraded traffic leaves from its node's 192.168.1.x LAN address (the
# on-link route beats the default). Technitium keeps dropping 192.168.1.0/24
# from this ACL, which freezes tdns2's serials and fires
# TechnitiumZoneSerialMismatch. Member zones inherit the catalog's ACL unless
# "Override Zone Transfer Option" is ticked on them.
#
# Runs every 20 minutes from the catalog-acl CronJob (TECHNITIUM_URL/TOKEN).
# By hand it falls back to the terraform env:
#   op run --env-file=.env_vars -- ./k8s/clusters/cluster-0/manifests/network/technitium/catalog-acl/fix-catalog-acl.sh
set -euo pipefail

url="${TECHNITIUM_URL:-${TF_VAR_technitium_url:?set TECHNITIUM_URL or TF_VAR_technitium_url}}"
token="${TECHNITIUM_TOKEN:-${TF_VAR_technitium_token:?set TECHNITIUM_TOKEN or TF_VAR_technitium_token}}"
catalog="cluster-catalog.cluster.t-vo.us"
node="tdns.cluster.t-vo.us" # the primary, which serves the transfers
lan="192.168.1.0/24"
members=(cluster.t-vo.us mcbadass.local 1.168.192.in-addr.arpa 83.168.192.in-addr.arpa)

api() {
    local endpoint="$1" resp
    shift
    local args=(--silent --show-error "${url%/}/api/${endpoint}" --data-urlencode "node=${node}")
    for kv in "$@"; do args+=(--data-urlencode "$kv"); done
    # Token goes in through a curl config on stdin so it never lands in argv.
    resp=$(printf 'data-urlencode = "token=%s"\n' "$token" | curl -K - "${args[@]}")
    if [[ $(jq -r .status <<<"$resp") != ok ]]; then
        echo "API ${endpoint} failed: $(jq -r '.errorMessage // .' <<<"$resp")" >&2
        exit 1
    fi
    printf '%s' "$resp"
}

show() {
    jq -r '.response | "  zoneTransfer=\(.zoneTransfer)  acl=\(.zoneTransferNetworkACL | join(","))  tsig=\(.zoneTransferTsigKeyNames // [] | join(","))"'
}

opts=$(api zones/options/get "zone=${catalog}")
echo "${catalog} before:"
show <<<"$opts"

if jq -e --arg lan "$lan" '.response.zoneTransferNetworkACL | index($lan)' <<<"$opts" >/dev/null; then
    echo "${lan} is already in the ACL; not changing anything."
else
    # Append, don't prepend: entries match in order, so any existing "!" deny stays in force.
    acl=$(jq -r --arg lan "$lan" '.response.zoneTransferNetworkACL + [$lan] | join(",")' <<<"$opts")
    api zones/options/set "zone=${catalog}" "zoneTransferNetworkACL=${acl}" >/dev/null
    echo "${catalog} after:"
    api zones/options/get "zone=${catalog}" | show
fi

case $(jq -r .response.zoneTransfer <<<"$opts") in
UseSpecifiedNetworkACL | AllowZoneNameServersAndUseSpecifiedNetworkACL | null) ;;
*) echo "WARNING: zoneTransfer mode ignores the ACL entirely; fix the mode in the UI." >&2 ;;
esac

# A member zone with its own override doesn't inherit the catalog ACL.
for zone in "${members[@]}"; do
    api zones/options/get "zone=${zone}" |
        jq -r --arg z "$zone" --arg lan "$lan" '.response |
            if .overrideCatalogZoneTransfer and ((.zoneTransferNetworkACL // []) | index($lan) | not)
            then "WARNING: \($z) overrides the catalog transfer ACL and lacks \($lan)"
            else empty end' >&2
done

if command -v dig >/dev/null; then
    echo
    echo "SOA serials (homebox vs tdns2); transfers normally catch up within a minute, so rerun if they differ:"
    for zone in "${catalog}" "${members[@]}"; do
        printf '  %-36s %12s  %12s\n' "$zone" \
            "$(dig +short @192.168.1.243 "$zone" SOA | awk '{print $3}')" \
            "$(dig +short @192.168.83.241 "$zone" SOA | awk '{print $3}')"
    done
else
    echo "dig not found; skipping the SOA serial comparison (try: nix shell nixpkgs#dig)." >&2
fi
