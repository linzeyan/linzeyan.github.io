---
title: "[Kubernetes] Service Overview"
date: 2021-11-24T14:00:45+08:00
menu:
  sidebar:
    name: "[Kubernetes] Service Overview"
    identifier: k8s-service-overview
    weight: 10
tags: ["Links", "Kubernetes"]
categories: ["Links", "Kubernetes"]
hero: images/hero/kubernetes.png
---

- [[Kubernetes] Service Overview](https://godleon.github.io/blog/Kubernetes/k8s-Service-Overview/)

### Define Service

#### With selector

> Since you need Pods before you define a Service, assume there are Pods in the cluster (exposing TCP port 9376) with the label app=MyApp. You can define a Service as an abstraction layer in front of those pods and provide the service through a domain name.

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-service
spec:
  # type has four options (ClusterIP, NodePort, LoadBalancer, ExternalName)
  # default is ClusterIP
  type: ClusterIP
  # select pods with "app=MyApp"
  selector:
    app: MyApp
  # Service port configuration
  ports:
    - protocol: TCP
      port: 80
      # This is the port number exposed by the Pod
      targetPort: 9376
```

`Pod <---> Endpoint(tcp:9376) <---> Service(tcp:80, with VIP)`

- If targetPort is not set, it defaults to spec.ports.port
- If protocol is not set, it defaults to TCP
- SCTP is supported since v1.12 (suitable for telecom or streaming), but it is disabled by default and must be enabled via the SCTPSupport feature gate

#### Without selector

> A Service is usually an abstraction for accessing pods, but it can also be an abstraction for other backends. This can happen in the following situations:
>
> - There is an external database in production, but an internal database in testing
>
> - You want the Service to point to a service in another namespace or cluster
>
> - You want to move some workloads to k8s, but some backend services remain outside k8s

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

Since no label selector is set, no endpoint is created. You must create an Endpoint resource object yourself and point it to the real backend service.

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

With the two configurations above, traffic to my-service is routed to 1.2.3.4:9376.

When configuring Endpoints, note the following:

- You cannot use loopback (127.0.0.0/8), link-local (169.254.0.0/16), or link-local multicast (224.0.0.0/24) IP ranges
- You also cannot use the cluster IP ranges configured in k8s

The examples above are all ClusterIP services. There is also ExternalName, which has no selector but is configured with a DNS name.

### Service Types

The examples above are all ClusterIP services, but there are four service types:

- ClusterIP: accessible within the cluster
- NodePort: accessible from outside
- LoadBalancer: accessible from outside (only on public clouds that support this type)
- ExternalName: returns a DNS CNAME record to clients (not served by pods inside the k8s cluster)

#### ClusterIP

> A ClusterIP service can only be accessed inside the cluster. For external access, use NodePort or LoadBalancer services.

#### NodePort

> In a private internal environment, exposing pods outside the k8s cluster via a NodePort service is one way. Below is a simple example of a NodePort service.

```yaml
kind: Service
apiVersion: v1
metadata:
  name: my-nodeport-service
spec:
  # Set type to NodePort
  type: NodePort
  # select pods with "app=MyApp"
  selector:
    app: MyApp
  # Service port configuration
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
      # Specify NodePort number (.spec.ports[*].nodePort)
      # Or omit (30000-32767)
      nodePort: 30036
```

```bash
$ kubectl get all
NAME                          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
.... (略)
service/my-nodeport-service   NodePort    10.233.44.13   <none>        80:30036/TCP   7s

```

kube-proxy also installs the corresponding iptables rules on each node.

```bash
# Not only adds rules, but also adds clear comments
$ iptables-save | grep my-nodeport-service
-A KUBE-EXTERNAL-SERVICES -p tcp -m comment --comment "default/my-nodeport-service: has no endpoints" -m addrtype --dst-type LOCAL -m tcp --dport 30036 -j REJECT --reject-with icmp-port-unreachable
-A KUBE-SERVICES -d 10.233.44.13/32 -p tcp -m comment --comment "default/my-nodeport-service: has no endpoints" -m tcp --dport 80 -j REJECT --reject-with icmp-port-unreachable

```

Finally, here are a few key points about NodePort services:

- NodePort is allocated from the API server flag `--service-node-port-range`, default is `30000 ~ 32767`
- To customize the NodePort, define `.spec.ports[*].nodePort` (must be within the above range)
- NodePort is effective on all node interfaces by default
- To restrict NodePort traffic to specific IPs, use the API server flag `--nodeport-addresses` (for example, `--nodeport-addresses=127.0.0.0/8` means all NodePort traffic is handled by the loopback interface)
- After setting NodePort, you can access the Service via `<NodeIP>:spec.ports[*].nodePort` and `.spec.clusterIP:spec.ports[*].port`

#### Load Balancer

> LoadBalancer is another way to allow external access to services inside the cluster.
>
> This service type requires an external load balancer, so currently only public clouds or OpenStack support it.

#### ExternalName

> ExternalName config points the Service to a specified DNS name rather than the pods selected by the Service label selector.

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

When looking up my-service.prod.svc inside the cluster, the k8s DNS service returns the CNAME record my.database.example.com.

The difference is that traffic routing for an ExternalName service happens at the DNS level rather than via proxying or forwarding.

<mark>Note! To use ExternalName, the k8s DNS service must be kube-dns and the version must be 1.7 or later.</mark>

#### External IP

> This is not a service type, but it lets users specify which IP a Service should bind to.

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
  # This service only routes traffic entering 80.11.12.10:80
  # to the backend endpoints
  externalIPs:
    - 80.11.12.10
```

With the configuration above, the service only routes traffic entering 80.11.12.10:80 to endpoints (pods) selected by the label selector.

Note that External IPs are not managed by k8s. If you want to use them, you must manage them yourself.
