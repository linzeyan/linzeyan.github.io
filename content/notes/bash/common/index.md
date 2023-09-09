---
title: Common Command
weight: 100
menu:
  notes:
    name: common
    identifier: notes-common
    parent: notes-bash
    weight: 10
---

{{< note title="cutycapt" >}}

```bash
# Capture website page as picture
xvfb-run --server-args="-screen 0, 1024x768x24" cutycapt --url=https://www.google.com --out="/tmp/google.png"
```

{{< /note >}}

{{< note title="openfortivpn" >}}

```bash
# https://github.com/adrienverge/openfortivpn
sudo openfortivpn ip:port --username=ricky --pppd-use-peerdns=1
```

{{< /note >}}

{{< note title="tr" >}}

```bash
# cat krypton2
YRIRY GJB CNFFJBEQ EBGGRA
# cat krypton2 | tr a-zA-Z n-za-mN-ZA-M
LEVEL TWO PASSWORD ROTTEN
```

{{< /note >}}

{{< note title="Common" >}}

```bash
# Find out processes swap usage command
for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; done | sort -k 2 -n -r | less
```

{{< /note >}}

{{< note title="Install" >}}

```bash
# openresty
wget https://openresty.org/package/centos/openresty.repo -O /etc/yum.repos.d/openresty.repo
yum install -y openresty openresty-resty
```

{{< /note >}}
