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

**_Switches are usually L2 devices_**

- They forward packets only to the destination host (based on the MAC table), which reduces collisions and eavesdropping. Switches can also handle packets arriving at the same time, while hubs cannot.

**_Hubs are L1 devices_**

- They forward packets from any host to all connected hosts, so collisions happen and cause random retries.

**_MAC Table_**

1. Learning
   - A packet arrives on some port (network A) from MAC X destined for MAC Y. The switch records that MAC X is on network A. This is called learning.
2. Flooding
   - The switch does not yet know where MAC Y is, so it forwards the packet to all networks except A. This is called flooding.
3. Forwarding
   - The host with MAC Y receives the packet and sends an ACK to MAC X. The switch records that MAC Y is on that network, then forwards the ACK to MAC X. This is forwarding.
4. Filtering
   - The switch receives a packet and finds that the source and destination MACs are on the same network, so it drops the packet. This is filtering.
5. Aging
   - Each MAC-table entry has a timestamp of last access. Entries older than a threshold (configurable) are removed. This is aging.

##### Vlan

Switch interfaces must support 802.1Q

- Channel - up to 8 links bundled to increase bandwidth and provide redundancy.

**_Spanning Tree_**

- Spanning Tree Protocol (STP) provides redundancy. If a link fails, it detects the issue and brings up a backup path so the network keeps running with little interruption.
- It also avoids loops, where links between switches form a cycle. For example, if an admin accidentally plugs in a cable that creates a loop, STP automatically removes the loop.
- STP uses path cost to decide which ports are Root, Designated, and Block. One switch becomes the Root Bridge, chosen by the lowest Priority Number plus MAC address; smaller MAC means earlier manufacturing.
- Recomputing the Root Bridge usually takes 60 seconds, during which service does not work.

**_Vlan tag_**

- Any port
  - Does not support 802.1Q
  - Supports 802.1Q - adds a tag at L2
    - Trunk - multiple tags
      - Only receives tagged frames
      - Keeps tags on egress
    - Access - only one tag
      - Only receives untagged frames
      - Removes tags on egress

#### [Cisco Switch] Automatic config backup

```
# Set scheduled commands and the TFTP server IP
config t
kron policylist
backup
cli write
cli show run | redirect tftp://192.168.0.50/DemoSW.cfg
exit
# Set the schedule time
kron occurrence backup at 05:30 recurring
policylist
backup
end
# Save and show the schedule
write
show kron schedule
```

#### [Cisco Switch] Port rate limiting

Entry-level Cisco switches can only rate-limit inbound traffic

Rate limiting setup as follows
First enable QoS globally

`mls qos`

**_5M Template_**

```
# Configure an ACL to match source IP
ip access-list extended ACL_5M
permit ip any any
# Bind the ACL to a class and mark packets
class-map match-all CLASS_5M
  match access-group name ACL_5M
# Bind the class to a policy and set the rate limit
# (Rate limit to 5M and allow 100KB burst; excess packets are dropped)
policy-map POLICY_5M
  class CLASS_5M
    police 5000000 100000 exceed-action drop
# Apply 5M rate limiting to the port
interface GigabitEthernet0/2
service-policy input POLICY_5M
```

**_10M Template_**

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

**_15M Template_**

```
ip access-list extended ACL_15M
permit ip any any
class-map match-all CLASS_15M
  match access-group name ACL_15M
policy-map POLICY_15M
  class CLASS_15M
    police 15000000 100000 exceed-action drop
# Target interface
interface GigabitEthernet0/2
service-policy input POLICY_15M
```

#### [Cisco Switch] DHCP

The DHCP server is on SW1, and hosts in the 172.16.31.0 network obtain IPs via DHCP relay

```
SW1#configure t
Enter configuration commands, one per line. End with CNTL/Z.
# Configure interface IP addresses
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
# Configure RIP routes
SW1(config)#router rip
SW1(config-router)#version 2
SW1(config-router)#network 192.168.1.0
SW1(config-router)#network 10.10.10.0
SW1(config-router)#exit
SW1(config)#exit
# Configure the DHCP pool for 10.10.10.0
SW1(config)#ip dhcp excluded-address 10.10.10.101 10.10.10.200
SW1(config)#ip dhcp pool 10-net
SW1(dhcp-config)#network 10.10.10.0 255.255.255.0
SW1(dhcp-config)#default-router 10.10.10.254
SW1(dhcp-config)#lease infinite
SW1(dhcp-config)#dns-server 168.95.1.1
SW1(dhcp-config)#end
# Configure the DHCP pool for 172.16.31.0
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
# Configure interface IP addresses
SW2(config)#interface fa1/0
SW2(config-if)#no switchport
SW2(config-if)#ip address 192.168.1.2 255.255.255.252
SW2(config-if)#no shutdown
SW2(config-if)#exit
SW2(config)#interface fa1/1
SW2(config-if)#no switchport
SW2(config-if)#ip address 172.16.31.254 255.255.255.0
SW2(config-if)#ip helper-address 192.168.1.1 (set DHCP relay)
SW2(config-if)#no shutdown
SW2(config-if)#exit
# Configure RIP routes
SW2(config)#router rip
SW2(config-router)#version 2
SW2(config-router)#network 192.168.1.0
SW2(config-router)#network 172.16.31.0
