---
title: "Switch notes"
date: 2017-11-25T11:47:37+08:00
menu:
  sidebar:
    name: "Switch notes"
    identifier: network-switch-cisco-my-notes
    weight: 10
tags: ["Network", "Switch", "Cisco"]
categories: ["Network", "Switch", "Cisco"]
hero: images/hero/network.png
---

#### Switch

**_Switch 通常是 L2 設備_**

- 只會將封包傳送到指定目的地的電腦（透過 MAC Table），相對上能減少資料碰撞及資料被竊聽的機會。交換器更能將同時傳到的封包分別處理，而集線器則不能。

**_Hub 則是 L1 設備_**

- 會將網路內某一使用者傳送的封包傳至所有已連接到集線器的電腦，因會碰撞所以 random retry。

**_MAC Table_**

1. Learning
   - 從某個 Port 收到某網段（設為 A）MAC 位址為 X 的計算機發給 MAC 位址為 Y 的計算機的資料包。交換機從而記下了 MAC 位址 X 在網段 A。這稱為學習(learning)。
2. Flooding
   - 交換機還不知道 MAC 位址 Y 在哪個網段上，於是向除了 A 以外的所有網段轉發該資料包。這稱為洪水(flooding)。
3. Forwarding
   - MAC 位址 Y 的電腦收到該封包，向 MAC 位址 X 發出確認包。交換器收到該包後，從而記錄下 MAC 位址 Y 所在的網段。交換機向 MAC 位址 X 轉發確認包。這稱為轉發(forwarding)。
4. Filtering
   - 交換機收到一個資料包，查表後發現該資料包的來源位址與目的位址屬於同一網段。交換機將不處理該資料包，這稱為過濾(filtering)。
5. Aging
   - 交換機內部的 MAC 位址-網段查詢表的每條記錄採用時間戳記錄最後一次存取的時間。早於某個閾值（用戶可配置）的記錄被清除，這稱為老化(aging)。

##### Vlan

Switch Interface 需支援 802.1Q

- Channel - 最多 8 隻腳對接，加大頻寬、備援。

**_Spanning Tree_**

- Spanning Tree Protocol (擴展樹協定) 技術可以令到網絡之間擁有備援功能，英文簡稱 STP。萬一真的出現網絡線中斷，它能夠在整過網絡自動偵測哪裡出現問題，然之後將備援線開啟，令到網絡繼續運行，使用者幾乎是沒有感受到網絡中斷。
- 除了得到備援功能之外，亦能避免迴轉 (Looping) 問題，這意思是網絡上 Switch 與 Switch 之間的網絡線形成迴圈。這裡有一個例子，萬一網管人員不小心插入一條能令網絡迴圈的網絡線，那麼 Spanning Tree 就會自動將網絡變成不迴圈情況。
- Spanning Tree 是以路徑成本來計算 Switch 那一個埠是 Root Port、Designed Port、Block Port，這先要其中一台 Switch 成為 Root Bridge，要成為 Root Bridge 是以 Priority Number 加上 MAC 地址的最小值來決定，MAC 地址越小代表越早出廠。
- 一般來說如果重新計算哪一台 Switch 成為 Root Bridge 需要 60 秒，期間服務不 Work。

**_Vlan tag_**

- 任一隻接腳
  - 不支援 802.1Q
  - 支援 802.1Q - 會在封包的 L2 加上 Tag
    - Trunk - 可以多個 Tag
      - 只收有 Tag 的封包
      - 送的時候 Tag 保留
    - Access - 只能 1 個 Tag
      - 只收沒有 Tag 的封包
      - 送的時候 Tag 拿掉

#### [Cisco Switch] 自動備份設定檔

```
# 先設定排程指令與 tftp server IP
config t
kron policylist
backup
cli write
cli show run | redirect tftp://192.168.0.50/DemoSW.cfg
exit
# 設定排程指令執行的時間
kron occurrence backup at 05:30 recurring
policylist
backup
end
# 存檔並顯示排程設定
write
show kron schedule
```

#### [Cisco Switch] 端口限速

低階端 Cisco Switch 只能針對 Inbound 流量限速

流量限速設定方式如下
先在 Global 端啟用 Qos 功能

