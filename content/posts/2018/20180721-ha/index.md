---
title: "HA command"
date: 2018-07-21T14:45:29+08:00
menu:
  sidebar:
    name: "HA command"
    identifier: firewall-juniper-ha-commands
    weight: 10
tags: ["Firewall", "Juniper"]
categories: ["Firewall", "Juniper"]
---

```
load merge relative terminal

# 全新設備上面沒啟用過HA  必須先定義Cluster ID
# ClustartID 必須獨立，不可以與其他SRX重複，因為HA會建立一組Virtual MAC Address ，而這個ID數值會對其產生影響，重複有可能導致MAC address 重複而出現不可預期的錯誤
#

request system zeroize

# 以下command 必須在  > 模式使用
set chassis cluster cluster-id <ID範圍 0~ 255> node 0 # 這個是在 node  0 的設備下的
set chassis cluster cluster-id <ID範圍 0~ 255> node 1 # 這個是在 node 1  的設備下的

在secondary node 下 這個command
request chassis cluster configuration-synchronize


# 等待機器重開機後，會出現Hold 或stanby 字樣 ，看到Cluster 是否有起來

show chassis cluster status

# 這個是RETH interface 建立好才會出現，必須先做config才會有
show chassis cluster interfaces

# 以下command 則是在 Config mode 下使用 ，先把設定檔建起來


---

# 這邊需要 backup-router 是給 HA裡面的Standby Device 的管理介面 (fxp) 一筆routing 可以回應，預設Standby 不會啟用routing engine，所以需要這筆設定

set groups node0 system host-name SRX-node0
set groups node0 system backup-router 10.10.0.254
set groups node0 system backup-router destination 0.0.0.0/0
set groups node0 interfaces fxp0 unit 0 family inet address 10.10.0.2/24
set groups node1 system host-name SRX-node1
set groups node1 system backup-router 10.10.0.254
set groups node1 system backup-router destination 0.0.0.0/0
set groups node1 interfaces fxp0 unit 0 family inet address 10.10.0.3/24

set apply-groups "${node}"
set system time-zone Asia/Taipei

set chassis cluster control-link-recovery
set chassis cluster reth-count 10
set chassis cluster heartbeat-interval 2000

# 另外建議在建置期間先將IPv6 打開，可以使用以下指令，因為日後開啟IPv6功能則必須要將設備重開機
set security forwarding-options family inet6 mode flow-based


# 這邊的interface 號碼要看每一台Chassis 的型號不同而會有所不同
# 最簡單的識別方式是看那台設備的Slot 有幾個，像SRX550HM 是 0~ 8都有擴充可以使用，所以預設HA會在 9開始 ，所以會是 ge-9/x/x
set chassis cluster redundancy-group 0 node 0 priority 150
set chassis cluster redundancy-group 0 node 1 priority 100
set chassis cluster redundancy-group 0 interface-monitor ge-0/0/3 weight 150
set chassis cluster redundancy-group 0 interface-monitor ge-0/0/5 weight 150
set chassis cluster redundancy-group 0 interface-monitor ge-9/0/3 weight 100
set chassis cluster redundancy-group 0 interface-monitor ge-9/0/5 weight 100

set chassis cluster redundancy-group 1 node 0 priority 150
set chassis cluster redundancy-group 1 node 1 priority 100
set chassis cluster redundancy-group 1 interface-monitor ge-0/0/3 weight 150
set chassis cluster redundancy-group 1 interface-monitor ge-0/0/5 weight 150
set chassis cluster redundancy-group 1 interface-monitor ge-9/0/3 weight 100
set chassis cluster redundancy-group 1 interface-monitor ge-9/0/5 weight 100


# 這裡是作為Redundancy group: 1 的 Data sync 設定 ，請務必設定上去才會啟用ge-0/0/2 的 heartbeat link
set interfaces fab0 fabric-options member-interfaces ge-0/0/2
set interfaces fab1 fabric-options member-interfaces ge-9/0/2

# 設定interface 加入reth Group
set interfaces ge-0/0/3 gigether-options redundant-parent reth0
set interfaces ge-0/0/4 gigether-options redundant-parent reth0
set interfaces ge-9/0/3 gigether-options redundant-parent reth0
set interfaces ge-9/0/4 gigether-options redundant-parent reth0

set interfaces ge-0/0/5 gigether-options redundant-parent reth1
set interfaces ge-9/0/5 gigether-options redundant-parent reth1

set interfaces reth0 vlan-tagging
# 務必要將RETH 加入 data sync Group 裡面，不然不會動
set interfaces reth0 redundant-ether-options redundancy-group 1

# 特別注意，在SRX雖然是LACP Passive mode ，在Switch 請務必使用LACP Activate mode
set interfaces reth0 redundant-ether-options lacp passive
set interfaces reth0 redundant-ether-options lacp periodic slow


set interfaces reth1 redundant-ether-options redundancy-group 1
set interfaces reth1 unit 0 family inet address 202.99.240.100/26
```
