---
title: Network Related Command
weight: 100
menu:
  notes:
    name: network
    identifier: notes-bash-network
    parent: notes-bash
    weight: 10
---

{{< note title="Check port status" >}}

```bash
# `(echo >/dev/tcp/${host}/${port})`
(echo >/dev/tcp/192.168.57.24/80) &>/dev/null && echo "open" || echo "closed"

timeout 1 bash -c '>/dev/tcp/192.168.57.24/80 &>/dev/null' && echo "open" || echo "closed"

timeout 1 bash -c '>/dev/tcp/192.168.57.24/80' && echo "open" || echo "closed"
```

{{< /note >}}

{{< note title="Block subnets" >}}

```bash
ip route add blackhole 192.168.0.0/24
```

{{< /note >}}

{{< note title="Kill sessions" >}}

```bash
# ss
sudo ss -K state TIME-WAIT
# or conntrack
sudo conntrack -D -p tcp --state TIME_WAIT
```

{{< /note >}}

{{< note title="connect IPs" >}}

```bash
ss -tnH state established \
| awk '{
  peer = $5; if (peer == "") peer = $NF # 取 Peer Address:Port（某些版本欄位可能不同）
  sub(/,$/, "", peer)                   # 去掉可能的逗號
  gsub(/[\[\]]/, "", peer)              # 去掉所有中括號
  gsub(/::ffff:/, "", peer)             # IPv4-mapped IPv6 無論出現在開頭還中間都移除
  sub(/%[^:]+/, "", peer)               # 去掉 IPv6 的 scope（如 %eth0）
  sub(/:[0-9]+$/, "", peer)             # 去掉最後的 :port
  print peer
}' \
| sort | uniq -c | sort -nr

```

{{< /note >}}