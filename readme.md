#

```shell
kubectl create namespace spidybox
```

```shell
helm uninstall spidybox --namespace=spidybox 
```

```shell
helm upgrade --install spidybox . --namespace=spidybox 
```


```shell
helm upgrade spidybox . --namespace=spidybox --dry-run --debug
```


```shell
kubectl delete namespace spidybox
helm upgrade --install spidybox . --namespace=spidybox 
```

