---
title: "Ubuntu 18.04 透過 netplan 設定網路卡 IP"
date: 2020-09-18T13:00:05+08:00
menu:
  sidebar:
    name: "Ubuntu 18.04 透過 netplan 設定網路卡 IP"
    identifier: linux-ubuntu-configure-interface-ip-by-netplan
    weight: 10
tags: ["URL", "Linux", "Ubuntu", "Network"]
categories: ["URL", "Linux", "Ubuntu", "Network"]
hero: images/hero/linux.png
---

- [Ubuntu 18.04 透過 netplan 設定網路卡 IP](https://blog.toright.com/posts/6293/ubuntu-18-04-%E9%80%8F%E9%81%8E-netplan-%E8%A8%AD%E5%AE%9A%E7%B6%B2%E8%B7%AF%E5%8D%A1-ip.html)

照上面的說明看了一下 /etc/netplan 目錄，查閱一下 /etc/netplan/50-cloud-init.yaml，如下：

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

看來可以關閉 cloud network，但是我其實也沒有要用 cloud-init，乾脆移除它，如下：

> `sudo apt-get remove cloud-init`

然後把 /etc/netplan/50-cloud-init.yaml 改成下面這樣：

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

這幾年 yaml 深得大眾的心，設定檔就是要用 yaml 格式才是潮，解說一下上述幾個設定：

- dhcp4: 關閉 DHCP 自動取得 IP，原本是 true 所以改成 no (官方文件竟然不是 false 有點搞笑，但我實際測試 false 也是可以 work 的)
- addresses: 靜態 IP 與 Mask
- nameservers: DNS 服務器，可以設定多筆
- gateway4: IPv4 所使用的 Gateway

修改後存檔後輸入以下命令：

> `sudo netplan try`
