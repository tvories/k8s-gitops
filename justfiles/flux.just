set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

repo_dir := justfile_directory()
cluster_dir := repo_dir + "/k8s/clusters/cluster-0"

[private]
default:
    @just --list flux

[doc('Bootstrap Flux from the version pinned in the manifest')]
bootstrap:
    yq '.spec.ref.tag' {{ repo_dir }}/k8s/global/flux/repositories/git/flux.yaml \
        | xargs -I{} flux install --version={} --export \
        | kubectl apply -f -
    kubectl apply -k {{ repo_dir }}/k8s/clusters/cluster-0/

[doc('Sync a single Flux HelmRelease')]
sync-hr ns name:
    kubectl -n "{{ ns }}" annotate --field-manager flux-client-side-apply --overwrite \
        hr "{{ name }}" \
        reconcile.fluxcd.io/requestedAt="$(date +%s)" \
        reconcile.fluxcd.io/forceAt="$(date +%s)"

[doc('Sync a single Flux Kustomization')]
sync-ks ns name:
    kubectl -n "{{ ns }}" annotate --field-manager flux-client-side-apply --overwrite \
        ks "{{ name }}" \
        reconcile.fluxcd.io/requestedAt="$(date +%s)"

[doc('Sync a single ExternalSecret')]
sync-es ns name:
    kubectl -n "{{ ns }}" annotate --field-manager flux-client-side-apply --overwrite \
        es "{{ name }}" force-sync="$(date +%s)"

[doc('Sync all Flux HelmReleases')]
sync-all-hr:
    kubectl get hr --no-headers -A | while read -r ns name _; do \
        just flux sync-hr "$ns" "$name"; \
    done

[doc('Sync all Flux Kustomizations')]
sync-all-ks:
    kubectl get ks --no-headers -A | while read -r ns name _; do \
        just flux sync-ks "$ns" "$name"; \
    done

[doc('Sync all ExternalSecrets')]
sync-all-es:
    kubectl get es --no-headers -A | while read -r ns name _; do \
        just flux sync-es "$ns" "$name"; \
    done

[doc('Sync all Flux GitRepositories')]
sync-all-gr:
    kubectl get gitrepositories --all-namespaces --no-headers | awk '{print $1, $2}' \
        | xargs -P 4 -L 1 bash -c \
            'kubectl -n $0 annotate gitrepository/$1 reconcile.fluxcd.io/requestedAt=$(date +%s) --field-manager=flux-client-side-apply --overwrite'

[doc('Suspend all Flux HelmReleases')]
suspend-all-hr:
    flux get helmrelease --all-namespaces --no-header | awk '{print $1, $2}' \
        | xargs -L 1 bash -c 'flux -n $0 suspend helmrelease $1'

[doc('Resume all Flux HelmReleases')]
resume-all-hr:
    flux get helmrelease --all-namespaces --no-header | awk '{print $1, $2}' \
        | xargs -L 1 bash -c 'flux -n $0 resume helmrelease $1'

[doc('Apply a local Flux Kustomization')]
apply-ks ns ks:
    just flux _render-local-ks "{{ ns }}" "{{ ks }}" \
        | kubectl apply --server-side --force-conflicts --field-manager=kustomize-controller -f /dev/stdin

[doc('Delete a local Flux Kustomization')]
delete-ks ns ks:
    just flux _render-local-ks "{{ ns }}" "{{ ks }}" \
        | kubectl delete -f /dev/stdin

[private]
_render-local-ks ns ks:
    flux-local build ks --namespace "{{ ns }}" --path "{{ cluster_dir }}" "{{ ks }}"
