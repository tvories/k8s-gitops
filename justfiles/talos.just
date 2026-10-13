# Talos machine-config tooling. Replaces talhelper (archived) with plain
# `talosctl machineconfig patch` over Jinja templates, secrets from 1Password.
# Modelled on bjw-s-labs/home-ops kubernetes/talos/mod.just.
#
# Render order (later layers win):
#   cluster.yaml.j2 -> controlplane|worker.yaml.j2 -> nodes/<role>/<node>.yaml.j2
# then `op inject` swaps op://k8s/talos/* references for real values.
#
# Node arguments are the short Kubernetes node names (m720q-1 ... m720q-4);
# they resolve via the mcbadass.local search domain.

# Modules don't inherit the root justfile's settings.
set quiet
set shell := ['bash', '-euo', 'pipefail', '-c']

talos_dir := source_directory() / ".." / "k8s/clusters/cluster-0/talos"

# Recipes may run without direnv (e.g. from an agent shell), so don't rely on
# .envrc; fall back to the repo's talosconfig.
export TALOSCONFIG := env("TALOSCONFIG", talos_dir / "clusterconfig/talosconfig")

[private]
default:
    @just --list talos

# Render a node's full machine config to stdout (contains secrets — pipe it,
# don't redirect it into the repo).
[doc('Render the machine config for a node')]
render-config node:
    just talos render "{{ node }}" inject

# Same as render-config, but every op:// reference becomes the placeholder
# cmVkYWN0ZWQ= ("redacted" in base64 — talosctl decodes cert fields while
# merging, so a literal op:// string would not parse). Safe to print; used to
# review template changes without touching 1Password.
[doc('Render a node config with secrets replaced by a placeholder')]
render-raw node:
    just talos render "{{ node }}" placeholder

# Each layer is templated AND secret-resolved before `machineconfig patch`
# merges them: talosctl validates cert fields during the merge, so injection
# cannot happen afterwards.
[private]
render node mode:
    #!/usr/bin/env bash
    set -euo pipefail
    role="$(just talos node-role "{{ node }}")"
    vars=(-D "schematic=$(just talos schematic-id)" -D "talos_version=$(just talos talos-version)" -D "k8s_version=$(just talos k8s-version)")
    layer() {
        local out bad
        # --autoescape none: minijinja otherwise picks escaping from the file
        # extension and YAML-quotes every value (kubelet:"v1.35.6").
        # --strict: an undefined variable is an error, not an empty string.
        out="$(minijinja-cli --autoescape none --strict "$1" "${vars[@]}")"
        # op inject scans raw text (comments too) and rejects any op:// that
        # isn't a full vault/item/FIELD reference. Check here so render-raw
        # catches it as well, not just a live render.
        bad="$(grep -noE 'op://[^[:space:]"'"'"']*' <<<"$out" | grep -vE ':op://k8s/talos/[A-Z_]+$' || true)"
        if [[ -n "$bad" ]]; then
            echo "Malformed 1Password reference in $(basename "$1") (line:ref): $bad" >&2
            return 1
        fi
        if [[ "{{ mode }}" == inject ]]; then
            op inject <<<"$out"
        else
            sed -E 's#op://k8s/talos/[A-Z_]+#cmVkYWN0ZWQ=#g' <<<"$out"
        fi
    }
    talosctl machineconfig patch \
        <(layer "{{ talos_dir }}/cluster.yaml.j2") \
        -p @<(layer "{{ talos_dir }}/${role}.yaml.j2") \
        -p @<(layer "{{ talos_dir }}/nodes/${role}/{{ node }}.yaml.j2")

# Shows what applying would change, without changing anything. Run this before
# every apply-node; after the talhelper migration it should report no changes
# (beyond the documented eno1 MTU fix on m720q-2/3 and the etcd-defrag role).
[doc('Dry-run: show what applying the rendered config to a node would change')]
diff-node node:
    just talos render-config "{{ node }}" | talosctl -n "{{ node }}" apply-config --dry-run -f /dev/stdin

[confirm('Apply Talos config to this node? [y/N]')]
[doc('Apply the rendered config to a node (pass --mode=... to override auto)')]
apply-node node *args:
    just talos render-config "{{ node }}" | talosctl -n "{{ node }}" apply-config -f /dev/stdin {{ args }}

