---
title: Network Related Command
weight: 100
menu:
  notes:
    name: network
    identifier: notes-network
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
