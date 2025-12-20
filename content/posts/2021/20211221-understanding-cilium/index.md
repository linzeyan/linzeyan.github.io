---
title: "【理解 Cilium 系列文章】(一) 初識 Cilium"
date: 2021-12-21T13:04:38+08:00
menu:
  sidebar:
    name: "【理解 Cilium 系列文章】(一) 初識 Cilium"
    identifier: k8s-network-cilium-introduce
    weight: 10
tags: ["URL", "Kubernetes", "Cilium", "Network"]
categories: ["URL", "Kubernetes", "Cilium", "Network"]
hero: images/hero/kubernetes.png
---

- [【理解 Cilium 系列文章】(一) 初識 Cilium](https://www.gushiciku.cn/pl/geTr/zh-hk)

#### 當前 k8s Service 負載均衡的實現現狀

在 Cilium 出現之前， Service 由 kube-proxy 來實現，實現方式有 userspace ， iptables ， ipvs 三種模式。

##### Userspace

當前模式下，kube-proxy 作為反向代理,監聽隨機端口，通過 iptables 規則將流量重定向到代理端口，再由 kube-proxy 將流量轉發到 後端 pod。Service 的請求會先從用户空間進入內核 iptables，然後再回到用户空間，代價較大，性能較差。

##### Iptables

存在的問題：

1.可擴展性差。隨着 service 數據達到數千個，其控制面和數據面的性能都會急劇下降。原因在於 iptables 控制面的接口設計中，每添加一條規則，需要遍歷和修改所有的規則，其控制面性能是 O(n²) 。在數據面，規則是用鏈表組織的，其性能是 O(n)

2.LB 調度算法僅支持隨機轉發

##### Ipvs 模式

IPVS 是專門為 LB 設計的。它用 hash table 管理 service，對 service 的增刪查找都是 O(1)的時間複雜度。不過 IPVS 內核模塊沒有 SNAT 功能，因此借用了 iptables 的 SNAT 功能。

IPVS 針對報文做 DNAT 後，將連接信息保存在 nf_conntrack 中，iptables 據此接力做 SNAT。該模式是目前 Kubernetes 網絡性能最好的選擇。但是由於 nf_conntrack 的複雜性，帶來了很大的性能損耗。騰訊針對該問題做過相應的優化 【繞過 conntrack，使用 eBPF 增強 IPVS 優化 K8s 網絡性能】

##### Cilium

Cilium 是基於 eBpf 的一種開源網絡實現，通過在 Linux 內核動態插入強大的安全性、可見性和網絡控制邏輯，提供網絡互通，服務負載均衡，安全和可觀測性等解決方案。簡單來説可以理解為 Kube-proxy + CNI 網絡實現。

Cilium 位於容器編排系統和 Linux Kernel 之間，向上可以通過編排平台為容器進行網絡以及相應的安全配置，向下可以通過在 Linux 內核掛載 eBPF 程序，來控制容器網絡的轉發行為以及安全策略執行

- linux 內核要求 `4.19` 及以上
- 可以採用 helm 或者 cilium cli ，此處筆者使用的是 cilium cli （版本為 1.10.3 ）

```bash
# 下載 cilium cli
wget https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz
tar xzvfC cilium-linux-amd64.tar.gz /usr/local/bin

# 安裝 cilium
cilium install --kube-proxy-replacement=strict # 此處選擇的是完全替換，默認情況下是 probe，(該選項下 pod hostport 特性不支持)

# 可視化組件 hubble(選裝)
cilium hubble enable --ui

# pod ready 後，查看 狀態如下
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
