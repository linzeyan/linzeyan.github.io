---
title: "[Kubernetes] Service Overview"
date: 2021-11-24T14:00:45+08:00
menu:
  sidebar:
    name: "[Kubernetes] Service Overview"
    identifier: k8s-service-overview
    weight: 10
tags: ["URL", "Kubernetes"]
categories: ["URL", "Kubernetes"]
hero: images/hero/kubernetes.png
---

- [[Kubernetes] Service Overview](https://godleon.github.io/blog/Kubernetes/k8s-Service-Overview/)

### 定義 Service

#### 搭配 selector

> 由於要先有 Pod 才會有定義 Service 的需求，因此假設 k8s 中已經有一些 Pod 的存在(同時對外開放 TCP port 9376)，並帶有 app=MyApp 的 label，此時就可以定義一個 Service 來作為這些 pod 前方的抽象層，透過 domain name 的方式提供服務

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  # type 一共有四種(ClusterIP, NodePort, LoadBalancer, ExternalName)
  # 預設是 ClusterIP
  type: ClusterIP
  # 選擇帶有 "app=MyApp" 的 pod
  selector:
    app: MyApp
  # Service 實際對外服務的設定
  ports:
    - protocol: TCP
      port: 80
      # 此為 Pod 對外開放的 port number
      targetPort: 9376
```

`Pod <---> Endpoint(tcp:9376) <---> Service(tcp:80, with VIP)`

- 若是 targetPort 不設定，預設會與 spec.ports.port 相同
- 若 protocol 不設定，預設使用 TCP
- 從 v1.12 開始支援 SCTP(適合用於電信產業 or 提供串流服務時使用)，但預設關閉，需要透過 SCTPSupport feature gate 開啟

#### 不與 selector 搭配

> 一般 Service 是作為 存取 pod 用的抽象層，但其實作為其他 backend 的抽象層，而這一類的需求可能來自於下列的情況：
>
> - 在生產環境中有個 external database，但在測試環境中是使用 internal database
>
> - 想要將 Service 指到位於其他 namespace or cluster 中的 service
>
> - 想要將某些 workload 移到 k8s 上面跑，但有些 backend service 依然還在 k8s 之外

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
```

由於沒有設定 label selector，因此也就不會產生相對應的 endpoint，此時我們就需要自己建立一個 Endpoint resource object，並指到真正的 backend service

```yaml
kind: Endpoints
apiVersion: v1
metadata:
  name: my-service
subsets:
  - addresses:
      - ip: 1.2.3.4
    ports:
      - port: 9376
```

透過以上兩組設定，就可以將到達 my-service 的網路流量導向 1.2.3.4:9376 去。

另外，在設定 Endpoint 時有幾點需要注意：

- 不能使用 loopback (127.0.0.0/8), link-local (169.254.0.0/16), or link-local multicast (224.0.0.0/24) … 等幾段 IP
- 也不能使用設定在 k8s 中的 cluster ip 網段

以上的範例的 service type 皆為 ClusterIP；另外還有一種稱為 ExternalName，同樣也是沒有 selector 但以 DNS name 為基礎來進行設定

### Service Types

上面所介紹的部份，其實都是屬於 ClusterIP type 的 service，但其實 service type 一共有四種，分別是：

- ClusterIP：提供 cluster 內部存取
- NodePort：供外部存取
- LoadBalancer：供外部存取 (但只限於支援此 type 的 public cloud)
- ExternalName：單純回應給 client 外部的 DNS CName record (並非由 k8s cluster 內部的 pod 服務)

#### ClusterIP

> 只是必須注意的是，將 type 設定為 ClusterIP 的 service，只能在 k8s cluster 內部存取；若是要提供給外部存取，則是要使用下面介紹的 NodePort & LoadBalancer 兩種 service type

#### NodePort

> 在私有內部的環境中，要讓 k8s cluster 外部存取佈署好的 pod，透過 NodePort type service 是其中一個方式，以下是一個設定 NodePort type service 的簡單範例

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-nodeport-service
spec:
  # 將 type 設定為 NodePort
  type: NodePort
  # 選擇帶有 "app=MyApp" 的 pod
  selector:
    app: MyApp
  # Service 實際對外服務的設定
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
      # 指定 NodePort number(.spec.ports[*].nodePort)
      # 也可不指定(30000~32767)
      nodePort: 30036
```

```bash
$ kubectl get all
NAME                          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
.... (略)
service/my-nodeport-service   NodePort    10.233.44.13   <none>        80:30036/TCP   7s

```

kube-proxy 還會在每個 node 上放上相對應的 iptables rule

```bash
# 不僅放上規則，還會附帶清楚的註解
$ iptables-save | grep my-nodeport-service
-A KUBE-EXTERNAL-SERVICES -p tcp -m comment --comment "default/my-nodeport-service: has no endpoints" -m addrtype --dst-type LOCAL -m tcp --dport 30036 -j REJECT --reject-with icmp-port-unreachable
-A KUBE-SERVICES -d 10.233.44.13/32 -p tcp -m comment --comment "default/my-nodeport-service: has no endpoints" -m tcp --dport 80 -j REJECT --reject-with icmp-port-unreachable

```

最後，NodePort service 在使用上有以下幾個重點需要注意：

- NodePort 所分配到的 port number 是從 API server 啟動參數中的 `--service-node-port-range` 來的，預設是 `30000 ~ 32767`
- 若要自訂 NodePort number，則是在 Service 中定義 `.spec.ports[*].nodePort` (只能使用在上面定義的範圍內的 port number)
- NodePort 預設的有效範圍是 node 的所有 interface
- 若希望只由特定的 IP 來處理 NodePort 的流量，可透過 API server 啟動參數中的 `--nodeport-addresses` 來指定(例如：使用 `--nodeport-addresses=127.0.0.0/8` 表示所有 NodePort 流量都會有 loopback interface 來處理)
- 設定 NodePort 後，可以透過兩種方式存取 Service，分別是 `<NodeIP>:spec.ports[*].nodePort` & `.spec.clusterIP:spec.ports[*].port`

#### Load Balancer

> Load Balancer type 是另一個讓外部可以直接存取 cluster 內部 service 的方式。
>
> 但這個 Service Type 需要與外部的 load balancer 服務搭配，因此目前僅有在 public cloud or OpenStack 上才有支援

#### ExternalName

> ExternalName 的設定其實就是把 Service 導向指定的 DNS name，而不是 service 中 label selector 所設定的 pod

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service
  namespace: prod
spec:
  type: ExternalName
  externalName: my.database.example.com
```

當 cluster 內部查找 my-service.prod.svc 的時候，k8s DNS service 就只會回應 my.database.example.com 這個 CNAME recrd。

但回應 CNAME record 跟其他 type 有何差別? 其實就是當存取 ExternalName type 的 service 時，網路流量的導向是發生在 DNS level 而不是透過 proxying or forwarding 達成的。

<mark>注意! 若要使用 ExternalName，k8s DNS service 的部份僅能安裝 kube-dns，且版本需要是 1.7 以上</mark>

#### External IP

> 這不算是一個 service type，但可以讓使用者指定 service 要黏在哪個 IP 上

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  selector:
    app: MyApp
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 9376
  # 此 service 只會將進入 80.11.12.10:80 的 網路流量
  # 導向後端的 endpoints
  externalIPs:
    - 80.11.12.10
```

透過以上設定，service 只會將進入 80.11.12.10:80 的 網路流量導向使用 Label Selector 選出來的 endpoint(Pod) 中。

而需要注意的是，External IP 的部份並不屬於 k8s 個管理範圍內，使用者若要使用就必須自己負責管理好這個部份。
