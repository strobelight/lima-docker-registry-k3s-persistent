# lima-docker-registry-k3s-persistent
Start lima with docker and k3s, with amd64 and arm architecture, mounting the docker directory of root and user to external disk, start docker registry and ui to it. Based off of some [lima examples](https://github.com/lima-vm/lima/tree/master/examples).

## Pre-requisites
* `brew install docker`
* `brew install kubernetes-cli`
* `brew install lima  # also installs qemu`
* `brew install socket_vmnet`
* PATH updated for access to docker, limactl and kubectl

### Checks
Run `limactl sudoers --check` several times until it's happy.

For example, I had to modify `~/.lima/_config/networks.yaml` and changed the following:
```
  socketVMNet: "/usr/local/Cellar/socket_vmnet/1.1.0/bin/socket_vmnet"
```

The check isn't happy about symbolic links so if `socket_vmnet` gets updated, you'll need to do this again.

Then it complained about sudoers being out of sync, so I ran the command it said to, but need to add `$PWD/` for the install:

```
limactl sudoers >etc_sudoers.d_lima && sudo install -o root $PWD/etc_sudoers.d_lima "/private/etc/sudoers.d/lima"
```

Finally the check passed with `is up-to-date`.

## Start
`./startK3sMultiDocker [cluster-name]`

This creates 40G disk for mounting of docker directories (holding your images for persistency across instance deletes), starts lima, docker, k3s, and a docker registry with a UI available on http://localhost:8080.

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
### docker-k3s-multiarch-rootful.yaml
If you need dockerd to run as root, `export QEMU_YAML="./docker-k3s-multiarch-rootful.yaml"` before running `startK3sMultiDocker`.
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
