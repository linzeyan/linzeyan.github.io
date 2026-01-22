---
title: "Fortigate 在 HA 模式下的管理介面"
date: 2020-09-08T09:47:47+08:00
menu:
  sidebar:
    name: "Fortigate 在 HA 模式下的管理介面"
    identifier: dediziertes-management-interface-fur-fortigate-im-ha-betrieb
    weight: 10
tags: ["Links", "Fortigate", "Firewall"]
categories: ["Links", "Fortigate", "Firewall"]
---

- [Fortigate 在 HA 模式下的管理介面](https://www.unixfu.ch/dediziertes-management-interface-fur-fortigate-im-ha-betrieb/)

##### 先啟用此功能

```
config system ha
   set ha-mgmt-status enable
   config ha-mgmt-interfaces
      edit 1
         set interface wan2
         set gateway 192.168.147.254
      next
   end
end
```

別忘了設定預設閘道。這個介面是隔離的，需要獨立的路由設定。

##### 接著為叢集中的每個節點設定獨立 IP

System1

```
config system interface
   edit wan2
      set ip 10.11.101.101/24
      set allowaccess https ping ssh snmp
   next
end
```

System2

```
config system interface
   edit wan2
      set ip 10.11.101.102/24
      set allowaccess https ping ssh snmp
   next
end
```

---

#### FortiOS 5.6 起新增

從 FortiOS 5.6 開始，有一種新的方式可以直接存取每台設備。這是 In-Band 的方法，不需要保留介面。

##### 在任意介面設定管理用 IP 位址。這個位址不會在叢集中同步。

System1

```
config system interface
   edit mgmt1
      set ip 10.11.101.254/24
      set management-ip 10.11.101.251/24
      set allow access https ping ssh snmp
   next
end
```

System2

```
config system interface
   edit mgmt1
      set ip 10.11.101.254/24
      set management-ip 10.11.101.252/24
      set allow access https ping ssh snmp
   next
end
```

現在每台設備都可以單獨存取，使用一般的路由表即可。
