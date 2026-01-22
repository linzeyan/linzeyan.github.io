---
title: "Netcat (Linux nc) Practical Examples for Network Admins"
date: 2018-11-09T00:17:47+08:00
menu:
  sidebar:
    name: "Netcat (Linux nc) Practical Examples for Network Admins"
    identifier: linux-utility-netcat-examples
    weight: 10
tags: ["Links", "Linux", "netcat"]
categories: ["Links", "Linux", "netcat"]
hero: images/hero/linux.png
---

- [Netcat (Linux nc) Practical Examples for Network Admins](https://blog.gtwang.org/linux/linux-utility-netcat-examples/)

#### Send a test UDP packet to a remote server

This command sends a UDP test packet to the specified host and port. The `-w1` option sets the timeout to 1 second.

`echo -n "foo" | nc -u -w1 192.168.1.8 5000`

#### Open a UDP port to receive data

`nc -lu localhost 5000`

#### Port scanning on a remote host

This command scans TCP ports in the ranges 1-1000 and 2000-3000 on the specified host to see which ports are open.

`nc -vnz -w 1 192.168.233.208 1-1000 2000-3000`

This command scans UDP ports.

`nc -vnzu 192.168.1.8 1-65535`

#### Copy a file between two hosts

Assume there are two hosts, A and B. To copy a file from host A to host B, run the following on host B (the receiver):

`nc -l 5000 > my.jpg`

Then run the following on host A (the sender):

`nc hostB.com 5000 < my.jpg`

This copies the file my.jpg from host A to host B. It may not be as convenient as scp, but its advantage is that it does not require login (no username or password). If two hosts cannot log in to each other, this can be a workaround.

#### Send an HTTP request manually

`echo -ne "GET / HTTP/1.0\r\n\r\n" | nc www.google.com 80`

#### Connect via a proxy server

This command uses the proxy server 10.2.3.4:8080 to connect to port 42 on host.example.com.

`nc -x10.2.3.4:8080 -Xconnect host.example.com 42`

#### Use a Unix domain socket

This command creates a Unix domain socket and receives data:

`nc -lU /var/tmp/dsocket`
