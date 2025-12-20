---
title: "Juniper notes"
date: 2017-11-23T16:00:00+08:00
menu:
  sidebar:
    name: "Juniper notes"
    identifier: network-firewall-juniper-my-notes
    weight: 10
tags: ["Network", "Firewall", "Juniper"]
categories: ["Network", "Firewall", "Juniper"]
hero: images/hero/network.png
---

#### [Juniper Firewall] tunnel

**_ACG_**
`icare@TWCHIJF01# show | compare rollback 4`

```diff
[edit security policies]
     from-zone DB_12 to-zone TCT_Office { ... }
+    from-zone DB_12 to-zone JC32 {
+        policy For_Backup {
+            match {
+                source-address DB_10.11.12.0/24;
+                destination-address BACKUP_10.32.32.130;
+                application any;
+            }
+            then {
+                permit;
+            }
+        }
+    }
[edit security zones security-zone DB_12 address-book]
       address DB_10.11.12.57 { ... }
+      address DB_10.11.12.0/24 10.11.12.0/24;
[edit security zones]
     security-zone ESB_15 { ... }
+    security-zone JC32 {
+        address-book {
+            address BACKUP_10.32.32.130 10.32.32.130/32;
+        }
+        host-inbound-traffic {
+            system-services {
+                ping;
+            }
+        }
+        interfaces {
+            gr-0/0/0.32;
+        }
+    }
[edit interfaces gr-0/0/0]
+    unit 32 {
+        description To_JC32_DBBackup;
+        tunnel {
+            source 202.168.193.128;
+            destination 218.253.210.8;
+        }
+        family inet {
+            address 10.32.0.101/30;
+        }
+    }
[edit routing-options static]
     route 0.0.0.0/0 { ... }
+    route 10.32.32.130/32 next-hop 10.32.0.102;
```

```
set security policies from-zone DB_12 to-zone JC32 policy For_Backup match source-address DB_10.11.12.0/24
set security policies from-zone DB_12 to-zone JC32 policy For_Backup match destination-address BACKUP_10.32.32.130
set security policies from-zone DB_12 to-zone JC32 policy For_Backup match application any
set security policies from-zone DB_12 to-zone JC32 policy For_Backup then permit
set security zones security-zone DB_12 address-book address DB_10.11.12.0/24 10.11.12.0/24
set security zones security-zone JC32 address-book address BACKUP_10.32.32.130 10.32.32.130/32
set security zones security-zone JC32 host-inbound-traffic system-services ping
set security zones security-zone JC32 interfaces gr-0/0/0.32
set interfaces gr-0/0/0 unit 32 description To_JC32_DBBackup
set interfaces gr-0/0/0 unit 32 tunnel source 202.168.193.128
set interfaces gr-0/0/0 unit 32 tunnel destination 218.253.210.8
set interfaces gr-0/0/0 unit 32 family inet address 10.32.0.101/30
set routing-options static route 10.32.32.130/32 next-hop 10.32.0.102
```

`icare@TWCHIJF01> show configuration | compare rollback 1`

```diff
[edit routing-options static]
     route 10.32.32.0/24 { ... }
+    route 218.253.210.8/32 next-hop 202.168.193.145;
```

```
set routing-options static route 218.253.210.8/32 next-hop 202.168.193.145
```

**_JC27_32_**

`support021@JC27_32-node0# show | compare rollback 5`

```diff
[edit security policies]
+    from-zone TWACG to-zone GPO {
+        policy For_DBBACKUP {
+            match {
+                source-address DB_10.11.12.0/24;
+                destination-address Backup_10.32.32.130;
+                application any;
+            }
+            then {
+                permit;
+            }
+        }
+    }
[edit security zones security-zone GPO address-book]
       address Other_API_10.32.32.115 { ... }
+      address Backup_10.32.32.130 10.32.32.130/32;
[edit security zones security-zone JC27_33 address-book]
       address 33_OG_Lottery_10.33.11.0/24 { ... }
+      address Zabbix_Agent_10.33.100.2 10.33.100.2/32;
[edit security zones security-zone JC27_33 host-inbound-traffic system-services]
       ping { ... }
+      ssh;
[edit security zones]
     security-zone PROXY { ... }
+    security-zone TWACG {
+        address-book {
+            address DB_10.11.12.0/24 10.11.12.0/24;
+        }
+        host-inbound-traffic {
+            system-services {
+                ping;
+            }
+        }
+        interfaces {
+            gr-0/0/0.11;
+        }
+    }
[edit interfaces gr-0/0/0]
+    unit 11 {
+        description To_TWACG;
+        tunnel {
+            source 218.253.210.8;
+            destination 202.168.193.128;
+        }
+        family inet {
+            address 10.32.0.102/30;
+        }
+    }
[edit routing-options static]
     route 172.16.3.0/24 { ... }
+    route 10.11.12.0/24 next-hop 10.32.0.101;
```

