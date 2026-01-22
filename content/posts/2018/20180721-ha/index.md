---
title: "HA command"
date: 2018-07-21T14:45:29+08:00
menu:
  sidebar:
    name: "HA command"
    identifier: firewall-juniper-ha-commands
    weight: 10
tags: ["Firewall", "Juniper"]
categories: ["Firewall", "Juniper"]
---

```
load merge relative terminal

# On a brand-new device without HA enabled, you must define the cluster ID.
# Cluster ID must be unique and cannot duplicate other SRX, because HA creates a virtual MAC address and this ID affects it. Duplicates may cause MAC duplication and unexpected errors.
#

request system zeroize

# The following commands must be run in `>` mode.
set chassis cluster cluster-id <ID range 0~255> node 0 # This is on node 0
set chassis cluster cluster-id <ID range 0~255> node 1 # This is on node 1

# On the secondary node, run this command.
request chassis cluster configuration-synchronize


# After reboot, you will see Hold or standby; check whether the cluster is up.

show chassis cluster status

# This appears only after RETH interfaces are created; you must configure first.
show chassis cluster interfaces

# The following commands are run in config mode; build the config first.


---

# The backup-router is for the HA standby device management interface (fxp) so it can respond to routing; by default the standby does not enable the routing engine, so this is required.

set groups node0 system host-name SRX-node0
set groups node0 system backup-router 10.10.0.254
set groups node0 system backup-router destination 0.0.0.0/0
set groups node0 interfaces fxp0 unit 0 family inet address 10.10.0.2/24
set groups node1 system host-name SRX-node1
set groups node1 system backup-router 10.10.0.254
set groups node1 system backup-router destination 0.0.0.0/0
set groups node1 interfaces fxp0 unit 0 family inet address 10.10.0.3/24

set apply-groups "${node}"
set system time-zone Asia/Taipei

set chassis cluster control-link-recovery
set chassis cluster reth-count 10
set chassis cluster heartbeat-interval 2000

# It is recommended to enable IPv6 during setup using the following command, because enabling IPv6 later requires a reboot.
set security forwarding-options family inet6 mode flow-based


# Interface numbers vary by chassis model.
# The easiest way is to check how many slots the device has. For example, SRX550HM has expansion 0-8, so HA starts at 9, hence ge-9/x/x.
set chassis cluster redundancy-group 0 node 0 priority 150
set chassis cluster redundancy-group 0 node 1 priority 100
set chassis cluster redundancy-group 0 interface-monitor ge-0/0/3 weight 150
set chassis cluster redundancy-group 0 interface-monitor ge-0/0/5 weight 150
set chassis cluster redundancy-group 0 interface-monitor ge-9/0/3 weight 100
set chassis cluster redundancy-group 0 interface-monitor ge-9/0/5 weight 100

set chassis cluster redundancy-group 1 node 0 priority 150
set chassis cluster redundancy-group 1 node 1 priority 100
set chassis cluster redundancy-group 1 interface-monitor ge-0/0/3 weight 150
set chassis cluster redundancy-group 1 interface-monitor ge-0/0/5 weight 150
set chassis cluster redundancy-group 1 interface-monitor ge-9/0/3 weight 100
set chassis cluster redundancy-group 1 interface-monitor ge-9/0/5 weight 100


# This is the data sync setting for redundancy group 1; you must set it to enable the ge-0/0/2 heartbeat link.
set interfaces fab0 fabric-options member-interfaces ge-0/0/2
set interfaces fab1 fabric-options member-interfaces ge-9/0/2

# Add interfaces to the reth group.
set interfaces ge-0/0/3 gigether-options redundant-parent reth0
set interfaces ge-0/0/4 gigether-options redundant-parent reth0
set interfaces ge-9/0/3 gigether-options redundant-parent reth0
set interfaces ge-9/0/4 gigether-options redundant-parent reth0

set interfaces ge-0/0/5 gigether-options redundant-parent reth1
set interfaces ge-9/0/5 gigether-options redundant-parent reth1

set interfaces reth0 vlan-tagging
# You must add RETH to the data sync group, otherwise it will not work.
set interfaces reth0 redundant-ether-options redundancy-group 1

# Note: SRX uses LACP passive mode, but the switch must use LACP active mode.
set interfaces reth0 redundant-ether-options lacp passive
set interfaces reth0 redundant-ether-options lacp periodic slow


set interfaces reth1 redundant-ether-options redundancy-group 1
set interfaces reth1 unit 0 family inet address 202.99.240.100/26
```
