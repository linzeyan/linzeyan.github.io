---
title: "Tuning EMQX to Scale to One Million Concurrent Connection on Kubernetes"
date: 2023-09-27T10:36:00+08:00
menu:
  sidebar:
    name: Tuning EMQX to Scale to One Million Concurrent Connection on Kubernetes
    identifier: tune-mqtt-emqx
    weight: 10
tags: ["Kubernetes", "MQTT", "EMQX", "Linux", "URL"]
categories: ["Kubernetes", "MQTT", "EMQX", "Linux", "URL"]
hero: images/hero/linux.png
---

- [Tuning EMQX to Scale to One Million Concurrent Connection on Kubernetes](https://www.infracloud.io/blogs/scale-emqx-one-million-connections-kubernetes/)
- [Performance Tuning (Linux)](https://www.emqx.io/docs/en/v5.2/performance/tune.html#linux-kernel-tuning)
- [矽谷牛的耕田筆記](https://www.facebook.com/technologynoteniu/posts/pfbid02ntZshJdTEHLhnkb4hATadU8qGdzB45T2AdmCqtx73oegqrCLNRTKJwkYNZkVNLMsl)

### Linux Kernel Tuning

- node level, basically the non-namespaced sysctls

```bash
# Sets the maximum number of file handles allowed by the kernel
sysctl -w fs.file-max=2097152

# Sets the maximum number of open file descriptors that a process can have
sysctl -w fs.nr_open=2097152
```

- namespaced sysctls

```bash
# Sets the maximum number of connections that can be queued for acceptance by the kernel.
sysctl -w net.core.somaxconn=32768

# Sets the maximum number of SYN requests that can be queued by the kernel
sysctl -w net.ipv4.tcp_max_syn_backlog=16384

# Setting the minimum, default and maximum size of TCP Buffer
sysctl -w net.ipv4.tcp_rmem='1024 4096 16777216'
sysctl -w net.ipv4.tcp_wmem='1024 4096 16777216'

# Setting Parameters for TCP Connection Tracking
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_time_wait=30

# Controls the maximum number of entries in the TCP time-wait bucket table
sysctl -w net.ipv4.tcp_max_tw_buckets=1048576

# Controls Timeout for FIN-WAIT-2 Sockets:
sysctl -w net.ipv4.tcp_fin_timeout=15
```

- There are some more namespaced sysctls that will improve the performance but because of an active issue we are not able to set them on the container level

```bash
# Sets the size of the backlog queue for the network device
sysctl -w net.core.netdev_max_backlog=16384

# Amount of memory that is allocated for storing incoming and outgoing  data for a socket
sysctl -w net.core.rmem_default=262144
sysctl -w net.core.wmem_default=262144

# Setting the maximum amount of memory for the socket buffers
sysctl -w net.core.rmem_max=16777216
sysctl -w net.core.wmem_max=16777216
sysctl -w net.core.optmem_max=16777216
```

### Erlang VM Tuning

```bash
## Erlang Process Limit
node.process_limit = 2097152

## Sets the maximum number of simultaneously existing ports for this system
node.max_ports = 2097152
```

### EMQX Broker Tuning

```yaml
# Other configuration…
EMQX_LISTENER__TCP__EXTERNAL: "0.0.0.0:1883"
EMQX_LISTENER__TCP__EXTERNAL__ACCEPTORS: 64
EMQX_LISTENER__TCP__EXTERNAL__MAX_CONNECTIONS: 1024000
```
