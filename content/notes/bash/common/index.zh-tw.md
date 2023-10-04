---
title: Common Command
weight: 100
menu:
  notes:
    name: common
    identifier: notes-bash-common
    parent: notes-bash
    weight: 10
---

{{< note title="ab" >}}

```bash
ab -n 20 -c 20 -k https://default.hddv1.com/error
```

{{< /note >}}

{{< note title="certbot" >}}

```bash
# Install
sudo apt install certbot python3-certbot-nginx

# Generating Wildcard Certificates
sudo certbot certonly --manual --preferred-challenges=dns --server https://acme-v02.api.letsencrypt.org/directory --agree-tos -d *.example.com
### add txt record then press enter to continue

# Automating Renewal
0 0 * * 1 /usr/bin/certbot renew --quiet --post-hook "systemctl reload nginx"
```

{{< /note >}}

{{< note title="cutycapt" >}}

```bash
# Capture website page as picture
xvfb-run --server-args="-screen 0, 1024x768x24" cutycapt --url=https://www.google.com --out="/tmp/google.png"
```

{{< /note >}}

{{< note title="dnscontrol" >}}

- [creds.json](/notes/bash/common/files/creds.json)
- command

```bash
dnscontrol get-zones --format=js --out=example.com.js r53 ROUTE53 example.com
dnscontrol get-zones --format=js --out=example.com.js cloudflare CLOUDFLAREAPI example.com
```

{{< /note >}}

{{< note title="k6" >}}

- [k6.js](/notes/bash/common/files/k6.js)
- command

```bash
k6 run k6.js
```

{{< /note >}}

{{< note title="hey" >}}

```bash
hey -n 200000 -c 500 -h2 -z 30s https://a8-wss.hddv1.com/test
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

{{< note title="siege" >}}

```bash
siege --time=3s --concurrent=30000 https://a8-h5.hddv1.com/index.html
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

{{< note title="vegeta" >}}

```bash
#!/usr/bin/env bash

attack() {
    echo "GET ${1}" |
        vegeta attack -duration=100s -header="User-Agent: baidu" -header="X-Forwarded-For: 47.0.0.1" -rate=500 -timeout=1s |
        vegeta encode |
        jaggr @count=rps \
            hist\[100,200,300,400,500\]:code \
            p25,p50,p95:latency \
            sum:bytes_in \
            sum:bytes_out |
        jplot rps+code.hist.100+code.hist.200+code.hist.300+code.hist.400+code.hist.500 \
            latency.p95+latency.p50+latency.p25 \
            bytes_in.sum+bytes_out.sum
}

if [[ -n ${1} ]]; then
    attack ${1}
fi

## -header="Connection: Upgrade" -header="Upgrade: websocket"
```

{{< /note >}}

{{< note title="wrk" >}}

```bash
wrk -t10 -c1000 -d30s -H "User-Agent: baidu" "https://default.hddv1.com/error"
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

###### - autocorrect

> A linter and formatter for help you improve copywriting, to correct spaces, words, punctuations between CJK (Chinese, Japanese, Korean). [Github](https://github.com/huacnlee/autocorrect)

```bash
wget https://github.com/huacnlee/autocorrect/releases/download/v1.7.4/autocorrect-darwin-amd64.tar.gz
```

###### - bpf

> BCC - Tools for BPF-based Linux IO analysis, networking, monitoring, and more
> Kernel should higher than 4.1
> Install from source is better

```bash
# `/usr/share/bcc/`
# https://github.com/iovisor/bcc
# https://github.com/iovisor/bcc/blob/master/docs/reference_guide.md#1-kernel-source-directory
# https://github.com/iovisor/bpftrace
yum install bcc-tools
```

###### - flamegraph

> Stack trace visualizer

```bash
# https://github.com/brendangregg/FlameGraph
brew install flamegraph
```

###### - git-split-diffs

> GitHub style split diffs in your terminal

```bash
npm install -g git-split-diffs
```

###### - glci

> Test your Gitlab CI Pipelines changes locally using Docker. [blog](https://blog.chengweichen.com/2021/03/glci-gitlab-local-ci.html)

```bash
yarn global add glci
```

###### - openresty

```bash
wget https://openresty.org/package/centos/openresty.repo -O /etc/yum.repos.d/openresty.repo
yum install -y openresty openresty-resty
```

###### - perf

> Performance monitoring for the Linux kernel

```bash
# https://github.com/brendangregg/Misc/blob/master/perf_events/perf.md
# http://www.brendangregg.com/perf.html
yum install perf
```

###### - pptx2md

> A pptx to markdown converter

```bash
pip3 install pptx2md
```

###### - sockperf

> Network Benchmarking Utility

```bash
# https://github.com/Mellanox/sockperf
yum install sockperf
```

###### - upx

> UPX - the Ultimate Packer for eXecutables

```bash
brew install upx
```

###### - wrk

> Modern HTTP benchmarking tool

```bash
brew install wrk
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

{{< note title="Script" >}}

{{< gist m-radzikowski 53e0b39e9a59a1518990e76c2bff8038 >}}

{{< /note >}}
