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

The following commands are run in operational mode, or use `run show` in configuration mode.

Show current firewall session count

```
show security flow session | match 10.22.12.104
show security flow session source-prefix 10.22.12.104
```

Clear current sessions

```
clear security flow session all
```

Query OID

```
show snmp mib walk decimal 1.3.6.1.2.1.2.2.1.2
```

Check current software version

```
show system software
```

Check system uptime

```
show system uptime
```

Check hardware cards and serial numbers

```
show chassis haredware
```

Check current hardware status

```
show chassis environment
```

Show routing table

```
show route
```

Vendor default values for administrative distance / route preference

Show ARP table

```
show arp
```

Show system log

```
show log messages
```

Show all interface statuses

```
show interface terse
```

Show interface detail

```
show interface ge-x/y/z detail
```

Monitor interface packet forwarding stats

```
monitor interface ge-x/y/z
```

Check ALG status

```
show security alg status
```

LOG

```
file list /cf/var/log | match cpu_date_0
```

BGP black hole setup

Basic setup
Factory reset

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

Remote management credentials

```
root@srx#set system login user username class super-user authentication plain-text-password

set system login user support029 uid 2029
set system login user support029 class ADMIN
set system login user support029 encrypted-password "$5$JQoeH.gs$f6/3srHsGRvvEXZ5Ok/Hpj/uc1CG.sPQZfXMoCXaWk8"
# Account is username with super-user privileges
# Set session timeout to 5 minutes

set system login idle-timeout 5
```

Allow login from specific IP

```
set policy-options prefix-list manager-ip 8.8.8.8/32
```

Set system time

```
root@srx#run set date 201711011329.14
root@srx#set system ntp server 168.95.1.1
```

Set hostname

```
root@srx#set system host-name QQ
root@QQ#
```

Set domain name

```
root@srx#set system domain-name abc.cde
```

Set DNS

```
root@srx#set system name-server 8.8.8.8
```

Enable SSH remote management

```
root@srx#set system service ssh
```

Enable HTTPS remote management

```
root@srx#set system service web-management https
```

Add annotation

```
root@srx#annotate
```

######Add these two policy log session lines ### to view log debug issues

```
set security policies from-zone DB to-zone INTERNET policy For_Postgres then log session-init
set security policies from-zone DB to-zone INTERNET policy For_Postgres then log session-close
show log traffic-log
```
