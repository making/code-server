# Code Server


```
mkdir $HOME/workspace
docker run \
  --rm \
  -p 8080:8080 \
  -e PASSWORD=password  \
  -v $HOME/workspace:/home/coder/workspace \
  -v $HOME/.m2:/home/coder/.m2 \
  ghcr.io/making/code-server
```