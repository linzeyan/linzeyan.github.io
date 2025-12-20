---
title: "LVM - lvg and lvol"
date: 2022-09-05T15:32:05+08:00
menu:
  sidebar:
    name: "LVM - lvg and lvol"
    identifier: ansible-system-lvm
    weight: 10
tags: ["URL", "Ansible", "LVM"]
categories: ["URL", "Ansible", "LVM"]
hero: images/hero/ansible.png
---

- [LVM - lvg and lvol](https://ansible.cloudns.pro/post/system/lvm/)

##### volume group

```yaml
- name: 在 /dev/sda1 跟 /dev/sdb1 之上建立 volume group，其 extend size 設置為 32MB
  community.general.lvg:
    vg: vg.services
    pvs: /dev/sda1,/dev/sdb1
    pesize: 32
```

##### local volume

```yaml
- name: 建立一個大小為 512m 的 local volume
  community.general.lvol:
    vg: firefly
    lv: test
    size: 512
```

##### Example

```yaml
---
- name: Create LVM for DRBD
  hosts: all
  become: yes

  vars:
    vg_name: drbdpool

  tasks:
    - name: Create a new primary partition for LVM
      community.general.parted:
        device: /dev/sdb
        number: 1
        align: optimal
        flags: [lvm]
        state: present

    - name: Create a volume group on top of /dev/sda1 with physical extent size = 32MB
      community.general.lvg:
        vg: "{{ vg_name }}"
        pvs: /dev/sdb1
        state: present

    - name: Create a logical volume
      community.general.lvol:
        vg: "{{ vg_name }}"
        lv: drbddata
        size: 100%FREE
```