[confirm('Upgrade this node to the version in version.yaml? [y/N]')]
[doc('Upgrade Talos on a node to version.yaml + schematic.yaml')]
upgrade-node node *args:
    #!/usr/bin/env bash
    set -euo pipefail
    image="$(just talos machine-image)"
    echo "Upgrading {{ node }} to ${image}"
    # Image Factory builds an installer the first time a version+schematic pair
    # is requested, so the first node of an upgrade can sit silent for a minute
    # or more before talosctl shows progress. Later nodes hit the cache.
    echo "(First node of a new version can be silent for a minute or two while the factory builds the image.)"
    talosctl -n "{{ node }}" upgrade --image "${image}" --timeout=10m {{ args }}

# Bump k8s_version in version.yaml FIRST: upgrade-k8s reads it, and it also
# rewrites the image tags in every node's machine config — so afterwards the
# templates and the nodes agree and `diff-node` stays clean. Run with
# --dry-run first to preview every image/manifest change.
[confirm('Upgrade Kubernetes to the version in version.yaml? [y/N]')]
[doc('Upgrade Kubernetes to version.yaml (pass --dry-run to preview)')]
upgrade-k8s *args:
    talosctl -n m720q-1 upgrade-k8s --to "$(just talos k8s-version)" {{ args }}

# The `talhelper genurl installer|iso` replacement. The schematic ID is a
# content hash of schematic.yaml (same extensions -> same ID, independent of
# Talos version); the version comes from version.yaml.
[doc('Show the schematic ID and the factory installer/ISO URLs (talhelper genurl)')]
image-urls:
    #!/usr/bin/env bash
    set -euo pipefail
    version="$(just talos talos-version)"
    schematic="$(just talos schematic-id)"
    echo "Talos version: ${version}"
    echo "Schematic ID:  ${schematic}"
    echo "Installer:     factory.talos.dev/metal-installer/${schematic}:${version}"
    echo "ISO:           https://factory.talos.dev/image/${schematic}/${version}/metal-amd64.iso"

[doc('Download a Talos ISO for the current schematic (for re-imaging a node)')]
download-image:
    #!/usr/bin/env bash
    set -euo pipefail
    version="$(just talos talos-version)"
    schematic="$(just talos schematic-id)"
    curl -fL --retry 5 --progress-bar \
        -o "{{ talos_dir }}/talos-${version}-${schematic:0:8}.iso" \
        "https://factory.talos.dev/image/${schematic}/${version}/metal-amd64.iso"
    echo "Downloaded talos-${version}-${schematic:0:8}.iso (git-ignore it, don't commit)"

# --- Client configs (talhelper genconfig used to write both) -----------------
# Both land in clusterconfig/ (git-ignored). Client certs last ~1 year:
# check with `yq -r '.contexts[].crt' <file> | base64 -d | openssl x509 -noout -enddate`.

# Admin kubeconfig, issued by the cluster through the Talos API. Needs a working
# talosconfig.
[confirm('Replace clusterconfig/kubeconfig with a freshly issued admin kubeconfig? [y/N]')]
[doc('Fetch a fresh admin kubeconfig into clusterconfig/kubeconfig')]
kubeconfig:
    talosctl -n m720q-1 kubeconfig "{{ talos_dir }}/clusterconfig/kubeconfig" --force --merge=false
    echo "Wrote {{ talos_dir }}/clusterconfig/kubeconfig"

# Admin talosconfig, rebuilt offline from the cluster secrets in 1Password: the
# secrets bundle is reassembled (op inject) and fed to `talosctl gen config`
# through a file descriptor, so nothing secret is written except the output
# talosconfig itself. Works even when the current talosconfig has expired.
[confirm('Replace clusterconfig/talosconfig with one rebuilt from 1Password? [y/N]')]
[doc('Rebuild clusterconfig/talosconfig from the secrets in 1Password')]
talosconfig:
    #!/usr/bin/env bash
    set -euo pipefail
    out="{{ talos_dir }}/clusterconfig/talosconfig"
    tmp="$(mktemp "{{ talos_dir }}/clusterconfig/.talosconfig.XXXXXX")"
    trap 'rm -f "$tmp"' EXIT
    talosctl gen config cluster-0 https://cluster-0.mcbadass.local:6443 \
        --with-secrets <(just talos secrets-bundle | op inject) \
        --output-types talosconfig --output "$tmp" --force
    talosctl --talosconfig "$tmp" config endpoint 192.168.80.99 192.168.80.100 192.168.80.101
    talosctl --talosconfig "$tmp" config node 192.168.80.99 192.168.80.100 192.168.80.101 192.168.80.90
    chmod 600 "$tmp"
    mv "$tmp" "$out"
    trap - EXIT
    echo "Wrote ${out}"
    talosctl --talosconfig "$out" -n m720q-1 version --short >/dev/null && echo "Verified: m720q-1 accepts the new talosconfig."

