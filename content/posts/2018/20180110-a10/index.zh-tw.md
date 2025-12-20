---
title: "A10"
date: 2018-01-10T03:44:14+08:00
menu:
  sidebar:
    name: "A10"
    identifier: adc-application-delivery-controller-a10-command-introduce
    weight: 10
tags: ["URL", "Application Delivery Controller", "A10"]
categories: ["URL", "Application Delivery Controller", "A10"]
---

- [A10 Link Aggregation](https://jal.tw/a10:l2:link-aggregation)
- [Health Monitor use TCL](https://jal.tw/a10:slb:healthmonitor:tcl)
- [A10 SSL Offload Cipher Suite Support List](https://jal.tw/a10:slb:ssl-cipher)
- [Compression](https://jal.tw/a10:slb:compression)
- [A10 RAM Cache 加速](https://jal.tw/a10:slb:ramcache)
- [A10 NAT](https://jal.tw/a10:nat)
- [A10 configuration template](https://jal.tw/a10:basic:config)

#### A10 Link Aggregation

##### 802.3ad LACP

> A10 trunk can config a maximnm of 16 LACP trunks per device.

```
interface ethernet 1
 lacp trunk 1 mode active
 lacp timeout long
!
interface ethernet 2
 lacp trunk 1 mode active
 lacp timeout long
```

##### Static Link Aggregation

> None LACP.
>
> Up to 8 static trunks.

```
trunk 1
 ethernet 1 to 2
```

#### Compression

```
slb server jal.tw jal.tw
   port 80  tcp

slb service-group jal.tw_group tcp
    member jal.tw:80

!
!
slb template http html_gzip
   compression enable
   compression level 6
   compression keep-accept-encoding enable
   compression content-type text
   compression content-type image

slb virtual-server vip-172.31.6.211 172.31.6.211
   port 80  http
      service-group jal.tw_group
      template http html_gzip
```

#### RAM Cache

```
slb server jal.tw jal.tw
   port 80  tcp

slb service-group jal.tw_group tcp
    member jal.tw:80

slb template cache ram_cache_static_content
   verify-host
   accept-reload-req
   max-content-size 819200
   default-policy-nocache
   policy uri .ico cache
   policy uri .gif cache
   policy uri .jpg cache
   policy uri .js cache
   policy uri .png cache
   policy uri .css cache
!
!

slb virtual-server vip-172.31.6.211 172.31.6.211
   port 80  http
      service-group jal.tw_group
      template cache ram_cache_static_content
```

#### A10 NAT

> A10 outgoing NAT 分成 L3-mode 及 L4 概念來處理的 NAT

##### Wildcard outgoing NAT

> - Layer 4 概念的 outgoing NAT
>
> > 1.  將 Clinet 端的 interface 設定為監聽模式 allow-promiscuous-vip
> > 2.  建立將要帶出去之 NAT IP (不能為 interface IP)
> > 3.  將 Gateway 視為 SLB Server 建立 Real Server
> > 4.  分別建立該 Gateway 的 Server Group (TCP 及 UDP 分開)，並將 Gateway 的 Real Sevrer 加為 member
> > 5.  使用 wildcard VIP 將流量送到 Gateway，但是 no-dest-nat (不換 destination IP，只換 destination MAC 為 gateway MAC)
>
> - Gateway IP: 10.2.2.254/24
> - Source IP: 10.1.1.0/24
> - NAT IP: 10.2.2.100
> - Source vlan: 10

```
interface ve 10
 ip allow-promiscuous-vip
!
ip nat pool SNAT_IP 10.2.2.100 10.2.2.100 netmask /24
!
slb server GW_IP 10.2.2.254
   port 0  tcp
       no health-check
   port 0  udp
       no health-check
!
slb service-group GW_TCP tcp
    member GW_IP:0
!
slb service-group GW_UDP udp
    member GW_IP:0
!
slb virtual-server _wildcard_vserver 0.0.0.0
   port 0  tcp
      source-nat pool SNAT_IP
      service-group GW_TCP
      no-dest-nat
   port 0  udp
      source-nat pool SNAT_IP
      service-group GW_UDP
      no-dest-nat
   port 0  others
      source-nat pool SNAT_IP
      service-group GW_TCP
      no-dest-nat
   port 21  ftp
      source-nat pool SNAT_IP
      service-group GW_TCP
      no-dest-nat
```

##### L3 mode NAT

> - Gateway IP: 10.2.2.254/24
> - Source IP: 10.1.1.0/24
> - NAT IP: 10.2.2.100
> - Source vlan: 10
> - Gateway vlan: 20

```
interface ve 20
 ip nat outside
interface ve 10
 ip nat inside
!
access-list 101 permit ip 10.1.1.0 0.0.0.255 any
!
ip nat pool SNAT_IP 10.2.2.100 10.2.2.100 netmask /24
!
ip nat inside source list 101 pool SNAT_IP
```

#### A10 configuration template

```
clock timezone Asia/Taipei nodst
!
slb template tcp Default
   idle-timeout 300
   reset-fwd
   reset-rev
!
!
logging syslog warning
logging host 10.0.0.1 port 514
!
snmp-server enable
snmp-server location "TAIWAN"
snmp-server contact "a10@a10networks.com"
snmp-server community read DontUsePublic remote 10.0.0.0 /24
snmp-server community read DontUsePublic remote 192.168.0.0 /16
!
enable-management service telnet management
!
ip dns primary 2001:4860:4860::8888
ip dns secondary 8.8.8.8
!
web-service timeout-policy idle 60
!
!
enable-core
!
!
terminal idle-timeout 60
!
ntp server tock.stdtime.gov.tw
ntp enable
!
```

#### A10 Debug 模式

```
enable
debug packet interface eth x
debug monitor
```

#### A10 AXDebug 模式

```
enable
axdebug
show axdebug filter
capture brief

...
no axdebug
```

```
設定要觀察 VS :BGP_NTT_AG_MKT/113.25.198.111, port : 80 , proto : tcp
AX2500#axdebug
AX2500(axdebug)#filter 1
AX2500(axdebug-filter:1)#ip 113.25.198.111 /32
AX2500(axdebug-filter:1)#port 80 80
AX2500(axdebug-filter:1)#proto tcp
AX2500(axdebug-filter:1)#exit
AX2500(axdebug)#show axdebug filter
axdebug filter 1
  ip 113.25.198.111 /32
  proto tcp
  port 80 80
將其存成 a2 檔名，並開始抓包
AX2500(axdebug)#capture save a2 0
停止抓包
AX2500(axdebug)#no capture brief
清除相關參數
AX2500(axdebug)#no filter 1
AX2500(axdebug)#show axdebug filter 1
```