`mls qos`

**_5M 範本_**

```
# 設定ACL指定來源IP
ip access-list extended ACL_5M
permit ip any any
# 指定CLASS套用ACL範本，標記封包
class-map match-all CLASS_5M
  match access-group name ACL_5M
# 指定policy套用CLASS，並指定限制速度
# (此處限速5M，並且允許Burst 100KB，多出來的封包會Drop掉)
policy-map POLICY_5M
  class CLASS_5M
    police 5000000 100000 exceed-action drop
# 對要限速的端口做限速5M
interface GigabitEthernet0/2
service-policy input POLICY_5M
```

**_10M 範本_**

```
ip access-list extended ACL_10M
permit ip any any
class-map match-all CLASS_10M
  match access-group name ACL_10M
policy-map POLICY_10M
  class CLASS_10M
    police 10000000 100000 exceed-action drop
interface GigabitEthernet0/2
service-policy input POLICY_10M
```

**_15M 範本_**

```
ip access-list extended ACL_15M
permit ip any any
class-map match-all CLASS_15M
  match access-group name ACL_15M
policy-map POLICY_15M
  class CLASS_15M
    police 15000000 100000 exceed-action drop
# 指定介面
interface GigabitEthernet0/2
service-policy input POLICY_15M
```

#### [Cisco Switch] DHCP

DHCP 主機由 SW1 擔任，而 172.16.31.0 網段的主機需要透過 DHCP Relay 來取得 IP

```
SW1#configure t
Enter configuration commands, one per line. End with CNTL/Z.
# 先設定interface的IP位址
SW1(config)#interface fa1/0
SW1(config-if)#no switchport
SW1(config-if)#ip address 192.168.1.1 255.255.255.252
SW1(config-if)#no shutdown
SW1(config-if)#exit
SW1(config)#interface fa1/1
SW1(config-if)#no switchport
SW1(config-if)#ip address 10.10.10.254 255.255.255.0
SW1(config-if)#no shutdown
SW1(config-if)#exit
SW1(config)#exit
# 設定RIP路由
SW1(config)#router rip
SW1(config-router)#version 2
SW1(config-router)#network 192.168.1.0
SW1(config-router)#network 10.10.10.0
SW1(config-router)#exit
SW1(config)#exit
# 設定10.10.10.0網段的DHCP pool
SW1(config)#ip dhcp excluded-address 10.10.10.101 10.10.10.200
SW1(config)#ip dhcp pool 10-net
SW1(dhcp-config)#network 10.10.10.0 255.255.255.0
SW1(dhcp-config)#default-router 10.10.10.254
SW1(dhcp-config)#lease infinite
SW1(dhcp-config)#dns-server 168.95.1.1
SW1(dhcp-config)#end
# 設定172.16.31.0網段的DHCP pool
SW1#configure t
Enter configuration commands, one per line. End with CNTL/Z.
SW1(config)#ip dhcp excluded-address 172.16.31.101 172.16.31.200
SW1(config)#ip dhcp pool 172-net
SW1(dhcp-config)#network 172.16.31.0 255.255.255.0
SW1(dhcp-config)#default-router 172.16.31.254
SW1(dhcp-config)#dns-server 168.95.1.1
SW1(dhcp-config)#lease infinite
SW1(dhcp-config)#end
SW1#wr
# 先設定Interface的IP位址
SW2(config)#interface fa1/0
SW2(config-if)#no switchport
SW2(config-if)#ip address 192.168.1.2 255.255.255.252
SW2(config-if)#no shutdown
SW2(config-if)#exit
SW2(config)#interface fa1/1
SW2(config-if)#no switchport
SW2(config-if)#ip address 172.16.31.254 255.255.255.0
SW2(config-if)#ip helper-address 192.168.1.1 (設定DHCP Relay)
SW2(config-if)#no shutdown
SW2(config-if)#exit
# 設定RIP路由
SW2(config)#router rip
SW2(config-router)#version 2
SW2(config-router)#network 192.168.1.0
SW2(config-router)#network 172.16.31.0
SW2(config-router)#exit
SW2(config)#exit
SW2#wr
# 檢查DHCP取得IP的狀況
SW1#show ip dhcp binding
```
