---
title: Network docs
weight: 100
menu:
  notes:
    name: network
    identifier: notes-docs-network
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

{{< note title="Juniper SRX 320" >}}

```bash
# 查看當前軟體版本號
show system software

# 查看系統啟動時間
show system uptime

# 查看硬體板卡及序號
show chassis haredware

# 查看硬體板卡當前狀態
show chassis environment

# 查看主控板（RE）資源使用及狀態
show chassis routing-engine


# 查看當前防火牆併發會話數
show security flow session summary

# 查看當前防火牆具體併發會話
show security flow session

# 清除當前 session
clear security flow session all

# 檢查全域 ALG 開啟情況
show security alg status

# 查OID
show snmp mib walk decimal 1.3.6.1.2.1.2.2.1.2

# 設定政策
set security policy zones from-zone to-zone

# 查看路由表
show route

# 查看 ARP 表
show arp

# 查看系統日誌
show log messages

# 查看所有介面運行狀態
show interface terse

# 查看介面運行細節資訊
show interface ge-x/y/z detail

# 比較修改
show | compare rollback ?
show | compare rollback 1

# 查看系統
show system

# 查看設定
show configuration

# 動態統計介面資料包轉發資訊
monitor interface ge-x/y/z

# 動態報文抓取（Tcpdump，類似 ScreenOS snoop命令）
monitor traffic interface ge-x/y/z
```

{{< /note >}}
