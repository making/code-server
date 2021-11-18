# Code Server


```
mkdir -p $HOME/coder/workspace
docker run \
  --name code-server \
  --rm \
  -p 3000:3000 \
  -e PASSWORD=password  \
  -e PORT=3000 \
  -v $HOME/coder/workspace:/home/coder/workspace \
  -v $HOME/.m2:/home/coder/.m2 \
  ghcr.io/making/code-server
```


## Deploy on kubernetes

```
curl -sL https://github.com/projectcontour/contour/raw/main/examples/kind/kind-expose-port.yaml > kind-expose-port.yaml
kind create cluster --config kind-expose-port.yaml 
```

```
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml
kubectl apply -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v0.30.0/release.yml
kubectl apply -f https://github.com/vmware-tanzu/carvel-secretgen-controller/releases/download/v0.7.1/release.yml
```

```
kubectl apply -f kapp/namespace-role.yaml
kubectl apply -f kapp/developer-env-demo1.yaml
kubectl apply -f kapp/developer-env-demo2.yaml
```


```
$ kubectl get httpproxy -A
NAMESPACE             NAME          FQDN                                 TLS SECRET        STATUS   STATUS DESCRIPTION
developer-env-demo1   code-server   coder-server-demo1.localhost.ik.am   code-server-tls   valid    Valid HTTPProxy
developer-env-demo2   code-server   coder-server-demo2.localhost.ik.am   code-server-tls   valid    Valid HTTPProxy
```

```
$ kubectl get secret -n developer-env-demo1 code-server-password -otemplate='{{.data.password | base64decode}}'
gjknfacl031ndksztukfuxv916exbbjbhdvryaud
$ kubectl get secret -n developer-env-demo2 code-server-password -otemplate='{{.data.password | base64decode}}'
k1rhx2sflv9oohzhaemubdoie6emiuao65kqd962
```

### How to configure values

Update `values.yaml` in the Secret

```yaml
# ...   
---
apiVersion: v1
kind: Secret
metadata:
  name: developer-env-demo1-values
  namespace: developer-env
stringData:
  values.yaml: |
    #@data/values
    #@overlay/match-child-defaults missing_ok=True
    ---
    namespace: developer-env
    suffix: demo1
    code_server:
      external_url_format: https://coder-server-{}.default.example.com
      ingress_class: contour-external
```