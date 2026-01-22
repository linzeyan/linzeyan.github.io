---
title: "Understanding Cilium Series (1): Introduction to Cilium"
date: 2021-12-21T13:04:38+08:00
menu:
  sidebar:
    name: "Understanding Cilium Series (1): Introduction to Cilium"
    identifier: k8s-network-cilium-introduce
    weight: 10
tags: ["Links", "Kubernetes", "Cilium", "Network"]
categories: ["Links", "Kubernetes", "Cilium", "Network"]
hero: images/hero/kubernetes.png
---

- [Understanding Cilium Series (1): Introduction to Cilium](https://www.gushiciku.cn/pl/geTr/zh-hk)

#### Current status of k8s Service load balancing implementations

Before Cilium, Services were implemented by kube-proxy in three modes: userspace, iptables, and ipvs.

##### Userspace

In this mode, kube-proxy acts as a reverse proxy and listens on random ports. It redirects traffic to the proxy port via iptables rules, and kube-proxy forwards the traffic to backend pods. Service requests go from user space into kernel iptables and then back to user space, which is costly and has poor performance.

##### Iptables

Problems:

1. Poor scalability. As the number of services grows into the thousands, control plane and data plane performance drop sharply. In the iptables control plane interface design, adding a rule requires traversing and modifying all rules, so control plane performance is O(n^2). In the data plane, rules are organized as a linked list, so performance is O(n).

2. The LB scheduling algorithm only supports random forwarding.

##### Ipvs mode

IPVS is designed specifically for LB. It uses a hash table to manage services, so service add/delete/lookup are O(1). However, the IPVS kernel module does not provide SNAT, so it borrows SNAT from iptables.

After IPVS performs DNAT on packets, it stores connection information in nf_conntrack, and iptables then performs SNAT. This mode is currently the best choice for Kubernetes network performance. However, nf_conntrack complexity introduces significant overhead. Tencent has optimized this issue ("Bypass conntrack, use eBPF to enhance IPVS and optimize K8s network performance").

##### Cilium

Cilium is an open-source networking implementation based on eBPF. It dynamically inserts powerful security, visibility, and network control logic into the Linux kernel to provide network connectivity, service load balancing, security, and observability. In simple terms, it can be viewed as a Kube-proxy + CNI networking implementation.

Cilium sits between the container orchestration system and the Linux kernel. Upward, it configures networking and security for containers via the orchestration platform. Downward, it mounts eBPF programs in the Linux kernel to control container network forwarding behavior and policy enforcement.

- Linux kernel version must be `4.19` or later
- You can use helm or the cilium cli; here I use the cilium cli (version 1.10.3)

```bash
# Download the cilium cli
wget https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz
tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin

# Install cilium
cilium install --kube-proxy-replacement=strict # Fully replace kube-proxy; default is probe (hostport is not supported in this mode)

# Optional visualization component: hubble
cilium hubble enable --ui

# After pods are ready, the status looks like this
~# cilium status
    /¯¯
 /¯¯__/¯¯    Cilium:         OK
 __/¯¯__/    Operator:       OK
 /¯¯__/¯¯    Hubble:         OK
 __/¯¯__/    ClusterMesh:    disabled
    __/

DaemonSet         cilium             Desired: 1, Ready: 1/1, Available: 1/1
Deployment        cilium-operator    Desired: 1, Ready: 1/1, Available: 1/1
Deployment        hubble-relay       Desired: 1, Ready: 1/1, Available: 1/1
Containers:       hubble-relay       Running: 1
                  cilium             Running: 1
                  cilium-operator    Running: 1
Image versions    cilium             quay.io/cilium/cilium:v1.10.3: 1
                  cilium-operator    quay.io/cilium/operator-generic:v1.10.3: 1
                  hubble-relay       quay.io/cilium/hubble-relay:v1.10.3: 1
```
