# lima-docker-registry-k3s-persistent
Start lima with docker and k3s, with amd64 and arm architecture, mounting the docker directory of root and user to external disk, start docker registry and ui to it.

## Pre-requisites
* `brew install docker`
* `brew install kubernetes-cli`
* `brew install lima`
* PATH updated for access to docker, limactl and kubectl

## Start
`./startK3sMultiDocker`

This creates 10G disk for mounting of docker directories (holding your images for persistency across instance deletes), starts lima, docker, k3s, and a docker registry with a UI available on http://localhost:8080.

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
