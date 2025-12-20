---
title: "[Juniper Firewall] command"
date: 2018-06-27T00:58:01+08:00
menu:
  sidebar:
    name: "[Juniper Firewall] command"
    identifier: firewall-juniper-command-record-in-time-city
    weight: 10
tags: ["Firewall", "Juniper"]
categories: ["Firewall", "Juniper"]
---

下列操作命令在操作模式下使用，或在配置模式下 run show…

查看當前防火牆 session 數

```
show security flow session | match 10.22.12.104
show security flow session source-prefix 10.22.12.104
```

清除當前 session

```
clear security flow session all
```

查 OID

```
show snmp mib walk decimal 1.3.6.1.2.1.2.2.1.2
```

查看當前軟體版本號

```
show system software
```

查看系統啟動時間

```
show system uptime
```

查看硬體板卡及序列號

```
show chassis haredware
```

查看硬體板卡當前狀態

```
show chassis environment
```

查看路由表

```
show route
```

設備商的 Administrative distance / Route preference 預設值比較

查看 ARP 表

```
show arp
```

查看系統 log

```
show log messages
```

查看所有介面運行狀態

```
show interface terse
```

查看介面運行細節資訊

```
show interface ge-x/y/z detail
```

動態統計介面資料包轉發資訊

```
monitor interface ge-x/y/z
```

檢查 ALG 開啟情況

```
show security alg status
```

LOG

```
file list /cf/var/log | match cpu_date_0
```

BGP Black hole set up

基本設定
恢復原廠設定

```
root@srx#start shell
root@srx%
root@srx%cli
root@srx#
root@srx#load factory-default
warning: activing factory configuration *恢復原廠設定後，需立即設置 ROOT 帳密
root@srx# set system root-authentication plain-text-password
root@srx#commit
```

遠端管理帳密配置

```
root@srx#set system login user username class super-user authentication plain-text-password

set system login user support029 uid 2029
set system login user support029 class ADMIN
set system login user support029 encrypted-password "$5$JQoeH.gs$f6/3srHsGRvvEXZ5Ok/Hpj/uc1CG.sPQZfXMoCXaWk8"
# 帳號為 username，擁有 super-user 權限
# 設定連線者 5 分鐘 timeout

set system login idle-timeout 5
```

設定連線者以特定 IP 登入

```
set policy-options prefix-list manager-ip 8.8.8.8/32
```

設置系統時間

```
root@srx#run set date 201711011329.14
root@srx#set system ntp server 168.95.1.1
```

設定設備名稱

```
root@srx#set system host-name QQ
root@QQ#
```

設定 Domain Name

```
root@srx#set system domain-name abc.cde
```

設定 DNS

```
root@srx#set system name-server 8.8.8.8
```

開啟 ssh 遠端管理

```
root@srx#set system service ssh
```

開啟 https 遠端管理

```
root@srx#set system service web-management https
```

加註解

```
root@srx#annotate
```

######加入這兩條 Policy 的 log session ### 可以查看 log debug 問題

```
set security policies from-zone DB to-zone INTERNET policy For_Postgres then log session-init
set security policies from-zone DB to-zone INTERNET policy For_Postgres then log session-close
show log traffic-log
```
