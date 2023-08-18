## Bootstrapping Talos

There are a few things that need to happen to bootstrap a cluster from the talos config.  These commands are written assuming you are running them from the talos directory.

### Talos

```bash
talosctl apply-config --insecure --nodes physical1 --file ./clusterconfig/cluster-0-physical1.mcbadass.local.yaml
talosctl apply-config --insecure --nodes physical2 --file ./clusterconfig/cluster-0-physical2.mcbadass.local.yaml
talosctl apply-config --insecure --nodes sff1 --file ./clusterconfig/cluster-0-sff1.mcbadass.local.yaml
talosctl apply-config --insecure --nodes m720q-1 --file ./clusterconfig/cluster-0-m720q-1.mcbadass.local.yaml
talosctl apply-config --insecure --nodes m720q-2 --file ./clusterconfig/cluster-0-m720q-2.mcbadass.local.yaml

# Bootstrap one node
talosctl bootstrap -n m720q-2
```

### CNI

Instead of installing from a quick-install github directory, I am now installing the CNI with:

```bash
kubectl kustomize --enable-helm ./cni | kubectl apply -f -
```

### Kubelet CSR Approver

Similar to CNI, I moved from installing a manifest file to this:

```bash
kubectl kustomize --enable-helm ./kubelet-csr-approver | kubectl apply -f -
```

## Flux

### Install Flux

Create the flux namespace:

```bash
kubectl create ns flux-system
```

This command pulls the current flux version from my git repo and installs flux with that version specified

```bash
yq '.spec.ref.tag' k8s/global/flux/repositories/git/flux.yaml | xargs -I{} flux install --version={} --export | kubectl apply -f -
```

### Flux GCP SOPS Secret

I use a GCP service account to unseal my SOPs stuff. I need to create a secret with the service account json file created with the terraform run:

```bash
kubectl -n flux-system create secret generic fluxcd-google-sa-secret --from-file=./k8s/clusters/cluster-0/terraform/gcp-flux-sa-credential.json --type=Opaque
```


## Bootstrap Cluster

Apply the top-level kustomization by running:

```bash
kubectl apply -k k8s/clusters/cluster-0/
```