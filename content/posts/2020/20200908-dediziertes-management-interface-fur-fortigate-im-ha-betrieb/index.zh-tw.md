---
title: "Fortigate Management Interface in HA Mode"
date: 2020-09-08T09:47:47+08:00
menu:
  sidebar:
    name: "Fortigate Management Interface in HA Mode"
    identifier: dediziertes-management-interface-fur-fortigate-im-ha-betrieb
    weight: 10
tags: ["URL", "Fortigate", "Firewall"]
categories: ["URL", "Fortigate", "Firewall"]
---

- [Fortigate Management Interface in HA Mode](https://www.unixfu.ch/dediziertes-management-interface-fur-fortigate-im-ha-betrieb/)

##### First you activate the feature

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

Do not forget to set a default gateway. This interface is isolated and requires its own routing.

##### Then you assign an individual IP address to every node in the cluster

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

#### New since FortiOS 5.6

Starting with FortiOS 5.6, there is a new way to access every machine directly. This method is In-Band and does not require a reserved interface.

##### Assign on any interface a management IP-address. This address will not be synchronised in the cluster.

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

Every device can be accessed individually now. The regular routing table applies.
