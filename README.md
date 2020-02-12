# Code Server for handson-lab

[Visual Studio Code Server](https://github.com/cdr/code-server) with following tools
* AdoptOpenJDK 11
* `mvn`
* `cf` and `cf7`
* `kubectl`
* `bosh`
* `om`
* `terraform`
* `fly`
* `credhub`
* `jq`
* `yj`
* `ytt`, `kapp`, `kbld`

and following extensions

* [Language support for Java ™ for Visual Studio Code](https://github.com/redhat-developer/vscode-java)
* [Debugger for Java](https://github.com/Microsoft/vscode-java-debug)
* [Java Test Runner](https://github.com/Microsoft/vscode-java-test)
* [Maven for Java](https://github.com/Microsoft/vscode-maven)
* Spring Boot Tools
* [Spring Initializr Java Support](https://github.com/Microsoft/vscode-spring-initializr)
* Spring Boot Dashboard
* Cloudfoundry Manifest YML Support
* Concourse CI Pipeline Editor
* [YAML](https://github.com/redhat-developer/vscode-yaml)

![image](https://user-images.githubusercontent.com/106908/74355988-f7a56680-4e00-11ea-8e6d-c999e7c30cb9.png)
![image](https://user-images.githubusercontent.com/106908/74356021-068c1900-4e01-11ea-88f7-2adfbab723d0.png)

Good for an instant handson-lab environment

## How to run locally

```
docker run --rm -p 8080:8080 making/code-server 
```

The password should be output in the log message.

You can use a custom password as follows:

```
docker run --rm -e PASSWORD=yourpassword -p 8080:8080 making/code-server 
```

## How to push a code server to Cloud Foundry

### To Pivotal Application Service

Make sure your foundation allows to push a docker image

```
$ cf feature-flags | grep docker
diego_docker                                  enabled <--
```

Just cf push!

```
cf push code-server -o making/code-server -m 2g -k 2g --random-route
```

More than 4g would be better for the disk size if allowed.

You'll see your generated password with `cf logs code-server --recent`.

If you want to use a custom password:

```
cf set-env code-server PASSWORD yourpassword
cf restart code-server
```

### To Pivotal Web Services

The way to deploy a code server is as same as Pivotal Application Service above.
However in PWS the load balancer via `80`/`443` port does not support WebSocket, you have to use `8443` port instead.

So go to `https://code-server-<random-words>.cfapps.io:8443/login`.
After login with the correct password, you'll see `ERR_CONNECTION_RESET` as you are redirect to HTTP (not HTTPS).

![image](https://user-images.githubusercontent.com/106908/74356529-d3965500-4e01-11ea-8584-6fe7b11cbedc.png)

Change `http` to `https` in the url bar of the browser, then you'll see the welcome page :)

![image](https://user-images.githubusercontent.com/106908/74356690-1bb57780-4e02-11ea-8e63-93100426e189.png)

## How to build your own docker image

```
docker pull making/coder-server # good for caching
# Add your favorite CLIs to Dockerfile
docker build . -t <your-image-name>
```

> You may reach the API limit of `marketplace.visualstudio.com`. You have to wait until you are released from the limit.