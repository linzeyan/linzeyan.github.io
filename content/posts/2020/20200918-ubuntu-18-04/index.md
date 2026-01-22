---
title: "Set interface IP with netplan on Ubuntu 18.04"
date: 2020-09-18T13:00:05+08:00
menu:
  sidebar:
    name: "Set interface IP with netplan on Ubuntu 18.04"
    identifier: linux-ubuntu-configure-interface-ip-by-netplan
    weight: 10
tags: ["Links", "Linux", "Ubuntu", "Network"]
categories: ["Links", "Linux", "Ubuntu", "Network"]
hero: images/hero/linux.png
---

- [Set interface IP with netplan on Ubuntu 18.04](https://blog.toright.com/posts/6293/ubuntu-18-04-%E9%80%8F%E9%81%8E-netplan-%E8%A8%AD%E5%AE%9A%E7%B6%B2%E8%B7%AF%E5%8D%A1-ip.html)

Following the notes above, check `/etc/netplan` and open `/etc/netplan/50-cloud-init.yaml`:

```yaml
# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
  ethernets:
    ens192:
      dhcp4: true
    ens224:
      dhcp4: true
  version: 2
```

It looks like you can disable cloud network, but I do not use cloud-init, so remove it:

> `sudo apt-get remove cloud-init`

Then change `/etc/netplan/50-cloud-init.yaml` to:

```yaml
# This file is generated from information provided by
# the datasource.  Changes to it will not persist across an instance.
# To disable cloud-init's network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
  ethernets:
    ens192:
      addresses: [192.168.32.231/24]
      gateway4: 192.168.32.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
      dhcp4: no
    ens224:
      dhcp4: true
  version: 2
```

YAML has become popular in recent years. Here is a quick explanation of the settings above:

- dhcp4: disable DHCP. It was true so set to no (the docs say no, not false, but false also works in testing).
- addresses: static IP and mask.
- nameservers: DNS servers, can set multiple.
- gateway4: IPv4 gateway.

After saving, run:

> `sudo netplan try`
