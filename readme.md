# Reinstall current default config

```shell
kubectl delete namespace spidybox 
```


```shell
helm upgrade --install spidybox . --namespace=spidybox --create-namespace
```

# Uninstall 
```shell
helm uninstall spidybox --namespace=spidybox 
```

# Test installation without actually doing it
```shell
helm upgrade spidybox . --namespace=spidybox --dry-run --debug
```


```shell
helm repo add longhorn https://charts.longhorn.io
helm repo update
```
```shell
helm upgrade --install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace
```

```shell
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=192.168.1.2 \
    --set nfs.path=/volume1/medias
```