# The talosctl secrets-bundle layout (what `talosctl gen secrets` writes and
# talhelper's talsecret.sops.yaml held), with 1Password references for values.
[private]
secrets-bundle:
    #!/usr/bin/env bash
    printf '%s\n' \
      'cluster:' \
      '  id: op://k8s/talos/CLUSTER_ID' \
      '  secret: op://k8s/talos/CLUSTER_SECRET' \
      'secrets:' \
      '  bootstraptoken: op://k8s/talos/CLUSTER_TOKEN' \
      '  aescbcencryptionsecret: op://k8s/talos/CLUSTER_AESCBC_ENCRYPTION_SECRET' \
      'trustdinfo:' \
      '  token: op://k8s/talos/MACHINE_TOKEN' \
      'certs:' \
      '  etcd:' \
      '    crt: op://k8s/talos/CLUSTER_ETCD_CA_CRT' \
      '    key: op://k8s/talos/CLUSTER_ETCD_CA_KEY' \
      '  k8s:' \
      '    crt: op://k8s/talos/CLUSTER_CA_CRT' \
      '    key: op://k8s/talos/CLUSTER_CA_KEY' \
      '  k8saggregator:' \
      '    crt: op://k8s/talos/CLUSTER_AGGREGATORCA_CRT' \
      '    key: op://k8s/talos/CLUSTER_AGGREGATORCA_KEY' \
      '  k8sserviceaccount:' \
      '    key: op://k8s/talos/CLUSTER_SERVICEACCOUNT_KEY' \
      '  os:' \
      '    crt: op://k8s/talos/MACHINE_CA_CRT' \
      '    key: op://k8s/talos/MACHINE_CA_KEY'

