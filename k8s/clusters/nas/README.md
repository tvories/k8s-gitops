# NAS Kubernetes

I am running TrueNAS Scale and I am using Flux to manage the manifests on the built-in K3s.

## How to bootstrap

Assuming you are in the `nas` root folder:

### Flux

#### Install Flux

```command
kubectl apply --server-side --kustomize ./bootstrap
```

#### Install service account secret

I use a GCP service account to decrypt flux secrets using SOPS.

```command
kubectl -n flux-system create secret generic fluxcd-google-sa-secret --from-file=$SADIRECTORY/gcp-flux-sa-credential.json --type=Opaque
```