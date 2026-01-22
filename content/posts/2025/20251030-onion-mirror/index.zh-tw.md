---
title: "onion-mirror"
date: 2025-10-30T17:49:44+08:00
menu:
  sidebar:
    name: "onion-mirror"
    identifier: tor-onion-mirror
    weight: 10
tags: ["Links", "Tor"]
categories: ["Links", "Tor"]
---

- [onion-mirror](https://flower.codes/2025/10/23/onion-mirror.html)

### 安裝 Tor

```bash
sudo apt update
sudo apt install tor
```

### 設定 Tor

```
# Disable SOCKS proxy since we aren't making outbound connections
# through Tor
SocksPort 0

# Make sure Tor runs as a daemon (i.e. in the background)
RunAsDaemon 1

# Setup the hidden service on port 80, this is where we tell Tor to
# create a .onion service for our web server
HiddenServiceDir /var/lib/tor/hidden_service/
HiddenServicePort 80

# Disable inbound connections, since we aren't running a relay or
# exit node
ORPort 0

# Disable directory services, since we won't be mirroring directory
# information to other Tor nodes
DirPort 0
```

```bash
sudo systemctl restart tor
```

### 取得你的 .onion 位址

```bash
sudo cat /var/lib/tor/hidden_service/hostname
```

### 設定 Caddy

```
http://jytkco7clxwj4hhzaydhk4kr3hwzsdzyvtsc6zn2ivog5uma5pxowzad.onion:80 {
  # Set up a reverse proxy, or serve static files, etc.
}
```

### 公告你的 .onion 位址

```
header {
  Onion-Location http://jytkco7clxwj4hhzaydhk4kr3hwzsdzyvtsc6zn2ivog5uma5pxowzad.onion{uri}
}
```
