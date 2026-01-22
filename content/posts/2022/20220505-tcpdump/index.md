---
title: "Tcpdump Usage Summary"
date: 2022-05-05T13:39:10+08:00
menu:
  sidebar:
    name: "Tcpdump Usage Summary"
    identifier: network-command-tcpdump
    weight: 10
tags: ["Links", "Network", "tcpdump", "command line"]
categories: ["Links", "Network", "tcpdump", "command line"]
hero: images/hero/network.png
---

- [Tcpdump Usage Summary](https://markrepo.github.io/commands/2018/06/23/tcpdump/)

## Command usage

tcpdump uses the command line. The command format is:

```bash
tcpdump [ -AdDeflLnNOpqRStuUvxX ] [ -c count ]
           [ -C file_size ] [ -F file ]
           [ -i interface ] [ -m module ] [ -M secret ]
           [ -r file ] [ -s snaplen ] [ -T type ] [ -w file ]
           [ -W filecount ]
           [ -E spi@ipaddr algo:secret, ...  ]
           [ -y datalinktype ] [ -Z user ]
           [ expression ]
```

### Simple option notes for tcpdump

- `-E spi@ipaddr algo:secret , ...` can decrypt IPsec ESP packets using `spi@ipaddr algo:secret`. The secret is the ESP key, expressed as an ASCII string. If it starts with `0x`, the key is read as hex. In addition to the syntax above (`spi@ipaddr algo:secret`), you can append a syntax input filename for tcpdump to use (replace ... in `spi@ipaddr algo:secret, ...` with a syntax filename). This file is opened when the first ESP packet arrives, so it is best to drop some privileges at that time (to reduce risk if the file is malicious).
- `-T type` forces tcpdump to analyze packets according to the protocol structure specified by type. Known type values include:
  - `aodv` (Ad-hoc On-demand Distance Vector protocol, used in Ad hoc peer-to-peer networks)
  - `cnfp` (Cisco NetFlow protocol)
  - `rpc` (Remote Procedure Call)
  - `rtp` (Real-Time Applications protocol)
  - `rtcp` (Real-Time Applications control protocol)
  - `snmp` (Simple Network Management Protocol)
  - `tftp` (Trivial File Transfer Protocol)
  - `vat` (Visual Audio Tool, an application-layer protocol used for video conferencing on the internet)
  - `wb` (distributed White Board, an application-layer protocol for online meetings)

### Practical command examples

**Capture communication between host 210.27.48.1 and host 210.27.48.2 or 210.27.48.3**

- `tcpdump host 210.27.48.1 and \( 210.27.48.2 or 210.27.48.3 \)`

**Monitor all packets sent to host hostname**

- `tcpdump -i eth0 dst host hostname`

**Capture telnet packets sent or received by host 210.27.48.1**

- `tcpdump tcp port 23 and host 210.27.48.1`

**Print the start and end packets of TCP sessions where the source or destination is not on the local network (nt: localnet, replace with the actual local network name)**

- `tcpdump 'tcp[tcpflags] & (tcp-syn|tcp-fin) != 0 and not src and dst net localnet'`

**Print all packets with source or destination port 80, IPv4 as the network layer protocol, and containing data (not SYN, FIN, ACK-only without data)**

- `tcpdump 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'`
  > (Think of it this way: ip[2:2] is the total length of the IP packet. (ip[0]&0xf)<<2 is the IP header length, where ip[0]&0xf is the IHL field and its unit is 32-bit words, so multiply by 4 (left shift 2) to get bytes. (tcp[12]&0xf0)>>4 is the TCP header length, also in 32-bit words, so convert to bits as ((tcp[12]&0xf0)>>4)<<2, i.e., ((tcp[12]&0xf0)>>2). ((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0 means the total IP packet length minus the IP header length minus the TCP header length is not zero, which means there is data in the IP packet. For IPv6, consider the difference between the IPv6 header's Payload Length and the TCP header length, and replace ip[] with ip6[].)

**Capture HTTP packets**

- `tcpdump  -XvvennSs 0 -i eth0 tcp[20:2]=0x4745 or tcp[20:2]=0x4854`
  > 0x4745 is the first two letters of "GET" ("GE"), and 0x4854 is the first two letters of "HTTP" ("HT").
