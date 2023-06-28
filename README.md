# Docker image for Gitolite

This image allows you to run a git server in a container with OpenSSH and [Gitolite](https://github.com/sitaramc/gitolite#readme).

Based on Alpine Linux.

## Quick setup

Create volumes for your SSH server host keys and for your Gitolite config and repositories

* Docker >= 1.9

        docker volume create --name gitolite-sshkeys
        docker volume create --name gitolite-git

* Docker < 1.9

        docker create --name gitolite-data -v /etc/ssh/keys -v /var/lib/git tianon/true

Setup Gitolite with yourself as the administrator:

* Docker >= 1.10

        docker run --rm -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" -e SSH_KEY_NAME="$(whoami)" -v gitolite-sshkeys:/etc/ssh/keys -v gitolite-git:/var/lib/git jgiannuzzi/gitolite true

* Docker == 1.9 (There is a bug in `docker run --rm` that removes volumes when removing the container)

        docker run --name gitolite-setup -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" -e SSH_KEY_NAME="$(whoami)" -v gitolite-sshkeys:/etc/ssh/keys -v gitolite-git:/var/lib/git jgiannuzzi/gitolite true
        docker rm gitolite-setup

* Docker < 1.9

        docker run --rm -e SSH_KEY="$(cat ~/.ssh/id_rsa.pub)" -e SSH_KEY_NAME="$(whoami)" --volumes-from gitolite-data jgiannuzzi/gitolite true

Finally run your Gitolite container in the background:

* Docker >= 1.9

        docker run -d --name gitolite -p 22:22 -v gitolite-sshkeys:/etc/ssh/keys -v gitolite-git:/var/lib/git jgiannuzzi/gitolite

* Docker < 1.9

        docker run -d --name gitolite -p 22:22 --volumes-from gitolite-data jgiannuzzi/gitolite

You can then add users and repos by following the [official guide](https://github.com/sitaramc/gitolite#adding-users-and-repos).




## gcloud: docker

https://console.cloud.google.com/artifacts/browse/citros?project=citros&supportedpurview=project

```bash
# if building from linux machine
docker build -t citros-docker-gitolite . 
# *** when building from MAC M1 chip add FROM --platform=linux/amd64 ***
docker buildx build --platform linux/amd64 -t citros-docker-gitolite .   

docker tag citros-docker-gitolite registry.local:32000/citros/citros-docker/citros-docker-gitolite
docker push registry.local:32000/citros/citros-docker/citros-docker-gitolite

# upload to google artifact registry
docker tag citros-docker-gitolite us-central1-docker.pkg.dev/citros/citros-docker/citros-docker-gitolite
docker push us-central1-docker.pkg.dev/citros/citros-docker/citros-docker-gitolite
```