# Migration helper: copies every value from talsecret.sops.yaml into the
# 1Password item op://k8s/talos, one concealed field per value, labelled with
# the names the templates reference. Creates the item if it doesn't exist;
# otherwise updates matching fields in place, adds missing ones, and leaves any
# other fields alone (their LABELS are listed so leftovers are easy to spot).
#
# Secrets travel sops -> jq -> op through pipes and file descriptors only:
# never printed, never in argv (visible in `ps`), never written to disk.
[confirm('Create or update 1Password item op://k8s/talos from talsecret.sops.yaml? [y/N]')]
[doc('Copy the talhelper SOPS secrets into 1Password (op://k8s/talos), creating or updating')]
secrets-to-1password:
    #!/usr/bin/env bash
    set -euo pipefail
    op whoami >/dev/null 2>&1 || { echo "Not signed in to 1Password — run: eval \$(op signin)" >&2; exit 1; }

    fields() {
        sops -d --output-type json "{{ talos_dir }}/talsecret.sops.yaml" | jq '
            def f($label; $v):
                if ($v | type) != "string" or $v == "" then error("talsecret is missing a value for " + $label)
                else {label: $label, type: "CONCEALED", value: $v} end;
            [
              f("CLUSTER_ID";                       .cluster.id),
              f("CLUSTER_SECRET";                   .cluster.secret),
              f("CLUSTER_TOKEN";                    .secrets.bootstraptoken),
              f("CLUSTER_AESCBC_ENCRYPTION_SECRET"; .secrets.aescbcencryptionsecret),
              f("MACHINE_TOKEN";                    .trustdinfo.token),
              f("MACHINE_CA_CRT";                   .certs.os.crt),
              f("MACHINE_CA_KEY";                   .certs.os.key),
              f("CLUSTER_CA_CRT";                   .certs.k8s.crt),
              f("CLUSTER_CA_KEY";                   .certs.k8s.key),
              f("CLUSTER_AGGREGATORCA_CRT";         .certs.k8saggregator.crt),
              f("CLUSTER_AGGREGATORCA_KEY";         .certs.k8saggregator.key),
              f("CLUSTER_ETCD_CA_CRT";              .certs.etcd.crt),
              f("CLUSTER_ETCD_CA_KEY";              .certs.etcd.key),
              f("CLUSTER_SERVICEACCOUNT_KEY";       .certs.k8sserviceaccount.key)
            ]'
    }
    wanted='["CLUSTER_ID","CLUSTER_SECRET","CLUSTER_TOKEN","CLUSTER_AESCBC_ENCRYPTION_SECRET","MACHINE_TOKEN","MACHINE_CA_CRT","MACHINE_CA_KEY","CLUSTER_CA_CRT","CLUSTER_CA_KEY","CLUSTER_AGGREGATORCA_CRT","CLUSTER_AGGREGATORCA_KEY","CLUSTER_ETCD_CA_CRT","CLUSTER_ETCD_CA_KEY","CLUSTER_SERVICEACCOUNT_KEY"]'

    if ! op item get talos --vault k8s >/dev/null 2>&1; then
        jq '{
              title: "talos",
              category: "SECURE_NOTE",
              notesPlain: "Talos machine-config secrets for cluster-0, rendered by `just talos render-config` (justfiles/talos.just). Migrated from talsecret.sops.yaml.",
              fields: .
            }' <(fields) | op item create --vault k8s - >/dev/null
        echo "Created op://k8s/talos with 14 fields."
    else
        # A hand-made Password item fails validation on edit if its built-in
        # password field is empty ("Password item requires ps value").
        if op item get talos --vault k8s --format json \
             | jq -e '.category == "PASSWORD" and ([.fields[]? | select(.id == "password") | .value // ""] | first // "") == ""' >/dev/null; then
            echo "op://k8s/talos is a Password item with an empty password, which 1Password won't let us edit." >&2
            echo "If it holds nothing else you need, delete it and re-run to create it as a Secure Note:" >&2
            echo "  op item delete talos --vault k8s && just talos secrets-to-1password" >&2
            exit 1
        fi
        # Labels only (no values) for the report.
        existing="$(op item get talos --vault k8s --format json | jq -c '[.fields[]?.label]')"
        jq -rn --argjson e "$existing" --argjson w "$wanted" '
            "Updating op://k8s/talos:",
            "  replacing: \([$w[] | select(. as $l | $e | index($l))] | join(", ") | if . == "" then "(none)" else . end)",
            "  adding:    \([$w[] | select(. as $l | $e | index($l) | not)] | join(", ") | if . == "" then "(none)" else . end)",
            "  untouched: \([$e[] | select(. as $l | $w | index($l) | not)] | unique | join(", ") | if . == "" then "(none)" else . end)"'

        # Read the item, replace/append the 14 fields, write it back. Matching
        # is by label, wherever the field sits (any section).
        op item get talos --vault k8s --format json \
          | jq --slurpfile new <(fields) '
              reduce $new[0][] as $f (.;
                if any(.fields[]?; .label == $f.label)
                then .fields |= map(if .label == $f.label then .value = $f.value | .type = "CONCEALED" else . end)
                else .fields += [$f]
                end)' \
          | op item edit talos --vault k8s >/dev/null
        echo "Updated op://k8s/talos."
    fi
    echo "Next: just talos diff-node m720q-4"

[private]
node-role node:
    #!/usr/bin/env bash
    set -euo pipefail
    for role in controlplane worker; do
        if [[ -f "{{ talos_dir }}/nodes/${role}/{{ node }}.yaml.j2" ]]; then echo "${role}"; exit 0; fi
    done
    echo "No node file for '{{ node }}' under nodes/controlplane or nodes/worker" >&2
    exit 1

[private]
talos-version:
    yq -r '.talos_version' "{{ talos_dir }}/version.yaml"

[private]
k8s-version:
    yq -r '.k8s_version' "{{ talos_dir }}/version.yaml"

[private]
schematic-id:
    curl -fsS -X POST --data-binary @"{{ talos_dir }}/schematic.yaml" https://factory.talos.dev/schematics | jq -r '.id'

[private]
machine-image:
    echo "factory.talos.dev/metal-installer/$(just talos schematic-id):$(just talos talos-version)"
