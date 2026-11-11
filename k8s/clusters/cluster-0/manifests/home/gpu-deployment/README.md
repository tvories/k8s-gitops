# GPU voice services (desktop) + HAProxy failover

Not applied by Flux. `docker-compose.yaml` runs on the desktop with the RTX 3080;
it lives here so it sits beside the in-cluster manifests it mirrors.

## Architecture

```
Home Assistant ──> VIP on OPNsense
                     :10300  primary desktop:10300  (whisper large-v3, GPU)
                             backup  192.168.83.x:10300  ← in-cluster, base-int8 CPU
                     :10200  primary desktop:10200  (kokoro, GPU)
                             backup  192.168.83.x:10200  ← in-cluster, CPU
```

HA points at the VIP only. HAProxy health-checks the desktop and silently falls
back to the cluster when it's asleep, rebooting, or wedged.

## Why these images

| Service | Image | Note |
|---|---|---|
| STT | `lscr.io/linuxserver/faster-whisper:3.5.0-gpu` | linuxserver, not rhasspy — theirs is the one publishing CUDA builds. Configured by **env vars**, whereas the in-cluster pod uses **command-line args**. |
| TTS | `ghcr.io/remsky/kokoro-fastapi-gpu:v0.6.0` | Same version as the in-cluster CPU image. |
| TTS bridge | `ghcr.io/roryeckel/wyoming_openai:0.5.0` | Kokoro speaks OpenAI HTTP, not Wyoming. Identical to the cluster's bridge. |

## Two things that must stay in sync with `home/kokoro`

**`TTS_VOICES`** — Home Assistant stores the chosen voice by name (`bf_lily`).
A voice present on one side and missing on the other breaks TTS at the exact
moment failover happens. Change one, change both.

**Ports** — `10300` / `10200` on both sides, so HAProxy can treat desktop and
cluster as interchangeable.

`WHISPER_MODEL` deliberately does *not* match: `large-v3-turbo` on the GPU,
`base-int8` in-cluster. Accuracy changes on failover; that's the trade.

## VRAM budget

The 3080 has 10 GB and is shared with the desktop. When the card runs out,
the kernel logs `NVRM: ... Out of memory [NV_ERR_NO_MEMORY]`, and whoever
asked for memory at that moment crashes. That has been Firefox (status 11),
kokoro (startup failed) and whisper.cpp (segfault loop on restart).
Full `large-v3` (~3.8 GB) + whisper.cpp (~2 GB) + kokoro (~0.9 GB) + desktop
(~1.5 GB) used about 9.1 of the 10 GB, so the always-on set is now
turbo + kokoro (~3 GB), and whisper.cpp only runs under
`--profile bookbridge`.

## Setup

The desktop runs NixOS (`deskmonster` in nix-config). It needs
`hardware.nvidia-container-toolkit.enable = true` and firewall openings for
10300/10200/8178 from the home networks. The toolkit exposes the GPU through
CDI, so the compose file requests `nvidia.com/gpu=all` instead of the
`nvidia` driver, and `--gpus all` doesn't work on this host.

```bash
# 1. Confirm the toolkit sees the GPU
docker run --rm --device nvidia.com/gpu=all ubuntu nvidia-smi

# 2. Start
docker compose up -d

# 3. Verify Wyoming actually answers (not just that the port is open)
python3 - <<'EOF'
import json, socket
for port, label in ((10300, "whisper"), (10200, "kokoro")):
    s = socket.create_connection(("localhost", port), timeout=10)
    s.sendall((json.dumps({"type": "describe", "version": "1.5.0"}) + "\n").encode())
    f = s.makefile("rb")
    h = json.loads(f.readline())
    n = h.get("data_length") or 0
    d = json.loads(f.read(n)) if n else h.get("data", {})
    print(label, "->", h.get("type"),
          [p.get("name") for p in (d.get("asr") or d.get("tts") or [])])
    s.close()
EOF
```

Then confirm the cluster can reach the desktop — a port being open on the host
is not the same as being reachable from a pod:

```bash
kubectl -n home run netcheck --rm -it --restart=Never --image=busybox -- \
  sh -c 'nc -vz <desktop-ip> 10300 && nc -vz <desktop-ip> 10200'
```

## HAProxy on OPNsense

The `os-haproxy` plugin is **not installed** as of 2026-08-03 (`installed=0`,
available `5.1`). Install it first:

```
System → Firmware → Plugins → os-haproxy
```
or `POST /api/core/firmware/install` with `os-haproxy`.

Then, per service (whisper `10300`, TTS `10200`):

1. **Real servers** — desktop (primary) and the in-cluster LB IP (mode `backup`)
2. **Health monitor** — TCP is not enough; a wedged container still accepts
   connections. Send a Wyoming `describe` and expect `"type":"info"`:
   - send `{"type": "describe", "version": "1.5.0"}\n`
   - expect string `"type": "info"`
3. **Backend pool** — both servers, the cluster one flagged *backup*
4. **Public service** — listen on the VIP at the matching port, TCP mode

`inter 2s` / `fall 2` gives ~4s failover. Requests already in flight when the
desktop drops will error and be retried by Home Assistant.

Finally, repoint HA's two Wyoming integrations at the VIP and reload them.

## Measured baseline (CPU, in-cluster)

| | Latency |
|---|---|
| whisper `base-int8` | 0.76s for 1.75s of speech (RTF 0.44) |
| kokoro `af_heart` | 2.57s |
| kokoro `bf_lily` | 3.23s |
| piper `lessac-medium` | 0.49s |

Kokoro on CPU is the bottleneck — the round trip with `bf_lily` is ~4.0s. That
is what this GPU path exists to fix.
