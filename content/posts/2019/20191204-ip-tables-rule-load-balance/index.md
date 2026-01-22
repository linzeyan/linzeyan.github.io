---
title: "Load Balancing with iptables and ip rule"
date: 2019-12-04T11:08:04+08:00
menu:
  sidebar:
    name: "Load Balancing with iptables and ip rule"
    identifier: linux-network-ip-tables-rule-load-balance
    weight: 10
tags: ["Links", "Linux", "Iptables"]
categories: ["Links", "Linux", "Iptables"]
hero: images/hero/linux.png
---

- [Load Balancing with iptables and ip rule](https://blog.outv.im/2019/ip-tables-rule-load-balance/)

#### Steps

This example uses an Arch Linux device with two Internet uplinks: eth0 and eth1. The mapping is:

- Mark 10 (0xa) - Routing table #110 - use eth0
- Mark 11 (0xb) - Routing table #111 - use eth1

We decide which uplink to use based on the packet mark. First, use ip rule to map each mark to its routing table.

The default routing table priority is 32768. To ensure our tables are used, set a higher priority (for example 31000).

```shell
# Use routing table 110 for packets marked 10 (0xa), priority 31000
ip rule add fwmark 10 table 110 prio 31000
# Use routing table 111 for packets marked 11 (0xb), priority 31000
ip rule add fwmark 11 table 111 prio 31000
# Add more mark <-> routing table mappings if needed

# Routes for table #110
ip route add 10.20.0.0/24 dev eth0 table 110
ip route add default via 10.20.0.254 table 110
# Routes for table #111
ip route add 10.25.0.0/24 dev eth1 table 111
ip route add default via 10.25.0.254 table 111


# If the connection is already marked, restore the mark to the packet
iptables -t mangle -A OUTPUT -j CONNMARK --restore-mark
# If a packet is already marked, accept it
iptables -t mangle -A OUTPUT -m mark ! --mark 0 -j ACCEPT
# If a packet is not marked
# Set the packet mark to 10 (0xa)
iptables -t mangle -A OUTPUT -j MARK --set-mark 10
# Set one out of every 2 packets to mark 11 (0xb)
iptables -t mangle -A OUTPUT -m statistic --mode nth --every 2 --packet 0 -j MARK --set-mark 11

# For three uplinks, you can do something like
# iptables -t mangle -A OUTPUT -j MARK --set-mark 10
# iptables -t mangle -A OUTPUT -m statistic --mode nth --every 3 --packet 0 -j MARK --set-mark 11
# iptables -t mangle -A OUTPUT -m statistic --mode nth --every 3 --packet 1 -j MARK --set-mark 12

# Save packet marks to the connection so the whole connection uses the same uplink
iptables -t mangle -A OUTPUT -j CONNMARK --save-mark

# Ensure packets egress via the chosen uplink
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
```

After that, check your rules with `iptables -L OUTPUT -t mangle`. Then use Wireshark to verify the traffic is actually split.
