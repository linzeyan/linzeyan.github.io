---
title: "An easy way to identify virtualization technology"
date: 2020-07-29T21:11:45+08:00
menu:
  sidebar:
    name: "An easy way to identify virtualization technology"
    identifier: linux-easy-way-to-determine-virtualization-technology
    weight: 10
tags: ["Links", "Virtualization", "Linux"]
categories: ["Links", "Virtualization", "Linux"]
hero: images/hero/linux.png
---

- [An easy way to identify virtualization technology](https://qastack.cn/unix/89714/easy-way-to-determine-virtualization-technology)

### `dmidecode -s system-product-name`

Virtualization technology

#### VMware Workstation

```shell
root@router:~# dmidecode -s system-product-name
VMware Virtual Platform
```

#### VirtualBox

```shell
root@router:~# dmidecode -s system-product-name
VirtualBox
```

#### QEMU and KVM

```shell
root@router:~# dmidecode -s system-product-name
KVM
```

QEMU (emulation)

####

```shell
root@router:~# dmidecode -s system-product-name
Bochs
```

#### Microsoft Virtual PC

```shell
root@router:~# dmidecode | egrep -i 'manufacturer|product'
Manufacturer: Microsoft Corporation
Product Name: Virtual Machine
```

#### Virtuozzo

```shell
root@router:~# dmidecode
/dev/mem: Permission denied
```

#### en

```shell
root@router:~# dmidecode | grep -i domU
Product Name: HVM domU
```

### `/dev/disk/by-id`

If you do not have permission to run `dmidecode`, you can use: `ls -1 /dev/disk/by-id/`

#### Virtualization technology: QEMU

```shell
[root@host-7-129 ~]# ls -1 /dev/disk/by-id/
ata-QEMU_DVD-ROM_QM00003
ata-QEMU_HARDDISK_QM00001
ata-QEMU_HARDDISK_QM00001-part1
ata-QEMU_HARDDISK_QM00002
ata-QEMU_HARDDISK_QM00002-part1
scsi-SATA_QEMU_HARDDISK_QM00001
scsi-SATA_QEMU_HARDDISK_QM00001-part1
scsi-SATA_QEMU_HARDDISK_QM00002
scsi-SATA_QEMU_HARDDISK_QM00002-part1
```
