---
title: "Mosdns-X"
date: 2025-11-09T20:32:00+08:00
menu:
  sidebar:
    name: "Mosdns-X"
    identifier: Mosdns-X
    weight: 10
tags: ["URL", "Go", "DNS", "linux"]
categories: ["URL", "Go", "DNS", "linux"]
hero: images/hero/go.svg
---

- [Mosdns-X](https://github.com/pmkol/mosdns-x)
- [让 Linux 系统的 DNS 更快更干净：部署 Mosdns-X](https://blog.ibytebox.com/archives/OxpX7FQ1)

### install

```bash
bash <(curl -sL https://raw.githubusercontent.com/lidebyte/bashshell/refs/heads/main/mosdns-x-manager.sh)
```

### config

```bash
sudo tee /etc/mosdns-x/config.yaml > /dev/null <<'EOF'
# mosdns-x 并发查询（无分流）配置

log:
  level: info
  file: /var/log/mosdns-x/mosdns-x.log

plugins:
  # 缓存插件
  - tag: cache
    type: cache
    args:
      size: 1024
      lazy_cache_ttl: 1800

  # 并发上游：取最先返回的可用答案
  - tag: forward_all
    type: fast_forward
    args:
      upstream:
        # 阿里
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

  # 主流水线：小缓存 → 并发优选
  - tag: main
    type: sequence
    args:
      exec:
        - cache
        - forward_all

# 监听（双栈 UDP/TCP 53）
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

# 备份系统 DNS
sudo cp -n /etc/resolv.conf /etc/resolv.conf.mosdns-backup

# 改为使用本地 Mosdns-X
echo -e "nameserver 127.0.0.1\noptions edns0" | sudo tee /etc/resolv.conf

# 若 53 端口被 systemd-resolved 占用，可禁用它
sudo systemctl disable --now systemd-resolved 2>/dev/null || true

# 如果想顺便加锁（防止被 DHCP 修改），加上 chattr 一起执行：
echo -e "nameserver 127.0.0.1\n" > /etc/resolv.conf && chattr +i /etc/resolv.conf

# 查看进程状态
sudo systemctl status mosdns --no-pager

# 测试解析速度（第二次命中缓存更快）
dig +stats www.google.com
dig +stats www.baidu.com

# 查看实时日志
tail -f /var/log/mosdns-x/mosdns-x.log
```
