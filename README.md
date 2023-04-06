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
