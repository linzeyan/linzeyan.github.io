#!/bin/bash

# Install K3D
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
k3d completion bash >> ~/.bashrc
source ~/.bashrc
k3d cluster create rancher -s 3
k3d kubeconfig merge

# Install Helm
wget https://get.helm.sh/helm-v3.4.2-linux-amd64.tar.gz

# https://rancher.com/docs/rancher/v2.x/en/installation/install-rancher-on-k8s/
# Install Rancher
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update
kubectl create namespace rancher
helm install rancher rancher-latest/rancher \
    --namespace rancher \
    --set hostname=rancher.knowhow.it \
    --set ingress.tls.source=secret \
    --set privateCA=true
kubectl -n rancher create secret tls tls-rancher-ingress \
    --cert=tls.crt \
    --key=tls.key
kubectl -n rancher create secret generic tls-ca \
    --from-file=cacerts.pem=./cacerts.pem
kubectl -n rancher rollout status deploy/rancher
