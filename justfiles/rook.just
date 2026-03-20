set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

templates_dir := justfile_directory() + "/.taskfiles/rook"
scripts_dir := justfile_directory() + "/.taskfiles/_scripts"

[private]
default:
    @just --list rook

[doc('Exec into the Rook-Ceph toolbox')]
toolbox:
    kubectl -n rook-ceph exec -it \
        $(kubectl -n rook-ceph get pod -l "app=rook-direct-mount" -o jsonpath='{.items[0].metadata.name}') \
        -- bash

[doc('Print the Rook-Ceph dashboard password')]
password:
    kubectl -n rook-ceph get secret rook-ceph-dashboard-password \
        -o jsonpath="{['data']['password']}" | base64 --decode && echo

[doc('Wipe Rook-Ceph disk and data from a node (e.g. just rook wipe-node m720q-1)')]
wipe-node node:
    #!/usr/bin/env bash
    case "{{ node }}" in
        m720q-1) ceph_disk="/dev/disk/by-id/nvme-TEAM_TM8FP6001T_TPBF2304210050300351" ;;
        m720q-2) ceph_disk="/dev/disk/by-id/nvme-TEAM_TM8FP6001T_TPBF2305150020700998" ;;
        m720q-3) ceph_disk="/dev/disk/by-id/nvme-TEAM_TM8FP6001T_TPBF2307170050100778" ;;
        *) echo "Unknown node: {{ node }}. Valid nodes: m720q-1, m720q-2, m720q-3"; exit 1 ;;
    esac
    ts="$(date +%H%M%S)"
    export node="{{ node }}" ceph_disk ts
    # Wipe disk
    export jobName="wipe-disk-{{ node }}"
    envsubst < "{{ templates_dir }}/WipeDiskJob.tmpl.yaml" | kubectl apply -f -
    bash "{{ scripts_dir }}/wait-for-k8s-job.sh" "$jobName" default
    kubectl -n default wait job/"$jobName" --for condition=complete --timeout=1m
    kubectl -n default logs job/"$jobName" --container list
    kubectl -n default delete job "$jobName"
    # Wipe data
    export jobName="wipe-rook-data-{{ node }}-${ts}"
    envsubst < "{{ templates_dir }}/WipeRookDataJob.tmpl.yaml" | kubectl apply -f -
    bash "{{ scripts_dir }}/wait-for-k8s-job.sh" "$jobName" default
    kubectl -n default wait job/"$jobName" --for condition=complete --timeout=1m
    kubectl -n default logs job/"$jobName" --container list
    kubectl -n default delete job "$jobName"