```
set security policies from-zone TWACG to-zone GPO policy For_DBBACKUP match source-address DB_10.11.12.0/24
set security policies from-zone TWACG to-zone GPO policy For_DBBACKUP match destination-address Backup_10.32.32.130
set security policies from-zone TWACG to-zone GPO policy For_DBBACKUP match application any
set security policies from-zone TWACG to-zone GPO policy For_DBBACKUP then permit
set security zones security-zone GPO address-book address Backup_10.32.32.130 10.32.32.130/32
set security zones security-zone TWACG address-book address DB_10.11.12.0/24 10.11.12.0/24
set security zones security-zone TWACG host-inbound-traffic system-services ping
set security zones security-zone TWACG interfaces gr-0/0/0.11
set interfaces gr-0/0/0 unit 11 description To_TWACG
set interfaces gr-0/0/0 unit 11 tunnel source 218.253.210.8
set interfaces gr-0/0/0 unit 11 tunnel destination 202.168.193.128
set interfaces gr-0/0/0 unit 11 family inet address 10.32.0.102/30
set routing-options static route 10.11.12.0/24 next-hop 10.32.0.101


set security policies from-zone MNL to-zone GPO policy For_ACG_DB_Backup match source-address TCT_DBA_10.22.12.103
set security policies from-zone MNL to-zone GPO policy For_ACG_DB_Backup match destination-address Backup_10.32.32.130
set security policies from-zone MNL to-zone GPO policy For_ACG_DB_Backup match application junos-ping
set security policies from-zone MNL to-zone GPO policy For_ACG_DB_Backup match application TCP_11129
set security policies from-zone MNL to-zone GPO policy For_ACG_DB_Backup match application junos-ssh
set security policies from-zone MNL to-zone GPO policy For_ACG_DB_Backup then permit
set security zones security-zone MNL address-book address TCT_DBA_10.22.12.103 10.22.12.103/32
```

#### [Juniper] packet capture

**_Configure forwarding options_**

```
[edit]
user@host# edit forwarding-options packet-capture
[edit forwarding-options packet-capture]
user@host#
Specify a file name for the packet capture and set the maximum-capture-size to 1500 as below:
[edit forwarding-options packet-capture]
user@host# set file filename testpacketcapture
[edit forwarding-options packet-capture]
user@host# set maximum-capture-size 1500
[edit forwarding-options packet-capture]
user@host# show
file filename testpacketcapture;
maximum-capture-size 1500;
[edit forwarding-options packet-capture]
user@host#top
```

**_Configure firewall filter for packet capture._**

```
user@host# set firewall filter PCAP term 1 from source-address 10.209.144.32
user@host# set firewall filter PCAP term 1 from destination-address 10.204.115.166
user@host# set firewall filter PCAP term 1 then sample
user@host# set firewall filter PCAP term 1 then accept
user@host# set firewall filter PCAP term 2 from source-address 10.204.115.166
user@host# set firewall filter PCAP term 2 from destination-address 10.209.144.32
user@host# set firewall filter PCAP term 2 then sample
user@host# set firewall filter PCAP term 2 then accept
user@host# set firewall filter PCAP term allow-all-else then accept
```

**_Apply firewall fIlter to desired interface_**

```
user@host# set interfaces ge-0/0/0 unit 0 family inet filter output PCAP
user@host# set interfaces ge-0/0/0 unit 0 family inet filter input PCAP
user@host# commit
```

**_Copy packet capture file from the SRX or J-Series device, and view it with your PCAP utility._**

```
user@host> file list /var/tmp/ | match testpacketcapture*
testpacketcapture1.ge-0.0
```

##### log session

```
set security policies from-zone IT to-zone INTERNET policy For_Tset then log session-init
set security policies from-zone IT to-zone INTERNET policy For_Test then log session-close
show log traffic-log
```

##### 設定相關 Filter 做 Debug Mode 使用

