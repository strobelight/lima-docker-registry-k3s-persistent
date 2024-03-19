#!/bin/bash

REPO=localhost:5000
TAG=hello-world
if [ ! -f hello.yaml ]; then
    cat <<EOF > hello.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    app: $TAG
  name: $TAG
spec:
  containers:
  - image: $REPO/$TAG:1.2.3
    name: $TAG
    resources: {}
  restartPolicy: Never
status: {}
EOF
fi
kubectl apply -f hello.yaml
for i in `seq 1 5`; do
    sleep .5
    kubectl logs $TAG
done
cleanup() {
    trap - 0 1 2 3 15 21 22
    cat <<-EOF
	
	
	If you see the following above:
	
	    Hello from Docker!
	    This message shows that your installation appears to be working correctly.
	
	GREAT! Your registry is accessible to k3s
	
	otherwise, something went wrong.
	
	EOF
    kubectl delete -f hello.yaml
}

trap cleanup 0 1 2 3 15 21 22
echo "ctrl-c to quit, otherwise in 15 seconds it'll quit"
sleep 15s
