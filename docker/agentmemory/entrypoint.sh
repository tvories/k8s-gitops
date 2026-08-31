#!/bin/sh
# agentmemory entrypoint, adapted from upstream deploy/coolify/entrypoint.sh.
#
# Runs as root so it can:
#   1. Overwrite the npm-bundled iii-config.yaml (which binds 127.0.0.1 and
#      uses relative ./data paths) with one that binds 0.0.0.0 and uses
#      absolute /data paths.
#   2. chown the mounted PVC to the runtime user.
#   3. Establish the HMAC secret.
#
# Divergence from upstream: when AGENTMEMORY_SECRET is supplied by the
# environment (here: an ExternalSecret sourced from 1Password) it is written
# to the persisted HMAC file instead of being ignored in favour of a
# self-generated one. That keeps the secret declarative — rotating it in
# 1Password and restarting the pod is enough, and MCP clients can be
# configured with a value we already know rather than one we have to scrape
# out of first-boot pod logs.
#
# Then it execs the agentmemory CLI under gosu as the unprivileged `node` user.

set -eu

DATA_DIR="${AGENTMEMORY_DATA_DIR:-/data}"
HMAC_FILE="${AGENTMEMORY_HMAC_FILE:-/data/.hmac}"
RUN_AS="node:node"
III_CONFIG="/opt/agentmemory/node_modules/@agentmemory/agentmemory/dist/iii-config.yaml"

mkdir -p "$DATA_DIR"
chown -R "$RUN_AS" "$DATA_DIR"

cat > "$III_CONFIG" <<'EOF'
workers:
  - name: iii-http
    config:
      port: 3111
      host: 0.0.0.0
      default_timeout: 180000
      cors:
        allowed_origins:
          - "http://localhost:3111"
          - "http://localhost:3113"
          - "http://127.0.0.1:3111"
          - "http://127.0.0.1:3113"
        allowed_methods: [GET, POST, PUT, DELETE, OPTIONS]
  - name: iii-state
    config:
      adapter:
        name: kv
        config:
          store_method: file_based
          file_path: /data/state_store.db
  - name: iii-queue
    config:
      adapter:
        name: builtin
  - name: iii-pubsub
    config:
      adapter:
        name: local
  - name: iii-cron
    config:
      adapter:
        name: kv
  - name: iii-stream
    config:
      port: 3112
      host: 0.0.0.0
      adapter:
        name: kv
        config:
          store_method: file_based
          file_path: /data/stream_store
  - name: iii-observability
    config:
      enabled: true
      service_name: agentmemory
      exporter: memory
      sampling_ratio: 1.0
      metrics_enabled: true
      logs_enabled: true
      logs_console_output: true
EOF
chown "$RUN_AS" "$III_CONFIG"

umask 077
if [ -n "${AGENTMEMORY_SECRET:-}" ]; then
  printf '%s\n' "$AGENTMEMORY_SECRET" > "$HMAC_FILE"
elif [ ! -s "$HMAC_FILE" ]; then
  printf '%s\n' "$(openssl rand -hex 32)" > "$HMAC_FILE"
  echo "================================================================"
  echo "agentmemory: no AGENTMEMORY_SECRET supplied; generated one and"
  echo "stored it at $HMAC_FILE (chmod 600). Read it with:"
  echo "  kubectl -n selfhosted exec deploy/agentmemory -- cat $HMAC_FILE"
  echo "================================================================"
fi
chmod 600 "$HMAC_FILE"
chown "$RUN_AS" "$HMAC_FILE"

AGENTMEMORY_SECRET="$(cat "$HMAC_FILE")"
export AGENTMEMORY_SECRET

exec gosu "$RUN_AS" agentmemory "$@"
