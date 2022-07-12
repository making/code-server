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
tanzu package repository add code-server-repo \
  --url ghcr.io/making/code-server-repo:0.0.12 \
  --namespace developer-env
```

```
$ tanzu package available list -n developer-env
- Retrieving available packages... 
  NAME                      DISPLAY-NAME  SHORT-DESCRIPTION       LATEST-VERSION  
  code-server.pkg.maki.lol  Code Server   VS Code in the browser  0.0.12  

$ tanzu package available get code-server.pkg.maki.lol/0.0.12 --values-schema -n developer-env
| Retrieving package details for code-server.pkg.maki.lol/0.0.12... 
  KEY                              DEFAULT                         TYPE     DESCRIPTION                                                          
  code_server.external_url_format  https://code-server-{}.vcap.me  string   External URL format                                                  
  code_server.ingress_class        <nil>                           string   Explicit Ingress class name                                          
  code_server.storage_size         10Gi                            string   Storage Size                                                         
  code_server.clean                false                           boolean  Whether to clean extension directory etc.                            
  code_server.clusterissuer        <nil>                           string   ClusterIssuer name to generate the code server's certificate         
  code_server.create_namespace     true                            boolean  Whether to create the namespace                                      
  namespace                        demo                            string   Namespace to install the code server                                 
  resources.limits.memory          4Gi                             string   Limits describes the maximum amount of memory resources allowed.     
  resources.limits.cpu             2000m                           string   Limits describes the maximum amount of cpu resources allowed.        
  resources.requests.memory        2Gi                             string   Requests describes the minimum amount of memory resources required.  
  resources.requests.cpu           1000m                           string   Requests describes the minimum amount of cpu resources required.     
  suffix                           <nil>                           string   Suffix of the namespace
```

```
cat <<EOF > values-demo1.yaml
namespace: developer-env
suffix: demo1
EOF
tanzu package install code-server-demo1 -p code-server.pkg.maki.lol -v 0.0.12 --values-file values-demo1.yaml -n developer-env


cat <<EOF > values-demo2.yaml
namespace: developer-env
suffix: demo2
EOF
tanzu package install code-server-demo2 -p code-server.pkg.maki.lol -v 0.0.12 --values-file values-demo2.yaml -n developer-env
```

### Verify installation

```
$ kubectl get ingress -A                    
NAMESPACE             NAME          CLASS    HOSTS                       ADDRESS          PORTS     AGE
developer-env-demo1   code-server   <none>   code-server-demo1.vcap.me   *******          80, 443   8m46s
developer-env-demo2   code-server   <none>   code-server-demo2.vcap.me   *******          80, 443   4m22s
```

```
$ kubectl get secret -n developer-env-demo1 code-server-password -otemplate='{{.data.password | base64decode}}'
gjknfacl031ndksztukfuxv916exbbjbhdvryaud
$ kubectl get secret -n developer-env-demo2 code-server-password -otemplate='{{.data.password | base64decode}}'
k1rhx2sflv9oohzhaemubdoie6emiuao65kqd962
```

Go to 
* https://code-server-demo1.vcap.me for demo1
* https://code-server-demo2.vcap.me for demo2


You can install Tanzu VSCode Extensions using runnning `install-tanzu-vscode-extension.sh` on the home directory. You will be prompted for the TanzuNet API Token and the target TAP version.

Inner Loop Development on the VS Code Server is available.

<img width="1024" alt="image" src="https://user-images.githubusercontent.com/106908/178522858-d6d2446b-286e-40b8-abdb-1cc9261352ea.png">


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
VERSION=0.0.12
docker build -t ghcr.io/making/code-server . 
docker push ghcr.io/making/code-server
kbld -f config/code-server.yaml --imgpkg-lock-output config/.imgpkg/images.yml
imgpkg push -b ghcr.io/making/code-server-bundle:${VERSION} -f config
```

### How to publish a package

```
ytt -f config/vaules.yaml --data-values-schema-inspect -o openapi-v3 > /tmp/schema-openapi.yml
ytt -f package-template.yml  --data-value-file openapi=/tmp/schema-openapi.yml -v version=${VERSION} > pkg-repo/packages/code-server.pkg.maki.lol/${VERSION}.yml
kbld -f pkg-repo/packages --imgpkg-lock-output pkg-repo/.imgpkg/images.yml
imgpkg push -b ghcr.io/making/code-server-repo:${VERSION} -f pkg-repo
```

Update `demo/*.yaml` and `README.md`
