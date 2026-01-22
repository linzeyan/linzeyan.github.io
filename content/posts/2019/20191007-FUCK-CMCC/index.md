---
title: "Fighting ISP Cache Hijacking Again with iptables"
date: 2019-10-07T10:41:08+08:00
menu:
  sidebar:
    name: "Fighting ISP Cache Hijacking Again with iptables"
    identifier: linux-network-iptables-cache-hijack-FUCK-CMCC
    weight: 10
tags: ["Links", "Network", "Linux", "Iptables"]
categories: ["Links", "Network", "Linux", "Iptables"]
hero: images/hero/linux.png
---

- [Fighting ISP Cache Hijacking Again with iptables](https://v2c.tech/Article/FUCK-CMCC)

##### Cause

The fight against the carrier cache problem started two years ago. The carrier even cached cnpm data. Worse, their cache servers were not only slow like a turtle in a marathon, they also crashed frequently, so I just wanted to write code but had to face a wall of red errors.

##### Fix

`iptables -I FORWARD -p tcp -m tcp -m ttl --ttl-gt 20 -m ttl --ttl-lt 30 -j DROP`

Since real packets from other servers might have TTL values in the 20-30 range, we should add another check. Comparing the hijacked 302 packets with normal 302 packets, the hijacked packets include FIN, PSH, and ACK flags, while normal 302 packets typically do not include all three.

So add a TCP flag check in iptables:

`iptables -I FORWARD -p tcp -m tcp -m ttl --ttl-gt 20 -m ttl --ttl-lt 30 --tcp-flags ALL FIN,PSH,ACK -j DROP`

This should drop hijacked packets while minimizing false positives.
