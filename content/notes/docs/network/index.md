---
title: Network docs
weight: 100
menu:
  notes:
    name: network
    identifier: notes-network-docs
    parent: notes-docs
    weight: 10
---

{{< note title="Synology Active Backup for Bussiness backup task failed" >}}

###### Due to IP change last week

0. Firewall policy create NAS_to_ESXi。
1. 虛擬機器 -> 任務清單 -> 刪除任務。
2. 虛擬機器 -> VMware vSphere -> 管理 Hypervisor -> 刪除舊的 IP，新增新的 IP。

{{< /note >}}

{{< note title="Set LACP for Synology NAS and NETGEAR switch" >}}

###### NETGEAR

1. Switching -> LAG -> LAG Configuration -> ch1 -> 41、42 -> Apply。
2. ch1 -> Description: NAS、LAG Type:LACP -> Apply。
3. Switching -> VLAN -> Port PVID Configuration -> g41、g42 PVID:99、VLAN Member:10-14,17-23,99,101、VLAN Tag:10-14,17-23,99,101 -> Apply。

###### Synology

- 控制台 -> 網路 -> 網路介面 -> 新增 Bond。

{{< /note >}}

{{< note title="Set NAT in FortiGate" >}}

##### 1. 政策&物件 -> 虛擬 IP -> 新增

- 名稱: IT-VPN
- 介面: wan2
- 對外 IP: 0.0.0.0

###### 埠號轉發

- 協定: TCP
- 外部服務埠號: 19979
- 對應到埠號: 19979

##### 2. 政策&物件 -> IPv4 政策

1. From zone wan2 to zone Knowhow_Vlan
2. From any to IT-VPN

{{< /note >}}
