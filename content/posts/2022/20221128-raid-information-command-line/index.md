---
title: "How to Detect RAID Information in Linux"
date: 2022-11-28T15:36:27+08:00
menu:
  sidebar:
    name: "How to Detect RAID Information in Linux"
    identifier: linux-raid-information-command-line
    weight: 10
tags: ["URL", "Linux", "RAID", "command line"]
categories: ["URL", "Linux", "RAID", "command line"]
hero: images/hero/linux.png
---

- [How to Detect RAID Information in Linux](https://www.baeldung.com/linux/raid-information-command-line)

##### lspci

```bash
lspci | grep RAID
00:1f.2 RAID bus controller: Intel Corporation 82801 Mobile SATA Controller [RAID mode] (rev 04)
```

##### lshw

```bash
lshw -class storage
  *-raid
       description: RAID bus controller
       product: 82801 Mobile SATA Controller [RAID mode]
       vendor: Intel Corporation
       physical id: 1f.2
       bus info: pci@0000:00:1f.2
       logical name: scsi0
       version: 04
       width: 32 bits
       clock: 66MHz
       capabilities: raid msi pm bus_master cap_list emulated
       configuration: driver=ahci latency=0
       resources: irq:26 ioport:f0d0(size=8) ioport:f0c0(size=4) ioport:f0b0(size=8) ioport:f0a0(size=4) ioport:f060(size=32) memory:f7e36000-f7e367ff
```

##### smartctl

```bash
dmesg | grep -i scsi
[    0.210852] SCSI subsystem initialized
[    0.341280] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 243)
...
[    1.213299] scsi 0:0:0:0: Direct-Access     ATA      ST320LT012-9WS14 YAM1 PQ: 0 ANSI: 5
[    1.319886] sd 0:0:0:0: [sda] Attached SCSI disk
[   19.571008] sd 0:0:0:0: Attached scsi generic sg0 type 0
```

```bash
smartctl --all /dev/sda
Model Family:     Seagate Laptop HDD
Device Model:     ST320LT012-9WS14C
Serial Number:    S0V3R9LL
LU WWN Device Id: 5 000c50 05be4653c
Firmware Version: 0001YAM1
User Capacity:    320,072,933,376 bytes [320 GB]
Sector Sizes:     512 bytes logical, 4096 bytes physical
Rotation Rate:    5400 rpm
Form Factor:      2.5 inches
Device is:        In smartctl database 7.3/5319
ATA Version is:   ATA8-ACS T13/1699-D revision 4
SATA Version is:  SATA 2.6, 3.0 Gb/s (current: 3.0 Gb/s)
Local Time is:    Sat Nov 19 20:52:01 2022 PKT
SMART support is: Available - device has SMART capability.
SMART support is: Enabled
...
```

##### MegaCLI

```bash
megacli -LDInfo -Lall -aALL
Adapter 0 -- Virtual Drive Information:
Virtual Drive: 0 (Target Id: 0)
Name                : SEAGATE
RAID Level          : Primary-1, Secondary-0, RAID Level Qualifier-0
Size                : 320 GB
Sector Size         : 512
Mirror Data         : 320 GB
State               : Optimal
...
```

##### lsscsi

```bash
lsscsi
[0:0:0:0]    disk    ATA      ST320LT012-9WS14 YAM1  /dev/sda
```

##### Vendor-Specific Tools

```bash
omreport storage vdisk
List of Virtual Disks in the System

Controller SEAGATE Laptop HDD
ID                                : 0
Status                            : Ok
Name                              : SEAGATE
State                             : Ready
Hot Spare Policy violated         : Not Assigned
Encrypted                         : No
Layout                            : RAID-0
Size                              : 320.00 GB (343597383680 bytes)
T10 Protection Information Status : No
Associated Fluid Cache State      : Not Applicable
Device Name                       : /dev/sda
Bus Protocol                      : ATA
Media                             : HDD
Read Policy                       : Adaptive Read Ahead
Write Policy                      : Write Back
Cache Policy                      : Not Applicable
Stripe Element Size               : 128 KB
Disk Cache Policy                 : Enabled
```
