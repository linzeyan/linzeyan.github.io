---
title: "Kubernetes Without kube-proxy"
date: 2021-12-20T17:57:13+08:00
menu:
  sidebar:
    name: "Kubernetes Without kube-proxy"
    identifier: k8s-network-cilium-kube-proxy-free
    weight: 10
tags: ["URL", "Kubernetes", "Cilium", "Network"]
categories: ["URL", "Kubernetes", "Cilium", "Network"]
hero: images/hero/kubernetes.png
---

- [Kubernetes Without kube-proxy](https://docs.cilium.io/en/v1.9/gettingstarted/kubeproxy-free/)

#### Quick-Start

```bash
kubeadm init --skip-phases=addon/kube-proxy

# Setup Helm repository
helm repo add cilium https://helm.cilium.io/


helm install cilium cilium/cilium --version 1.9.18 \
    --namespace kube-system \
    --set kubeProxyReplacement=strict \
    --set k8sServiceHost=REPLACE_WITH_API_SERVER_IP \
    --set k8sServicePort=REPLACE_WITH_API_SERVER_PORT

```
