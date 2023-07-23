# Docker image for Gitolite

This image allows you to run a git server in a container with OpenSSH and [Gitolite](https://github.com/sitaramc/gitolite#readme).

Based on Alpine Linux.


## gcloud: docker

https://console.cloud.google.com/artifacts/browse/citros?project=citros&supportedpurview=project

```bash
# if building from linux machine
docker build -t citros-gitolite-docker . 
# *** when building from MAC M1 chip add FROM --platform=linux/amd64 ***
docker buildx build --platform linux/amd64 -t citros-gitolite-docker .   

docker tag citros-gitolite-docker registry.local:32000/citros/citros-docker/citros-gitolite-docker
docker push registry.local:32000/citros/citros-docker/citros-gitolite-docker

# upload to google artifact registry
docker tag citros-gitolite-docker us-central1-docker.pkg.dev/citros/citros-docker/citros-gitolite-docker
docker push us-central1-docker.pkg.dev/citros/citros-docker/citros-gitolite-docker
```