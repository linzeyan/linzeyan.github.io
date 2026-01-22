---
title: "不使用 kube-proxy 的 Kubernetes"
date: 2021-12-20T17:57:13+08:00
menu:
  sidebar:
    name: "不使用 kube-proxy 的 Kubernetes"
    identifier: k8s-network-cilium-kube-proxy-free
    weight: 10
tags: ["Links", "Kubernetes", "Cilium", "Network"]
categories: ["Links", "Kubernetes", "Cilium", "Network"]
hero: images/hero/kubernetes.png
---

- [不使用 kube-proxy 的 Kubernetes](https://docs.cilium.io/en/v1.9/gettingstarted/kubeproxy-free/)

#### 快速開始

```bash
kubeadm init --skip-phases=addon/kube-proxy

# 設定 Helm 倉庫
helm repo add cilium https://helm.cilium.io/


helm install cilium cilium/cilium --version 1.9.18 \
    --namespace kube-system \
    --set kubeProxyReplacement=strict \
    --set k8sServiceHost=REPLACE_WITH_API_SERVER_IP \
    --set k8sServicePort=REPLACE_WITH_API_SERVER_PORT

```
