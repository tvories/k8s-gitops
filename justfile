set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

mod flux 'justfiles/flux.just'
mod k8s 'justfiles/k8s.just'
mod volsync 'justfiles/volsync.just'
mod rook 'justfiles/rook.just'
mod vault 'justfiles/vault.just'
mod talos 'justfiles/talos.just'
mod tf 'justfiles/tf.just'

[private]
default:
    @just --list
