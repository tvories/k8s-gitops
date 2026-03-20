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

[doc('Unlock a restic repository for a ReplicationSource')]
unlock ns name:
    #!/usr/bin/env bash
    export rsrc="{{ name }}" namespace="{{ ns }}" ts="$(date +%H%M%S)"
    envsubst < "{{ templates_dir }}/UnlockJob.tmpl.yaml" | kubectl apply -f -
    bash "{{ scripts_dir }}/wait-for-k8s-job.sh" "unlock-${rsrc}-${ts}" "{{ ns }}"
    kubectl -n "{{ ns }}" wait job/"unlock-${rsrc}-${ts}" --for condition=complete --timeout=1m
    kubectl -n "{{ ns }}" logs job/"unlock-${rsrc}-${ts}" --container unlock
    kubectl -n "{{ ns }}" delete job "unlock-${rsrc}-${ts}"

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
