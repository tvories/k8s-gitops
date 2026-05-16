set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

[private]
default:
    @just --list vault

[doc('Rolling Vault upgrade: delete inactive pods, wait for ready, then delete active pod')]
update-vault:
    #!/usr/bin/env bash
    NAMESPACE=selfhosted

    echo "Deleting inactive Vault pods..."
    kubectl delete po -n "${NAMESPACE}" --selector="vault-active=false"

    echo "Waiting for all Vault pods to be ready..."
    kubectl wait po -n "${NAMESPACE}" --selector="app.kubernetes.io/name=vault" \
        --for=condition=Ready --timeout=300s

    echo "All pods ready. Deleting active Vault pod..."
    kubectl delete po -n "${NAMESPACE}" --selector="vault-active=true"

    echo "Waiting for cluster to stabilize..."
    kubectl wait po -n "${NAMESPACE}" --selector="app.kubernetes.io/name=vault" \
        --for=condition=Ready --timeout=300s

    echo "Vault upgrade complete."
