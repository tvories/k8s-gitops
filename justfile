set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

mod flux 'justfiles/flux.just'
mod k8s 'justfiles/k8s.just'
mod volsync 'justfiles/volsync.just'
mod rook 'justfiles/rook.just'

[private]
default:
    @just --list