```
root@junos-SRX> show configuration security flow | display set
set security flow traceoptions file tracetest
set security flow traceoptions flag basic-datapath
set security flow traceoptions packet-filter ICMP-Filter protocol icmp
set security flow traceoptions packet-filter ICMP-Filter source-prefix 192.168.88.0/24
set security flow traceoptions packet-filter ICMP-Filter destination-prefix 168.95.1.1/32
root@junos-SRX> show configuration security flow
traceoptions {
    file tracetest;
    flag basic-datapath;
    packet-filter ICMP-Filter {
        protocol icmp;
        source-prefix 192.168.88.0/24;
        destination-prefix 168.95.1.1/32;
    }
}
```

檢查 Log 檔

```
root@junos-SRX> show log tracetest
```

#### [Juniper] SRX Cluster HA 設定

- 測試環境：SRX 220H 兩台
- SRX 220H Cluster 默認端口
- (fxp0)管理端口：Ge-0/0/6
- (Control Plane：fxp1)控制端口：Ge-0/0/7
- (Fabric Link 也叫 Data Plane：fab)數據同步端口：Ge-0/0/1
- 使用集群則集群後接口標示為：Ge-0/0/0-7; Ge-3/0/0-7
- 不同型號集群後端口顯示不同，參考[官方手冊](http://www.juniper.net/documentation/en_US/junos12.1/topics/reference/general/chassis-cluster-srx-series-node-interface-understanding.html#table-srx-cluster-interface-naming)

**_配置設定_**

```
On device A:>set chassis cluster cluster-id 1 node 0 reboot
On device B:>set chassis cluster cluster-id 1 node 1 reboot
On device A:
set groups node0 system host-name SRX-Primary
set groups node0 interfaces fxp0 unit 0 family inet address 10.10.30.189/24
set groups node1 system host-name SRX-Secondby
set groups node1 interfaces fxp0 unit 0 family inet address 10.10.30.190/24
set apply-groups "${node}"
set interfaces fab0 fabric-options member-interfaces ge-0/0/1
set interfaces fab1 fabric-options member-interfaces ge-3/0/1
set chassis cluster redundancy-group 0 node 0 priority 100
set chassis cluster redundancy-group 0 node 1 priority 1
set chassis cluster redundancy-group 1 node 0 priority 100
set chassis cluster redundancy-group 1 node 1 priority 1
set chassis cluster redundancy-group 1 interface-monitor ge-0/0/3 weight 255
set chassis cluster redundancy-group 1 interface-monitor ge-0/0/4 weight 255
set chassis cluster redundancy-group 1 interface-monitor ge-0/0/5 weight 255
set chassis cluster redundancy-group 1 interface-monitor ge-3/0/3 weight 255
set chassis cluster redundancy-group 1 interface-monitor ge-3/0/4 weight 255
set chassis cluster redundancy-group 1 interface-monitor ge-3/0/5 weight 255
set chassis cluster reth-count 3
set interfaces ge-0/0/3 gigether-options redundant-parent reth0
set interfaces ge-3/0/3 gigether-options redundant-parent reth0
set interfaces reth0 redundant-ether-options redundancy-group 1
set interfaces reth0 unit 0 family inet address 192.168.3.1/24
set interfaces ge-0/0/4 gigether-options redundant-parent reth1
set interfaces ge-3/0/4 gigether-options redundant-parent reth1
set interfaces reth1 redundant-ether-options redundancy-group 1
set interfaces reth1 unit 0 family inet address 192.168.4.1/24
set interfaces ge-0/0/5 gigether-options redundant-parent reth2
set interfaces ge-3/0/5 gigether-options redundant-parent reth2
set interfaces reth2 redundant-ether-options redundancy-group 1
set interfaces reth2 unit 0 family inet address 192.168.5.1/24
set security zones security-zone trust interfaces reth0.0
set security zones security-zone untrust interfaces reth1.0
set security zones security-zone DMZ interfaces reth2.0
```

**_配置說明_**

```
On device A: >set chassis cluster cluster-id 1 node 0 reboot
//定義cluster-id 和node，同一個集群cluster-id 必須相同，取值範圍為0-15，0 代表禁用集群；node 取值範圍為0-1, 0代表主設備
On device B: >set chassis cluster cluster-id 1 node 1 reboot
//定義cluster-id 和node，同一個集群cluster-id 必須相同，取值範圍為0-15，0 代表禁用集群；node 取值範圍為0-1, 0代表主設備
On device A:
set groups node0 system host-name SRX-Primary
set groups node0 interfaces fxp0 unit 0 family inet address 10.10.30.189/24
set groups node1 system host-name SRX-Secondby
set groups node1 interfaces fxp0 unit 0 family inet address 10.10.30.190/24
//為集群設備配置單獨的名字和管理IP 地址
set apply-groups "${node}"
//讓以上的全域配置應用到每個獨立的節點上
set interfaces fab0 fabric-options member-interfaces ge-0/0/1
set interfaces fab1 fabric-options member-interfaces ge-3/0/1
//定義數據同步端口並關聯連接埠
set chassis cluster redundancy-group 0 node 0 priority 100
set chassis cluster redundancy-group 0 node 1 priority 1
set chassis cluster redundancy-group 1 node 0 priority 100
set chassis cluster redundancy-group 1 node 1 priority 1
//設置冗餘組的對不同節點的優先級，優先級範圍1-254.值越大優先級越高，一般習慣定義2 個冗餘組，redundancy-group 0 用於控制引擎，redundancy-group 1 用於控制數據引擎，當然也可以為每組冗餘連接埠放在一個redundancy-group 組中
set chassis cluster redundancy-group 1 interface-monitor ge-0/0/3 weight 255
set chassis cluster redundancy-group 1 interface-monitor ge-0/0/4 weight 255
set chassis cluster redundancy-group 1 interface-monitor ge-0/0/5 weight 255
set chassis cluster redundancy-group 1 interface-monitor ge-3/0/3 weight 255
set chassis cluster redundancy-group 1 interface-monitor ge-3/0/4 weight 255
set chassis cluster redundancy-group 1 interface-monitor ge-3/0/5 weight 255
//配置接口監控在數據冗餘口，不建議配置接口監控在redundancy-group 0，當監控到接口故障後優先級降255，實現數據口冗餘自動切換
set chassis cluster reth-count 3
//定義集群最多支持多少組冗餘接口，必須不低於當前配置的冗餘口組數目，否則將有超過數量的冗餘口不能正常工作，超過冗餘組的冗餘接口的路由訊息都不生效
set interfaces ge-0/0/3 gigether-options redundant-parent reth0
set interfaces ge-3/0/3 gigether-options redundant-parent reth0
set interfaces reth0 redundant-ether-options redundancy-group 1
//把物理連接埠加入到冗餘接口reth，並把接口reth0 加入數據冗餘組redundancy-group 1
set interfaces reth0 unit 0 family inet address 192.168.3.1/24
//為冗餘邏輯接口配置IP 地址
set interfaces ge-0/0/4 gigether-options redundant-parent reth1
set interfaces ge-3/0/4 gigether-options redundant-parent reth1
set interfaces reth1 redundant-ether-options redundancy-group 1
//把物理連接埠加入到冗餘接口reth，並把接口reth1 加入數據冗餘組redundancy-group 1
set interfaces reth1 unit 0 family inet address 192.168.4.1/24
//為冗餘邏輯接口配置IP 地址
set interfaces ge-0/0/5 gigether-options redundant-parent reth2
set interfaces ge-3/0/5 gigether-options redundant-parent reth2
set interfaces reth2 redundant-ether-options redundancy-group 1
//把物理連接埠加入到冗餘接口reth，並把接口reth2 加入數據冗餘組redundancy-group 1
set interfaces reth2 unit 0 family inet address 192.168.5.1/24
//為冗餘邏輯接口配置IP 地址
set security zones security-zone trust interfaces reth0.0
set security zones security-zone untrust interfaces reth1.0
set security zones security-zone DMZ interfaces reth2.0
//把集群的邏輯接口關聯到ZONE
```

#### [Juniper] SRX 自動備份

> SRX 也 support 用 tftp 或是 scp 的方式做檔案上傳

**_設定有修改設定檔 commit 就自動備份_**

```
root@888# show  system archival | display set
set system archival configuration transfer-on-commit
set system archival configuration archive-sites "ftp://帳號@192.168.88.1/路徑";; password "ftp密碼"
```

**_設定有每日自動備份(1440 單位為 minute)_**

```
root@888# show system archival | display set
set system archival configuration transfer-interval "1440"
set system archival configuration archive-sites "ftp://帳號@192.168.88.1/路徑";; password "ftp密碼"
```

**_還原備份檔案_**

```
[edit]
root@888# edit system archival configuration
[edit system archival configuration]
root@888# load merge ftp://username:password@192.168.88.1/888_juniper.conf.gz_20151227_185001
load complete
[edit system archival configuration]
```
