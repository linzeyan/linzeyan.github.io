---
title: "Arp notes"
date: 2017-09-03T15:00:00+08:00
menu:
  sidebar:
    name: "Arp notes"
    identifier: network-arp-notes
    weight: 10
tags: ["Network"]
categories: ["Network"]
hero: images/hero/network.png
---

Before a packet is sent

- Look up the MAC for the IP in the ARP table
  - MAC found - encapsulate
  - No MAC - broadcast
    - Same subnet - OK
    - Different subnet - look up the router MAC in the ARP table
      - Found - OK
      - Not found - broadcast
