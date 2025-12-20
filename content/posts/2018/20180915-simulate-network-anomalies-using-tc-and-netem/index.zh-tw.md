---
title: "使用 TC 和 Netem 模拟网络异常"
date: 2018-09-15T16:17:26+08:00
menu:
  sidebar:
    name: "使用 TC 和 Netem 模拟网络异常"
    identifier: linux-simulate-network-anomalies-using-tc-and-netem
    weight: 10
tags: ["URL", "Linux", "Network"]
categories: ["URL", "Linux", "Network"]
hero: images/hero/linux.png
---

- [使用 TC 和 Netem 模拟网络异常](https://www.hi-linux.com/posts/35699.html)

> Netem 与 TC 简要说明
>
> Netem 是 Linux 2.6 及以上内核版本提供的一个网络模拟功能模块。该功能模块可以用来在性能良好的局域网中，模拟出复杂的互联网传输性能。例如:低带宽、传输延迟、丢包等等情况。使用 Linux 2.6 (或以上) 版本内核的很多 Linux 发行版都默认开启了该内核模块，比如：Fedora、Ubuntu、Redhat、OpenSuse、CentOS、Debian 等等。
>
> TC 是 Linux 系统中的一个用户态工具，全名为 Traffic Control (流量控制)。TC 可以用来控制 Netem 模块的工作模式，也就是说如果想使用 Netem 需要至少两个条件，一是内核中的 Netem 模块被启用，另一个是要有对应的用户态工具 TC 。

1. 所有的报文延迟 100ms 发送: `$ tc qdisc add dev enp0s5 root netem delay 100ms`
2. 模拟丢包率: `$ tc qdisc change dev enp0s5 root netem loss 50%`
3. 模拟包重复: `$ tc qdisc change dev enp0s5 root netem duplicate 50%`
4. 模拟包损坏: `tc qdisc change dev enp0s5 root netem corrupt 2%`
5. 模拟包乱序(每 5 个报文（第 5、10、15…报文）会正常发送，其他的报文延迟 100ms): `tc qdisc change dev enp0s5 root netem reorder 50% gap 3 delay 100ms`

##### 查看并显示 enp0s5 网卡的相关传输配置

`$ tc qdisc show dev enp0s5`

##### [Wondershaper](https://github.com/magnific0/wondershaper)

设置网卡下载速度为 200kb/s，上传速度为 150kb/s

`$ sudo wondershaper enp0s5 200 150`

速率限制消除

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

- `--device` 说明要控制的网卡为 enp0s5。
- `--latency` 指定 250ms 的延迟。
- `--target-bw` 指定目标带宽。
- `--default-bw` 指定默认带宽。
- `--packet-loss` 指定丢包率。
- `--target-addr`/`--target-proto`/`--target-port` 参数指定在满足这些条件的报文上实施上面的配置。
