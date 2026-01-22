---
title: "Mosdns-X"
date: 2025-11-09T20:32:00+08:00
menu:
  sidebar:
    name: "Mosdns-X"
    identifier: Mosdns-X
    weight: 10
tags: ["Links", "Go", "DNS", "linux"]
categories: ["Links", "Go", "DNS", "linux"]
hero: images/hero/go.svg
---

- [Mosdns-X](https://github.com/pmkol/mosdns-x)
- [Make DNS faster and cleaner on Linux: Deploy Mosdns-X](https://blog.ibytebox.com/archives/OxpX7FQ1)

### install

```bash
bash <(curl -sL https://raw.githubusercontent.com/lidebyte/bashshell/refs/heads/main/mosdns-x-manager.sh)
```

### config

```bash
sudo tee /etc/mosdns-x/config.yaml > /dev/null <<'EOF'
# mosdns-x concurrent query (no split routing) config

log:
  level: info
  file: /var/log/mosdns-x/mosdns-x.log

plugins:
  # Cache plugin
  - tag: cache
    type: cache
    args:
      size: 1024
      lazy_cache_ttl: 1800

  # Concurrent upstreams: take the first usable answer
  - tag: forward_all
    type: fast_forward
    args:
      upstream:
        # AliDNS
        - addr: "udp://223.5.5.5"
        - addr: "tls://dns.alidns.com"

        # DNSPod / doh.pub
        - addr: "udp://119.29.29.29"
        - addr: "tls://dot.pub"

        # Cloudflare
        - addr: "udp://1.1.1.1"
        - addr: "tls://cloudflare-dns.com"

        # Google
        - addr: "udp://8.8.8.8"
        - addr: "tls://dns.google"

  # Main pipeline: small cache -> concurrent selection
  - tag: main
    type: sequence
    args:
      exec:
        - cache
        - forward_all

# Listen on dual-stack UDP/TCP 53
servers:
  - exec: main
    listeners:
      - addr: :53
        protocol: udp
      - addr: :53
        protocol: tcp
EOF
```

### systemd

```bash
sudo tee /etc/systemd/system/mosdns.service > /dev/null <<'EOF'
[Unit]
Description=Mosdns-X DNS Accelerator
After=network.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/mosdns-x start --as-service -d /usr/local/bin -c /etc/mosdns-x/config.yaml
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=mosdns

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now mosdns

# Backup system DNS
sudo cp -n /etc/resolv.conf /etc/resolv.conf.mosdns-backup

# Switch to local Mosdns-X
echo -e "nameserver 127.0.0.1\noptions edns0" | sudo tee /etc/resolv.conf

# If port 53 is occupied by systemd-resolved, disable it
sudo systemctl disable --now systemd-resolved 2>/dev/null || true

# If you also want to lock it (prevent DHCP changes), run chattr too:
echo -e "nameserver 127.0.0.1\n" > /etc/resolv.conf && chattr +i /etc/resolv.conf

# Check process status
sudo systemctl status mosdns --no-pager

# Test resolution speed (second run should hit cache)
dig +stats www.google.com
dig +stats www.baidu.com

# View logs in real time
tail -f /var/log/mosdns-x/mosdns-x.log
```
