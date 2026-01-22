---
title: "用 iptables 和 ip rule 做負載均衡"
date: 2019-12-04T11:08:04+08:00
menu:
  sidebar:
    name: "用 iptables 和 ip rule 做負載均衡"
    identifier: linux-network-ip-tables-rule-load-balance
    weight: 10
tags: ["Links", "Linux", "Iptables"]
categories: ["Links", "Linux", "Iptables"]
hero: images/hero/linux.png
---

- [用 iptables 和 ip rule 做負載均衡](https://blog.outv.im/2019/ip-tables-rule-load-balance/)

#### 操作

這裡以一台透過有線 + 無線出口連線到網際網路的 Arch Linux 裝置為例。共有兩個出口，分別使用網卡 eth0 和 eth1。大致對應關係如下：

- 標記 10 (0xa) - 路由表 #110 - 使用 eth0 出口
- 標記 11 (0xb) - 路由表 #111 - 使用 eth1 出口

我們會根據封包上的標記值判斷它應該走哪個出口。首先，使用 ip rule 為每個標記值指定一張路由表。

通常預設路由表的權重是 32768。為了讓我們的路由表生效，需要將權重調高一些（例如 31000）。

```shell
# 讓帶標記 10 (0xa) 的封包使用 110 號路由表，權重 31000
ip rule add fwmark 10 table 110 prio 31000
# 讓帶標記 11 (0xb) 的封包使用 111 號路由表，權重 31000
ip rule add fwmark 11 table 111 prio 31000
# 如果你的連線更多，可以繼續新增標記 <-> 路由表的對應關係

# #110 路由表的路由
ip route add 10.20.0.0/24 dev eth0 table 110
ip route add default via 10.20.0.254 table 110
# #111 路由表的路由
ip route add 10.25.0.0/24 dev eth1 table 111
ip route add default via 10.25.0.254 table 111


# 如果這條連線已經被標記，將標記設定到封包上
iptables -t mangle -A OUTPUT -j CONNMARK --restore-mark
# 如果封包已經有標記，直接放行
iptables -t mangle -A OUTPUT -m mark ! --mark 0 -j ACCEPT
# 如果封包沒有被標記
# 把封包標記為 10 (0xa)
iptables -t mangle -A OUTPUT -j MARK --set-mark 10
# 每 2 個封包就把一個封包標記為 11 (0xb)
iptables -t mangle -A OUTPUT -m statistic --mode nth --every 2 --packet 0 -j MARK --set-mark 11

# 如果你有三條出口，這裡可以類似於
# iptables -t mangle -A OUTPUT -j MARK --set-mark 10
# iptables -t mangle -A OUTPUT -m statistic --mode nth --every 3 --packet 0 -j MARK --set-mark 11
# iptables -t mangle -A OUTPUT -m statistic --mode nth --every 3 --packet 1 -j MARK --set-mark 12

# 把封包的標記儲存到整條連線上，讓整個連線使用同一個出口
iptables -t mangle -A OUTPUT -j CONNMARK --save-mark

# 讓封包的出口與我們選擇的一致
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
```

之後可以用 `iptables -L OUTPUT -t mangle` 看一下規則是否正確，再用 Wireshark 驗證連線是否真的分流。
