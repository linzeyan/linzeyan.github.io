---
title: "如何在 Switch 上啟用 snmp 設定"
date: 2018-02-04T14:48:12+08:00
menu:
  sidebar:
    name: "如何在 Switch 上啟用 snmp 設定"
    identifier: switch-cisco-how-to-enable-snmp-configuration
    weight: 10
tags: ["URL", "Switch", "Cisco"]
categories: ["URL", "Switch", "Cisco"]
---

- [如何在 Switch 上啟用 snmp 設定](https://itlocation.blogspot.com/2013/10/switchsnmp.html)

以 snmp-server 為主要指令

`C3750(Config)#snmp-server community RO`

指的是 SNMP 協定時互相溝通的密碼
RO 指的是 Read Only (SNMP 工具不允許修改設定)
RW 指的是 Read and Write (SNMP 工具可以修改設定)

`C3750(config)#snmp-server group SNMP_ROA v3 priv match exact`

1. 設定 SNMP Group 名： SNMP_ROA
2. Version ： V3
3. 最高的 priv

`C3750(config)#snmp-server user cater SNMP_ROA v3 auth MD5 cisco12345 priv des56 test12345`

這行設定跟 PRTG 設定有關聯，一定要記清楚

1. 使用者 ：cater
2. 隸屬 Group 為：SNMP_ROA
3. 驗證模式 ：MD5
4. 密碼(MD5) ：cisco12345 (PRTG 要求要 8 碼以上)
5. Priv 驗證密碼 ：test12345 (PRTG 要求要 8 碼以上)

`C3750(config)#snmp-server host 192.168.3.100 version 3 priv cater`

1. 指定 SNMP SERVER：192.168.3.100 2.
2. 使用 Version 3
3. 使用 Priv 模式，使用者為 cater
