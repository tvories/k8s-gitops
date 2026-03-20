set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

[private]
default:
    @just --list k8s

[doc('Mount a PersistentVolumeClaim to a temporary debug pod')]
browse-pvc namespace claim:
    #!/usr/bin/env bash
    kubectl run -n {{ namespace }} debug-{{ claim }} -i --tty --rm \
        --image=ghcr.io/nicolaka/netshoot:latest --privileged \
        --overrides='{
          "spec": {
            "containers": [{
              "name": "debug",
              "image": "ghcr.io/nicolaka/netshoot:latest",
              "command": ["/bin/bash"],
              "stdin": true, "stdinOnce": true, "tty": true,
              "volumeMounts": [{"name": "data", "mountPath": "/data"}]
            }],
            "volumes": [{"name": "data", "persistentVolumeClaim": {"claimName": "{{ claim }}"}}],
            "restartPolicy": "Never"
          }
        }'

[doc('Open a privileged debug shell on a node')]
node-shell node:
    kubectl debug node/{{ node }} -n default -it \
        --image=ghcr.io/nicolaka/netshoot:latest --profile sysadmin
    kubectl delete pod -n default -l app.kubernetes.io/managed-by=kubectl-debug

[doc('Delete pods in Failed, Pending, or Succeeded state')]
prune-pods:
    for phase in Failed Pending Succeeded; do \
        kubectl delete pods -A --field-selector status.phase="$phase" --ignore-not-found=true; \
    done

[doc('Check yaml files changed vs main for kustomize/kubectl errors')]
check-yaml:
    git diff --name-only origin/main.. | grep kustomization.yaml | sed 's/kustomization.yaml//' \
        | xargs -I{} kustomize build {}
    git diff --name-only origin/main.. | grep .yaml \
        | xargs cat | kubectl apply -f - --dry-run=server

[doc('Suspend or resume a KEDA ScaledObject')]
keda state ns name:
    kubectl -n "{{ ns }}" annotate --field-manager flux-client-side-apply --overwrite \
        so "{{ name }}" autoscaling.keda.sh/paused{{ if state != "suspend" { "-" } else { "=true" } }}

[doc('Suspend or resume all KEDA ScaledObjects')]
keda-all state:
    kubectl get scaledobjects --no-headers -A | while read -r ns name _; do \
        just k8s keda "{{ state }}" "$ns" "$name"; \
    done

[doc('List all DockerHub images running in the cluster')]
list-dockerhub-images:
    kubectl get pods --all-namespaces \
        -o=jsonpath='{range .items[*]}{"\n"}{range .spec.containers[*]}{.image}{"\n"}{end}{end}' \
        | sort | uniq \
        | grep -Ev 'quay|gcr|ghcr|ecr|us-docker' \
        | grep -Ev 'bitnami|rook|intel|grafana' \
        | sed -e 's/docker\.io\///g' \
        | sort | uniq
