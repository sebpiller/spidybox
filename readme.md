# Destroy the namespace if any and reinstall the app

```shell
kubectl delete namespace spidybox
kubectl create namespace spidybox
helm upgrade --install spidybox . --namespace=spidybox 
```

# Uninstall 
```shell
helm uninstall spidybox --namespace=spidybox 
```

# Test installation without actually doing it
```shell
helm upgrade spidybox . --namespace=spidybox --dry-run --debug
```
