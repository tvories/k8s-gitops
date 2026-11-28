set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

templates_dir := justfile_directory() + "/.taskfiles/volsync"
scripts_dir := justfile_directory() + "/.taskfiles/_scripts"

[private]
default:
    @just --list volsync

[doc('Trigger a VolSync snapshot for a ReplicationSource')]
snapshot ns name:
    kubectl -n "{{ ns }}" patch replicationsources "{{ name }}" \
        --type merge -p "{\"spec\":{\"trigger\":{\"manual\":\"$(date +%s)\"}}}"

[doc('Trigger VolSync snapshots for all ReplicationSources')]
snapshot-all:
    kubectl get replicationsources --no-headers -A | while read -r ns name _; do \
        just volsync snapshot "$ns" "$name"; \
    done

[doc('List all restic snapshots for a ReplicationSource')]
list ns name:
    #!/usr/bin/env bash
    export rsrc="{{ name }}" namespace="{{ ns }}" ts="$(date +%H%M%S)"
    envsubst < "{{ templates_dir }}/ListJob.tmpl.yaml" | kubectl apply -f -
    bash "{{ scripts_dir }}/wait-for-k8s-job.sh" "list-${rsrc}-${ts}" "{{ ns }}"
    kubectl -n "{{ ns }}" wait job/"list-${rsrc}-${ts}" --for condition=complete --timeout=1m
    kubectl -n "{{ ns }}" logs job/"list-${rsrc}-${ts}" --container list
    kubectl -n "{{ ns }}" delete job "list-${rsrc}-${ts}"

[doc('Remove stale restic locks for a ReplicationSource (force=true also removes live locks)')]
unlock ns name force="false":
    #!/usr/bin/env bash
    set -euo pipefail
    secret=$(kubectl -n "{{ ns }}" get replicationsource "{{ name }}" -o jsonpath='{.spec.restic.repository}')
    [[ -n "$secret" ]] || { echo "{{ ns }}/{{ name }}: no spec.restic.repository" >&2; exit 1; }
    if [[ "{{ force }}" == "true" ]]; then unlock_args='["unlock","--remove-all"]'; else unlock_args='["unlock"]'; fi
    export rsrc="{{ name }}" namespace="{{ ns }}" ts="$(date +%H%M%S)" secret unlock_args
    job="unlock-${rsrc}-${ts}"
    echo "==> {{ ns }}/{{ name }} (secret: ${secret})"
    envsubst '${rsrc} ${namespace} ${ts} ${secret} ${unlock_args}' \
        < "{{ templates_dir }}/UnlockJob.tmpl.yaml" | kubectl apply -f -
    bash "{{ scripts_dir }}/wait-for-k8s-job.sh" "$job" "{{ ns }}"
    rc=0
    kubectl -n "{{ ns }}" wait job/"$job" --for condition=complete --timeout=5m || rc=$?
    kubectl -n "{{ ns }}" logs job/"$job" --container unlock || true
    if [[ $rc -ne 0 ]]; then
        echo "{{ ns }}/{{ name }}: unlock did not complete; job left for inspection (ttl 1h)" >&2
        exit $rc
    fi
    kubectl -n "{{ ns }}" delete job "$job"

[doc('Remove stale restic locks for every restic ReplicationSource (force=true also removes live locks)')]
unlock-all force="false":
    #!/usr/bin/env bash
    set -uo pipefail
    failed=()
    while read -r ns name; do
        just volsync unlock "$ns" "$name" "{{ force }}" || failed+=("$ns/$name")
    done < <(kubectl get replicationsources -A \
        -o jsonpath='{range .items[?(@.spec.restic)]}{.metadata.namespace} {.metadata.name}{"\n"}{end}')
    if (( ${#failed[@]} )); then
        echo "Failed: ${failed[*]}" >&2
        exit 1
    fi
    echo "All restic repositories unlocked."

[doc('Restore a ReplicationSource from restic (snapshot index defaults to 1)')]
restore ns name snapshot="1":
    #!/usr/bin/env bash
    export rsrc="{{ name }}" namespace="{{ ns }}" snapshot="{{ snapshot }}" ts="$(date +%H%M%S)"
    kustomization=$(kubectl -n "{{ ns }}" get replicationsource "{{ name }}" \
        -o jsonpath="{.metadata.labels.kustomize\.toolkit\.fluxcd\.io/name}")
    claim=$(kubectl -n "{{ ns }}" get replicationsource "{{ name }}" \
        -o jsonpath="{.spec.sourcePVC}")
    app=$(kubectl -n "{{ ns }}" get persistentvolumeclaim "$claim" \
        -o jsonpath="{.metadata.labels.app\.kubernetes\.io/name}")
    if [[ -n $(kubectl -n "{{ ns }}" get deployment --no-headers -l "app.kubernetes.io/name=$app" 2>/dev/null) ]]; then
        controller="deployments.apps/$app"
    else
        controller="statefulsets.apps/$app"
    fi
    export kustomization claim controller
    # Suspend
    flux -n flux-system suspend kustomization "$kustomization"
    flux -n "{{ ns }}" suspend helmrelease "{{ name }}"
    kubectl -n "{{ ns }}" wait pod --for delete \
        --selector="app.kubernetes.io/name={{ name }}" --timeout=2m
    # Restore
    envsubst < "{{ templates_dir }}/ReplicationDestination.tmpl.yaml" | kubectl apply -f -
    bash "{{ scripts_dir }}/wait-for-k8s-job.sh" "volsync-dst-${rsrc}-${claim}-${ts}" "{{ ns }}"
    kubectl -n "{{ ns }}" wait job/"volsync-dst-${rsrc}-${claim}-${ts}" \
        --for condition=complete --timeout=120m
    kubectl -n "{{ ns }}" delete replicationdestination "${rsrc}-${claim}-${ts}"
    # Resume
    flux -n "{{ ns }}" resume helmrelease "{{ name }}"
    flux -n flux-system resume kustomization "$kustomization"
