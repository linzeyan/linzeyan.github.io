---
title: "Simulate Network Anomalies with TC and Netem"
date: 2018-09-15T16:17:26+08:00
menu:
  sidebar:
    name: "Simulate Network Anomalies with TC and Netem"
    identifier: linux-simulate-network-anomalies-using-tc-and-netem
    weight: 10
tags: ["Links", "Linux", "Network"]
categories: ["Links", "Linux", "Network"]
hero: images/hero/linux.png
---

- [Simulate Network Anomalies with TC and Netem](https://www.hi-linux.com/posts/35699.html)

> Netem and TC brief overview
>
> Netem is a network emulation module provided by Linux 2.6 and later kernels. It can be used on a good LAN to simulate complex Internet transmission performance, such as low bandwidth, latency, packet loss, and so on. Many Linux distributions with kernel 2.6+ enable this module by default, such as Fedora, Ubuntu, Redhat, OpenSuse, CentOS, Debian, etc.
>
> TC is a user-space tool in Linux, short for Traffic Control. TC controls the operating mode of the Netem module. In other words, to use Netem you need at least two conditions: the Netem module must be enabled in the kernel, and the corresponding user-space tool TC must be available.

1. Delay all packets by 100ms: `$ tc qdisc add dev enp0s5 root netem delay 100ms`
2. Simulate packet loss: `$ tc qdisc change dev enp0s5 root netem loss 50%`
3. Simulate packet duplication: `$ tc qdisc change dev enp0s5 root netem duplicate 50%`
4. Simulate packet corruption: `tc qdisc change dev enp0s5 root netem corrupt 2%`
5. Simulate packet reordering (every 5 packets (5th, 10th, 15th...) are sent normally, others are delayed 100ms): `tc qdisc change dev enp0s5 root netem reorder 50% gap 3 delay 100ms`

##### View transmission settings for enp0s5

`$ tc qdisc show dev enp0s5`

##### [Wondershaper](https://github.com/magnific0/wondershaper)

Set download to 200kb/s and upload to 150kb/s

`$ sudo wondershaper enp0s5 200 150`

Remove rate limit

`$ sudo wondershaper clear enp0s5`

##### [Comcast](https://github.com/tylertreat/comcast)

```shell
$ comcast --device=enp0s5 --latency=250 \
    --target-bw=1000 \
    --default-bw=1000000 \
    --packet-loss=10% \
    --target-addr=8.8.8.8,10.0.0.0/24 \
    --target-proto=tcp,udp,icmp \
    --target-port=80,22,1000:2000
```

- `--device` specifies the target NIC as enp0s5.
- `--latency` specifies a 250ms delay.
- `--target-bw` specifies the target bandwidth.
- `--default-bw` specifies the default bandwidth.
- `--packet-loss` specifies the packet loss rate.
- `--target-addr`/`--target-proto`/`--target-port` apply the configuration above to packets that match these conditions.
