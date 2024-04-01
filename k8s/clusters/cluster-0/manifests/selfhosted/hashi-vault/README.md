# Hashicorp Vault Guides

## Roll out an upgrade after updating the image

```sh
kubectl delete pod -n selfhosted --selector="vault-active=false"
# Wait until pods come back up
kubectl delete pod -n selfhosted --selector="vault-active=true"
```