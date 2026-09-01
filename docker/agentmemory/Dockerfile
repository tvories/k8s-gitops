# agentmemory does not publish a prebuilt image. Upstream's deploy templates
# each build one that npm-installs @agentmemory/agentmemory and copies the iii
# engine binary out of the public iiidev/iii image. This is upstream's
# deploy/coolify/Dockerfile with a Kubernetes-tuned entrypoint.
# https://github.com/rohitg00/agentmemory/tree/main/deploy

# renovate: datasource=docker depName=iiidev/iii
ARG III_VERSION=0.11.2

FROM iiidev/iii:${III_VERSION} AS iii-image

FROM node:22-slim

# renovate: datasource=npm depName=@agentmemory/agentmemory
ARG AGENTMEMORY_VERSION=0.9.29
ARG III_VERSION=0.11.2
ARG III_SDK_VERSION=0.11.2

RUN apt-get update \
 && apt-get install -y --no-install-recommends openssl ca-certificates tini gosu curl \
 && rm -rf /var/lib/apt/lists/*

COPY --from=iii-image /app/iii /usr/local/bin/iii

WORKDIR /opt/agentmemory
# One layer for install + prune + model bake + chown. Splitting these was
# worth ~1.3GB: `chown -R` rewrites every file, so as its own step Docker
# stores a second full copy of node_modules, and anything deleted in a later
# layer still ships in the earlier one.
#
# Upstream's templates pass --omit=optional. We keep optional deps because
# @huggingface/transformers is one, and EMBEDDING_PROVIDER=local needs it.
RUN printf '{"name":"agentmemory-deploy","version":"1.0.0","private":true,"overrides":{"iii-sdk":"%s"}}\n' "${III_SDK_VERSION}" > package.json \
 && npm install "@agentmemory/agentmemory@${AGENTMEMORY_VERSION}" --no-fund --no-audit \
 && ln -s /opt/agentmemory/node_modules/.bin/agentmemory /usr/local/bin/agentmemory \
 # onnxruntime-web is the browser/WebGPU backend. transformers.js statically
 # imports it from src/backends/onnx.js, but the bundled Node entrypoint
 # (dist/transformers.node.mjs) does not, so it is dead weight here. Verified
 # by running a real embedding with it deleted.
 && rm -rf node_modules/onnxruntime-web \
 # onnxruntime-node ships every platform's binaries plus GPU execution
 # providers. This runs CPU-only on linux/x64; the CUDA provider alone is
 # 302MB of dead weight.
 && ORT=node_modules/onnxruntime-node/bin/napi-v6 \
 && find "$ORT" -mindepth 1 -maxdepth 1 ! -name linux -exec rm -rf {} + \
 && find "$ORT/linux" -mindepth 1 -maxdepth 1 ! -name x64 -exec rm -rf {} + \
 && rm -f "$ORT/linux/x64/libonnxruntime_providers_cuda.so" \
          "$ORT/linux/x64/libonnxruntime_providers_tensorrt.so" \
 # Bake the embedding model in. transformers.js caches inside its own package
 # dir with no env var to relocate it, so fetching at runtime would mean a
 # write into /opt plus egress on first search. Model id and dtype must match
 # src/providers/embedding/local.ts exactly, or the runtime pipeline() call
 # misses this cache and silently refetches.
 && node -e "import('@huggingface/transformers') \
      .then(t => t.pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2', { dtype: 'q8' })) \
      .then(() => console.log('embedding model cached')) \
      .catch(e => { console.error(e); process.exit(1); })" \
 # The entrypoint drops to `node`, which must be able to read the model cache
 # and have the iii config rewritten underneath it.
 && chown -R node:node /opt/agentmemory

ENV AGENTMEMORY_III_VERSION=${III_VERSION} \
    AGENTMEMORY_DATA_DIR=/data \
    TINI_SUBREAPER=1

COPY --chmod=0755 entrypoint.sh /usr/local/bin/agentmemory-entrypoint.sh

EXPOSE 3111 3112

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD curl -fsS http://127.0.0.1:3111/agentmemory/livez || exit 1

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/agentmemory-entrypoint.sh"]
