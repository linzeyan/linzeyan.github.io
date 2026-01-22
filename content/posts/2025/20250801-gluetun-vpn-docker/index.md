---
title: "Gluetun: Route Docker Containers Through a VPN, Disconnect on No Network"
date: 2025-08-01T15:51:00+08:00
menu:
  sidebar:
    name: "Gluetun: Route Docker Containers Through a VPN, Disconnect on No Network"
    identifier: docker-gluetun-vpn
    weight: 10
tags: ["Links", "Docker", "Gluetun", "VPN"]
categories: ["Links", "Docker", "Gluetun", "VPN"]
hero: images/hero/docker.jpeg
---

- [Gluetun: Route Docker Containers Through a VPN, Disconnect on No Network](https://ivonblog.com/posts/gluetun-vpn-docker/)

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
    environment: # Fill in based on your VPN provider's OpenVPN config
      - VPN_SERVICE_PROVIDER=protonvpn
      - VPN_TYPE=openvpn
      - OPENVPN_USER= # OpenVPN username
      - OPENVPN_PASSWORD= # OpenVPN password
      - SERVER_COUNTRIES=United Kingdom # Set server country, separated by commas
     networks: # (Optional) fixed IP for the Gluetun container
       network:
        ipv4_address: 172.27.0.5

networks: # (Optional) fixed IP for the Gluetun container
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
      - VPN_SERVICE_PROVIDER=protonvpn # Fill in based on your VPN provider's WireGuard config
      - VPN_TYPE=wireguard
      - WIREGUARD_PRESHARED_KEY= # Preshared key
      - WIREGUARD_PRIVATE_KEY= # Private key
      - WIREGUARD_ADDRESSES= # Set IPv4 and IPv6 addresses, separated by commas
      - SERVER_COUNTRIES=United Kingdom # Set server country, separated by commas
     networks: # (Optional) fixed IP for the Gluetun container
       network:
        ipv4_address: 172.27.0.5

networks: # (Optional) fixed IP for the Gluetun container
  network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.27.0.0/16
          gateway: 172.27.0.5
```

## Let containers use Gluetun's VPN connection

- If the service and Gluetun are in the same docker-compose, add network mode: network_mode: "service:gluetun"
- If the service is in a different docker-compose from Gluetun, add network_mode: "container:gluetun"
- Open Gluetun's docker-compose file and re-add the service ports you need (e.g. 8080)
- Start Gluetun first, then start services that should use Gluetun's VPN connection
- The container's public IP should match the VPN server you selected
