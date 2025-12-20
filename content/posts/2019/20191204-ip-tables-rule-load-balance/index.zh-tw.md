---
title: "用 iptables 和 ip rule 做负载均衡"
date: 2019-12-04T11:08:04+08:00
menu:
  sidebar:
    name: "用 iptables 和 ip rule 做负载均衡"
    identifier: linux-network-ip-tables-rule-load-balance
    weight: 10
tags: ["URL", "Linux", "Iptables"]
categories: ["URL", "Linux", "Iptables"]
hero: images/hero/linux.png
---

- [用 iptables 和 ip rule 做负载均衡](https://blog.outv.im/2019/ip-tables-rule-load-balance/)

#### 操作

这里以一台通过有线 + 无线出口连接到互联网的 Arch Linux 设备为例。其中共有两个出口，分别使用网卡 eth0 和 eth1。大概的对应关系是：

- 标记 10 (0xa) - 路由表 #110 - 使用 eth0 出口
- 标记 11 (0xb) - 路由表 #111 - 使用 eth1 出口

我们会根据数据包上包含的标记值来判断它应该走什么出口。首先，使用 ip rule 为每个标记值指定一张使用的路由表。

通常默认路由表的权重是 32768。为了让我们的路由表用得上，我们需要把它们的权重调得高一些（例如 31000）。

```shell
# 让带标记 10 (0xa) 的数据包使用 110 号路由表，权重 31000
ip rule add fwmark 10 table 110 prio 31000
# 让带标记 11 (0xb) 的数据包使用 111 号路由表，权重 31000
ip rule add fwmark 11 table 111 prio 31000
# 如果你的连接更多，可以继续添加标记 <-> 路由表的对应关系

# #110 路由表的路由
ip route add 10.20.0.0/24 dev eth0 table 110
ip route add default via 10.20.0.254 table 110
# #111 路由表的路由
ip route add 10.25.0.0/24 dev eth1 table 111
ip route add default via 10.25.0.254 table 111


# 如果这条连接已经被标记，那么把标记设置到数据包上
iptables -t mangle -A OUTPUT -j CONNMARK --restore-mark
# 如果数据包已经有标记，直接放行
iptables -t mangle -A OUTPUT -m mark ! --mark 0 -j ACCEPT
# 如果数据包没被标记的话
# 把数据包包的标记设置为 11 (0xb)...
iptables -t mangle -A OUTPUT -j MARK --set-mark 10
# 并且每 2 个包就把一个包的标记设置为 10 (0xa)
iptables -t mangle -A OUTPUT -m statistic --mode nth --every 2 --packet 0 -j MARK --set-mark 11

# 如果你有三条出口的话，这里可以类似于
# iptables -t mangle -A OUTPUT -j MARK --set-mark 10
# iptables -t mangle -A OUTPUT -m statistic --mode nth --every 3 --packet 0 -j MARK --set-mark 11
# iptables -t mangle -A OUTPUT -m statistic --mode nth --every 3 --packet 1 -j MARK --set-mark 12

# 把数据包的标记存储到整条连接上，这样整个连接过程都会使用同一条出口
iptables -t mangle -A OUTPUT -j CONNMARK --save-mark

# 我们还需要让数据包上标示的出口是我们为其选择的出口
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
```

之后可以用 `iptables -L OUTPUT -t mangle` 看一下自己所设置的规则是否正确。然后就可以用 Wiresharks 看一看自己的连接是不是真的分流啦。
