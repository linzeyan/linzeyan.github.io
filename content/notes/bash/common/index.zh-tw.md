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

{{< note title="openssl" >}}

```bash
# 自簽名證書，要把 ca.p7b 匯入 certmgr.msc 的受信任的根憑證授權單位，Chrome 才吃的到。
openssl crl2pkcs7 -nocrl -certfile ca.crt -out ca.p7b
```

{{< /note >}}

{{< note title="prlimit" >}}

```bash
# 更改 Max_open_files 遇到參數錯誤，原因為 CentOS6 與 CentOS7 指令不同
# CentOS6
for i in $(ps -ef | grep 'publish/server/game_server' | egrep -v 'grep|startall' | awk '{print $2}'); do echo -n "Max open files=1024000:1024000" > /proc/$i/limits; done

# CentOS7
for i in $(ps -ef | grep gateway | grep -v grep | awk '{print $2}'); do prlimit --pid $i --nofile=1024000:1024000 ; done
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

{{< note title="Vagrant with hyper-v provider" >}}

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

{{< /note >}}

{{< note title="Common" >}}

```bash
# Find out processes swap usage command
for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; done | sort -k 2 -n -r | less
```

{{< /note >}}

{{< note title="Gitbook" >}}

Hide gitbook sidebar default.

```bash
raw_path=$(pwd)
npm install -g gitbook-cli
gitbook install
cd ~/.gitbook/versions/3.2.3/node_modules/gitbook-plugin-theme-default
sed -i "25i\ \ \ \ gitbook.storage.set('sidebar', false);" src/js/theme/sidebar.js
npm install -g browserify uglify-js less less-plugin-clean-css
npm install
src/build.sh
```

{{< /note >}}

{{< note title="Install" >}}

```bash
# openresty
wget https://openresty.org/package/centos/openresty.repo -O /etc/yum.repos.d/openresty.repo
yum install -y openresty openresty-resty
```

{{< /note >}}

{{< note title="LVM" >}}

```bash
# 確認 resize 在哪個 disk
lsblk

# 確認 `/dev/sde` 是否為該新增 disk 路徑
pvresize /dev/sde

# vgdisplay [vg 編號]
# 查 free  PE / Size 的編號
vgdisplay vg3

# 要升級的 lvm 硬碟路徑
lvdisplay

# lvresize -l +[free 的編號] 升級的 lvm 硬碟路徑
lvresize -l +38400 /dev/vg3/disklvm4

# resize
xfs_growfs /dev/vg3/disklvm4

# 檢查擴充是否成功
df -h
```

{{< /note >}}

{{< note title="Migration zabbix" >}}

```bash
mysqldump -uroot --opt zabbix > zabbix.sql
rsync -az zabbix.sql newserver:/root
mysql -uroot zabbix < zabbix.sql
```

{{< /note >}}

{{< note title="Re-create /dev/null" >}}

```bash
rm -f /dev/null
mknod /dev/null c 1 3
```

{{< /note >}}
