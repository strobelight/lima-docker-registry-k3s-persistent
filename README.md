# lima-docker-registry-k3s-persistent
Start lima with docker and k3s, with amd64 and arm architecture, mounting the docker directory of root and user to external disk, start docker registry and ui to it. Based off of some [lima examples](https://github.com/lima-vm/lima/tree/master/examples).

## Pre-requisites
* `brew install docker`
* `brew install kubernetes-cli`
* `brew install lima`
* PATH updated for access to docker, limactl and kubectl

## Start
`./startK3sMultiDocker [cluster-name]`

This creates 20G disk for mounting of docker directories (holding your images for persistency across instance deletes), starts lima, docker, k3s, and a docker registry with a UI available on http://localhost:8080.

If `cluster-name` not provided, it defaults to `k3smulti`. A user of the same name is created with the certs for access.

`./restartInstance`

This restarts an instance that has been stopped.

## Stop
`./stopDeleteInstance`

This stops the instance and deletes it.

`./stopInstance`

This stops the instance.

## Other files
### docker-k3s-multiarch.yaml
The yaml used by `startK3sMultiDocker` to start qemu, docker, k3s, etc.
### startRegistry
A supporting script called by `startK3sMultiDocker` and `restartInstance` that starts a docker registry and a UI that can access it too.
### test/run-hello.sh
A test script that runs the `hello-world` in k3s. `hello-world` is pulled, tagged with a bogus 1.2.3 revision, and pushed to the local docker registry that should be accessible from k3s. Logs are pulled in a loop to see its output. The pod is terminated after 5 minutes or you can press ctrl-C.

## Registry
The registry needs some poking to clean up after deletes:
```
docker exec registry registry garbage-collect /etc/docker/registry/config.yml
```

Unfortuneately, _folders_ are not removed (near as I can tell).

## Cross-platform builds

This lima contains both a qemu-amd64 and qemu-arm64, and the right one will be started for your platform (arm64 in the case of M1 or M2). This means however that builds will also be on the default platform instead of amd64 that RDEI expects.

Here are several ways to affect the resulting platform architecture of a build:

* Dockerfile:
```
FROM --platform=linux/arm64 python:3.7-alpine
FROM --platform=linux/amd64 python:3.7-alpine
```
* Environment Variable:
```
export DOCKER_DEFAULT_PLATFORM=linux/arm64
export DOCKER_DEFAULT_PLATFORM=linux/amd64
```
* On build line:
```
docker buildx build --platform linux/arm64 ...
docker buildx build --platform linux/amd64 ...
```
* In docker-compose.yaml:
```
services:
  blah:
    platform: linux/amd64
    #platform: linux/arm64
  ...
```
