---
title: "Argo CD ApplicationSet Controller: 世界為我而轉動！"
date: 2021-12-27T09:41:03+08:00
menu:
  sidebar:
    name: "Argo CD ApplicationSet Controller: 世界為我而轉動！"
    identifier: k8s-argo-cd-applicationset-controller
    weight: 10
tags: ["URL", "Kubernetes", "Argo CD", "GitOps"]
categories: ["URL", "Kubernetes", "Argo CD", "GitOps"]
hero: images/hero/kubernetes.png
---

- [Argo CD ApplicationSet Controller: 世界為我而轉動！](https://medium.com/starbugs/argo-cd-applicationset-controller-%E4%B8%96%E7%95%8C%E7%82%BA%E6%88%91%E8%80%8C%E8%BD%89%E5%8B%95-a837f9392298)
- [Argo CD](https://github.com/argoproj/argo-cd)

```bash
# 安裝 kind，其他平台安裝方式請參閱官方文件
# 用來運行輕量 K8s Cluster 於本地端
~$ brew install kind
# 安裝 kubectx，其他平台安裝方式請參閱官方文件
# 用來方便切換不同 k8s context
~$ brew install kubectx
# 安裝 helm，其他平台安裝方式請參閱官方文件
# K8s 套件管理工具
~$ brew install helm
# 安裝 kubectl, 其他平台安裝方式請參閱官方文件
# 用來與 K8s Cluster API Server 溝通
~$ brew install kubectl
# 安裝 argocd cli, 其他平台安裝方式請參閱官方文件
# 用來與 Argo CD 溝通
~$ brew install argocd
```
