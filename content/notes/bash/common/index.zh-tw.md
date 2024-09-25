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

{{< note title="age" >}}

```bash
# generate public and private keys
age-keygen -o key.txt

# encrypt file with public key
age -r public_key -o file.txt.enc file.txt

# encrypt file with ssh key
age -R ~/.ssh/id_ed25519.pub file.txt > file.txt.enc

# decrypt file
age --decrypt -i key.txt file.txt.enc > file.txt
```

{{< /note >}}

{{< note title="awk" >}}

```bash
# To lowercase
uuidgen|awk '{print tolower($0)}' # output: 649612b0-0fa4-4b50-9b13-17279f602a43

# To uppercase
echo 'hello world'|awk '{print toupper($0)}' # output: HELLO WORLD

# 提取子字符串: `substr(string, start, length)`
echo "hello world" | awk '{print substr($0, 1, 5)}' # output: hello

# 全局替換字符串中的正則表達式匹配項: `gsub(regex, replacement, string)`
# 替換字符串中首次匹配的正則表達式: `sub(regex, replacement, string)`
echo "hello world" | awk '{gsub(/world/, "everyone"); print $0}' # output: hello everyone

# 將數字轉換為整數
echo "3.14" | awk '{print int($0)}' # output: 3

# 返回平方根
echo "99" | awk '{print sqrt($0)}' # output: 9.94987

# 指數和對數
echo "2" | awk '{print exp($0), log($0)}' # output: 7.38906 0.693147
```

{{< /note >}}

{{< note title="certbot" >}}

```bash
# Install
sudo apt install certbot python3-certbot-nginx python3-certbot-dns-route53

# 1. Generating Wildcard Certificates
sudo certbot certonly --manual --preferred-challenges=dns --server https://acme-v02.api.letsencrypt.org/directory --agree-tos -d *.example.com
### add txt record then press enter to continue

# 2. Generating Wildcard Certificates
sudo certbot certonly -d example.com -d *.example.com --dns-route53 --agree-tos --server https://acme-v02.api.letsencrypt.org/directory

# Automating Renewal
0 0 * * 1 /usr/bin/certbot certonly --dns-route53 -d *.example.com --quiet --post-hook "systemctl reload nginx"
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

{{< note title="Script Optimization" >}}

[Advanced Shell Scripting Techniques: Automating Complex Tasks with Bash](https://omid.dev/2024/06/19/advanced-shell-scripting-techniques-automating-complex-tasks-with-bash/)
1. Use Built-in Commands: Built-in commands execute faster because they don't require loading an external process.
2. Minimize Subshells: Subshells can be expensive in terms of performance.
```bash
# Inefficient
output=$(cat file.txt)

# Efficient
output=$(<file.txt)
```
3. Use Arrays for Bulk Data: When handling a large amount of data, arrays can be more efficient and easier to manage than multiple variables.
```bash
# Inefficient
item1="apple"
item2="banana"
item3="cherry"

# Efficient
items=("apple" "banana" "cherry")
for item in "${items[@]}"; do
    echo "$item"
done
```
4. Enable Noclobber: To prevent accidental overwriting of files.
```bash
set -o noclobber
```
5. Use Functions: Functions allow you to encapsulate and reuse code, making scripts cleaner and reducing redundancy.
6. Efficient File Operations: When performing file operations, use efficient techniques to minimize resource usage.
```bash
# Inefficient
while read -r line; do
    echo "$line"
done < file.txt

# Efficient
while IFS= read -r line; do
    echo "$line"
done < file.txt
```
7. Parallel Processing: Tools like `xargs` and GNU `parallel` can be incredibly useful.
8. Error Handling: Robust error handling is critical for creating reliable and maintainable scripts.
```bash
# Exit on Error: Using set -e ensures that your script exits immediately if any command fails, preventing cascading errors.
set -e

# Custom Error Messages: Implement custom error messages to provide more context when something goes wrong.
command1 || { echo "command1 failed"; exit 1; }

# Trap Signals: Use the `trap` command to catch and handle signals and errors gracefully.
trap 'echo "Error occurred"; cleanup; exit 1' ERR

function cleanup() {
    # Cleanup code
}

# Validate Inputs: Always validate user inputs and script arguments to prevent unexpected behavior.
if [[ -z "$1" ]]; then
    echo "Usage: $0 <argument>"
    exit 1
fi

# Logging: Implement logging to keep track of script execution and diagnose issues.
logfile="script.log"
exec > >(tee -i $logfile)
exec 2>&1

echo "Script started"
```
9. Automating Complex System Administration Tasks:
   1. Automated Backups
   2. System Monitoring
   3. User Management
   4. Automated Updates
   5. Network Configuration

{{< /note >}}