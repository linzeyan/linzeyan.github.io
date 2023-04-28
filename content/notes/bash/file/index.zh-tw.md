---
title: File Related Command
weight: 100
menu:
  notes:
    name: file
    identifier: notes-file
    parent: notes-bash
    weight: 10
---

{{< note title="File create time" >}}

#### 1. Find Inode
```shell
$ stat dns.yaml
  File: dns.yaml
  Size: 1003        Blocks: 8          IO Block: 4096   regular file
Device: ca01h/51713d    Inode: 3595636     Links: 1
Access: (0644/-rw-r--r--)  Uid: ( 1000/  ubuntu)   Gid: ( 1000/  ubuntu)
Access: 2022-05-03 12:59:59.996755279 +0800
Modify: 2021-12-10 18:27:54.157585209 +0800
Change: 2022-01-07 14:57:58.619727878 +0800
 Birth: -
```
or
```shell
$ ls -i dns.yaml
3585173 dns.yaml
```

#### 2. Find Filesystem
```shell
$ df dns.yaml
Filesystem     1K-blocks     Used Available Use% Mounted on
/dev/root      101583780 25703988  75863408  26% /
```

#### 3. Get Create Time
```shell
$ sudo debugfs -R 'stat <3595636>' /dev/root
Inode: 3595636   Type: regular    Mode:  0644   Flags: 0x80000
Generation: 449657737    Version: 0x00000000:00000001
User:  1000   Group:  1000   Project:     0   Size: 1003
File ACL: 0
Links: 1   Blockcount: 8
Fragment:  Address: 0    Number: 0    Size: 0
 ctime: 0x61d7e476:93c13018 -- Fri Jan  7 14:57:58 2022
 atime: 0x6270b6cf:eda51d3c -- Tue May  3 12:59:59 2022
 mtime: 0x61b32baa:25923ce4 -- Fri Dec 10 18:27:54 2021
crtime: 0x61b32baa:25923ce4 -- Fri Dec 10 18:27:54 2021
Size of extra inode fields: 32
Inode checksum: 0x5b176bb2
EXTENTS:
(0):2665902
```

{{< /note >}}


{{< note title="Display Ubuntu's Message of the Day" >}}
```bash
sudo chmod +x /etc/update-motd.d/*
```
{{< /note >}}