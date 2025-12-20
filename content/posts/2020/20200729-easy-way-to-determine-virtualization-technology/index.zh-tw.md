---
title: "确定虚拟化技术的简便方法"
date: 2020-07-29T21:11:45+08:00
menu:
  sidebar:
    name: "确定虚拟化技术的简便方法"
    identifier: linux-easy-way-to-determine-virtualization-technology
    weight: 10
tags: ["URL", "Virtualization", "Linux"]
categories: ["URL", "Virtualization", "Linux"]
hero: images/hero/linux.png
---

- [确定虚拟化技术的简便方法](https://qastack.cn/unix/89714/easy-way-to-determine-virtualization-technology)

### `dmidecode -s system-product-name`

虚拟化技术

#### VMware 工作站

```shell
root@router:~# dmidecode -s system-product-name
VMware Virtual Platform
```

#### 虚拟盒子

```shell
root@router:~# dmidecode -s system-product-name
VirtualBox
```

#### Qemu 与 KVM

```shell
root@router:~# dmidecode -s system-product-name
KVM
```

Qemu（模拟）

####

```shell
root@router:~# dmidecode -s system-product-name
Bochs
```

#### Microsoft 虚拟 PC

```shell
root@router:~# dmidecode | egrep -i 'manufacturer|product'
Manufacturer: Microsoft Corporation
Product Name: Virtual Machine
```

#### 维尔图佐

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

如果您没有 `dmidecode` 运行权， 则可以使用： `ls -1 /dev/disk/by-id/`

#### 虚拟化技术：QEMU

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
