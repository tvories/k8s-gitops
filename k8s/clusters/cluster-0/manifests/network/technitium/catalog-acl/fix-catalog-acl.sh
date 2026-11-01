#!/usr/bin/env bash
# Re-add the node subnets to the cluster catalog zone's Zone Transfer ACL.
#
# tdns2 (k8s) pulls every catalogued zone from homebox over AXFR, and the pod's
# traffic is masqueraded to its node's address. That used to be the node's
# 192.168.1.x LAN lease (on-link beat the default route); since the nodes lost
# their untagged LAN address (2026-10-31) it's their 192.168.80.x VLAN80
# address, routed through OPNsense. Technitium keeps rebuilding this ACL from
# the registered node IPs, dropping both subnets, which freezes tdns2's serials
# and fires TechnitiumZoneSerialMismatch. Member zones inherit the catalog's
# ACL unless "Override Zone Transfer Option" is ticked on them.
#
# Runs every 20 minutes from the catalog-acl CronJob (TECHNITIUM_URL/TOKEN).
# By hand it falls back to the terraform env:
#   op run --env-file=.env_vars -- ./k8s/clusters/cluster-0/manifests/network/technitium/catalog-acl/fix-catalog-acl.sh
set -euo pipefail

url="${TECHNITIUM_URL:-${TF_VAR_technitium_url:?set TECHNITIUM_URL or TF_VAR_technitium_url}}"
token="${TECHNITIUM_TOKEN:-${TF_VAR_technitium_token:?set TECHNITIUM_TOKEN or TF_VAR_technitium_token}}"
catalog="cluster-catalog.cluster.t-vo.us"
node="tdns.cluster.t-vo.us" # the primary, which serves the transfers
# VLAN80 is where transfers come from now. 192.168.1.0/24 stays until no node
# holds a LAN lease (m720q-1 kept one longest); drop it after that.
nets=(192.168.80.0/24 192.168.1.0/24)
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

wanted=$(printf '%s\n' "${nets[@]}" | jq -R . | jq -s .)
missing=$(jq -c --argjson w "$wanted" '[$w[] as $n | select(.response.zoneTransferNetworkACL | index($n) | not) | $n]' <<<"$opts")
if [[ $missing == "[]" ]]; then
    echo "${nets[*]} already in the ACL; not changing anything."
else
    echo "adding missing: $(jq -r 'join(" ")' <<<"$missing")"
    # Append, don't prepend: entries match in order, so any existing "!" deny stays in force.
    acl=$(jq -r --argjson m "$missing" '.response.zoneTransferNetworkACL + $m | join(",")' <<<"$opts")
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
        jq -r --arg z "$zone" --argjson w "$wanted" '.response | . as $r |
            if .overrideCatalogZoneTransfer
            then $w[] | select(($r.zoneTransferNetworkACL // []) | index(.) | not)
                | "WARNING: \($z) overrides the catalog transfer ACL and lacks \(.)"
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
