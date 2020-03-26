# Kubernetes Debug Tool

## Tools

* Docker Engine
* AWS CLI
* Python, pip
* git
* cUrl
* wget
* bash
* aws-iam-authenticator

```docker
docker build -t alpine-kube-tools:0.0.1 .

docker image tag alpine-kube-tools:0.0.1 evgmoskalenko/alpine-kube-tools:0.0.1

docker push evgmoskalenko/alpine-kube-tools:0.0.1
```

```kubernetes helm
kubectl run -i -t --image=evgmoskalenko/alpine-kube-tools:0.0.1 --restart=Never debug -n default

kubectl delete deployment debug -n default
```