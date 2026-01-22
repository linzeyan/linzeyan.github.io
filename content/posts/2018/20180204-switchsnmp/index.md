---
title: "How to Enable SNMP on a Switch"
date: 2018-02-04T14:48:12+08:00
menu:
  sidebar:
    name: "How to Enable SNMP on a Switch"
    identifier: switch-cisco-how-to-enable-snmp-configuration
    weight: 10
tags: ["Links", "Switch", "Cisco"]
categories: ["Links", "Switch", "Cisco"]
---

- [How to Enable SNMP on a Switch](https://itlocation.blogspot.com/2013/10/switchsnmp.html)

Use `snmp-server` as the main command.

`C3750(Config)#snmp-server community RO`

This is the shared secret for SNMP communication.
RO means Read Only (SNMP tools are not allowed to modify settings).
RW means Read and Write (SNMP tools can modify settings).

`C3750(config)#snmp-server group SNMP_ROA v3 priv match exact`

1. SNMP group name: SNMP_ROA
2. Version: v3
3. Highest priv level

`C3750(config)#snmp-server user cater SNMP_ROA v3 auth MD5 cisco12345 priv des56 test12345`

This is related to PRTG configuration and must be recorded correctly.

1. User: cater
2. Group: SNMP_ROA
3. Auth mode: MD5
4. Auth password (MD5): cisco12345 (PRTG requires at least 8 characters)
5. Priv password: test12345 (PRTG requires at least 8 characters)

`C3750(config)#snmp-server host 192.168.3.100 version 3 priv cater`

1. SNMP server: 192.168.3.100
2. Use version 3
3. Use priv mode with user cater
