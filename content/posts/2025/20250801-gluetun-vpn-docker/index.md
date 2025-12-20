---
title: "Gluetun：讓Docker容器走VPN連線，沒網路就斷線，使用教學"
date: 2025-08-01T15:51:00+08:00
menu:
  sidebar:
    name: "Gluetun：讓Docker容器走VPN連線，沒網路就斷線，使用教學"
    identifier: docker-gluetun-vpn
    weight: 10
tags: ["URL", "Docker", "Gluetun", "VPN"]
categories: ["URL", "Docker", "Gluetun", "VPN"]
hero: images/hero/docker.jpeg
---

- [Gluetun：讓 Docker 容器走 VPN 連線，沒網路就斷線，使用教學](https://ivonblog.com/posts/gluetun-vpn-docker/)

## Gluetun

- OpenVPN

```yaml
services:
  gluetun:
    image: qmcgaw/gluetun
    container_name: gluetun
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    ports:
      - 8888:8888/tcp # HTTP proxy
      - 8388:8388/tcp # Shadowsocks
      - 8388:8388/udp # Shadowsocks
    volumes:
      - /home/user/gluetun:/gluetun
    environment: # 按照VPN供應商的OpenVPN設定檔填寫
      - VPN_SERVICE_PROVIDER=protonvpn
      - VPN_TYPE=openvpn
      - OPENVPN_USER= # OpenVPN帳號
      - OPENVPN_PASSWORD= # OpenVPN密碼
      - SERVER_COUNTRIES=United Kingdom # 指定伺服器所在國家，以逗號分隔
     networks: # (選擇性) 固定Gluetun容器的IP
       network:
        ipv4_address: 172.27.0.5

networks: # (選擇性) 固定Gluetun容器的IP
  network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.27.0.0/16
          gateway: 172.27.0.5
```

- WireGuard

```yaml
services:
  gluetun:
    image: qmcgaw/gluetun
    container_name: gluetun
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    ports:
      - 8888:8888/tcp # HTTP proxy
      - 8388:8388/tcp # Shadowsocks
      - 8388:8388/udp # Shadowsocks
    volumes:
      - /home/user/gluetun:/gluetun
    environment:
      - VPN_SERVICE_PROVIDER=protonvpn # 按照VPN供應商的WireGuard設定檔填寫
      - VPN_TYPE=wireguard
      - WIREGUARD_PRESHARED_KEY= # 預共享密鑰
      - WIREGUARD_PRIVATE_KEY= # 私鑰
      - WIREGUARD_ADDRESSES= # 填IPV4與IPV6位址，以逗號分隔
      - SERVER_COUNTRIES=United Kingdom # 指定伺服器所在國家，以逗號分隔
     networks: # (選擇性) 固定Gluetun容器的IP
       network:
        ipv4_address: 172.27.0.5

networks: # (選擇性) 固定Gluetun容器的IP
  network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.27.0.0/16
          gateway: 172.27.0.5
```

## 讓容器走 Gluetun 的 VPN 連線

- 如果容器服務跟 Gluetun 寫在同一個 docker-compose：加入網路模式 network_mode: "service:gluetun"
- 如果該容器跟 Gluetun 不是寫在同一個 docker-compose：加入 network_mode: "container:gluetun"
- 開啟 Gluetun 的 docker-compose 檔案，把 service 用到的通訊埠(ex:8080)加回來
- 依序啟動 Gluetun 和 走 Gluetun 的 VPN 連線的服務
- 容器公共 IP 應當跟您選擇的 VPN 伺服器一致
