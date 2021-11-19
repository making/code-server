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


## Install Code Server on kubernetes

```
curl -sL https://github.com/projectcontour/contour/raw/main/examples/kind/kind-expose-port.yaml > kind-expose-port.yaml
kind create cluster --config kind-expose-port.yaml 
```

Install

* contour
* cert-manager
* kapp-controller
* secretgen-controller

as prerequisites

```
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml
kubectl apply -f https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v0.30.0/release.yml
kubectl apply -f https://github.com/vmware-tanzu/carvel-secretgen-controller/releases/download/v0.7.1/release.yml
```

### Quick Install

```
ytt -f config/code-server.yaml -f config/vaules.yaml -v namespace=developer-env -v suffix=demo1 | kubectl apply -f -
ytt -f config/code-server.yaml -f config/vaules.yaml -v namespace=developer-env -v suffix=demo2 | kubectl apply -f -
```

### Install using Carvel Package

#### Install via kubectl

```
kubectl apply -f demo/namespace-role.yaml
kubectl apply -f demo/package-repository.yaml
kubectl apply -f demo/developer-env-demo1.yaml
kubectl apply -f demo/developer-env-demo2.yaml
```

#### Install via tanzu cli

```
tanzu package repository add making-pkg \
  --url ghcr.io/making/pkg-repo:0.0.3 \
  --namespace developer-env
```

```
$ tanzu package available list -n developer-env
- Retrieving available packages... 
  NAME                      DISPLAY-NAME  SHORT-DESCRIPTION       LATEST-VERSION  
  code-server.pkg.maki.lol  Code Server   VS Code in the browser  0.0.3 

$ tanzu package available get code-server.pkg.maki.lol/0.0.3 --values-schema -n developer-env
| Retrieving package details for code-server.pkg.maki.lol/0.0.3... 
  KEY                              DEFAULT                                 TYPE     DESCRIPTION                                                          
  code_server.external_url_format  https://code-server-{}.localhost.ik.am  string   External URL format                                                  
  code_server.ingress_class        <nil>                                   string   Explicit Ingress class name                                          
  code_server.storage_size         10Gi                                    string   Storage Size                                                         
  code_server.clean                false                                   boolean  Whether to clean extension directory etc.                            
  code_server.create_namespace     true                                    boolean  Whether to create the namespace                                      
  namespace                        demo                                    string   Namespace to install the code server                                 
  resources.limits.cpu             2000m                                   <nil>    Limits describes the maximum amount of cpu resources allowed.        
  resources.limits.memory          4Gi                                     <nil>    Limits describes the maximum amount of memory resources allowed.     
  resources.requests.cpu           1000m                                   <nil>    Requests describes the minimum amount of cpu resources required.     
  resources.requests.memory        2Gi                                     <nil>    Requests describes the minimum amount of memory resources required.  
  suffix                           <nil>                                   string   Suffix of the namespace  
```

```
cat <<EOF > values-demo1.yaml
namespace: developer-env
suffix: demo1
EOF
tanzu package install code-server-demo1 -p code-server.pkg.maki.lol -v 0.0.3 --values-file values-demo1.yaml -n developer-env


cat <<EOF > values-demo2.yaml
namespace: developer-env
suffix: demo2
EOF
tanzu package install code-server-demo2 -p code-server.pkg.maki.lol -v 0.0.3 --values-file values-demo2.yaml -n developer-env
```

### Verify installation

```
$ kubectl get httpproxy -A
NAMESPACE             NAME          FQDN                                TLS SECRET        STATUS   STATUS DESCRIPTION
developer-env-demo1   code-server   code-server-demo1.localhost.ik.am   code-server-tls   valid    Valid HTTPProxy
developer-env-demo2   code-server   code-server-demo2.localhost.ik.am   code-server-tls   valid    Valid HTTPProxy
```

```
$ kubectl get secret -n developer-env-demo1 code-server-password -otemplate='{{.data.password | base64decode}}'
gjknfacl031ndksztukfuxv916exbbjbhdvryaud
$ kubectl get secret -n developer-env-demo2 code-server-password -otemplate='{{.data.password | base64decode}}'
k1rhx2sflv9oohzhaemubdoie6emiuao65kqd962
```

Go to 
* https://code-server-demo1.localhost.ik.am for demo1
* https://code-server-demo2.localhost.ik.am for demo2

## How to configure values

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
    ---
    namespace: developer-env
    suffix: demo1
    code_server:
      external_url_format: https://code-server-{}.default.example.com
      ingress_class: contour-external
```

## Development Note

### How to publish an imgpkg bundle

```
VERSION=0.0.3
docker build -t ghcr.io/making/code-server . 
docker push ghcr.io/making/code-server
kbld -f config/code-server.yaml --imgpkg-lock-output config/.imgpkg/images.yml
imgpkg push -b ghcr.io/making/code-server-bundle:${VERSION} -f config
```

### How to publish a package

```
touch pkg-repo/packages/code-server.pkg.maki.lol/${VERSION}.yml
# Edit ${VERSION}.yml
kbld -f pkg-repo/packages --imgpkg-lock-output pkg-repo/.imgpkg/images.yml
imgpkg push -b ghcr.io/making/pkg-repo:${VERSION} -f pkg-repo
```

Update `demo/*.yaml` and `README.md`