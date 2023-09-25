---
title: "Cloudflare tunnel on Synology"
date: 2023-09-25T22:01:00+08:00
description: Create cloudflare tunnel on synology
menu:
  sidebar:
    name: Cloudflare Tunnel
    identifier: cloudflare-tunnel
    weight: 10
tags: ["Cloudflare", "tunnel", "Synology"]
categories: ["Cloudflare", "Synology"]
# hero: nginx.jpeg
---

## Setup Synology

1. Create a directory in docker directory, such as `cloudflare-tunnel`.
2. Download cloudflared/cloudflared image to registry.
3. ssh to admin@synology
4. Change `cloudflare-tunnel` owner, `sudo chown -R 65532:65532 /volume1/docker/cloudflare-tunnel`.

### Run containers

#### - `cloudflared tunnel login`

1. Run container and mount volume `docker/cloudflare-tunnel:/home/nonroot/.cloudflared`.
2. Select `Use the same network as Docker Host` in network tab.
3. Add command `tunnel login` in envorinment tab.
4. Go to container log, and copy login url.
5. Paste url to browser and authorize the zone.
6. Export the container setting json to the directory `cloudflare-tunnel`.

#### - `cloudflared tunnel create synology-tunnel`

1. Edit the container setting json in the the directory `cloudflare-tunnel`, modify cmd. `tunnel create synology-tunnel`.
2. Import the container setting json and run a new container.
3. The container will stop and create tunnel config json in `cloudflare-tunnel`.
4. Create config.yml and write ingress rules.
5. In config.yml, tunnel value is the same as the tunnel config json name, and credentials-file is `/home/nonroot/.cloudflared/tunnel config json`
6. Export the second container setting json to the directory `cloudflare-tunnel`.

#### - `cloudflared tunnel route dns synology-tunnel synology.ruru910.com`

1. Edit the second container setting json in the the directory `cloudflare-tunnel`, modify cmd. `tunnel route dns synology-tunnel synology.ruru910.com`.
2. Import the second container setting json and run a new container.
3. The container will stop and create a dns record mapping domain to the tunnel.

#### - `cloudflared tunnel run synology-tunnel`

1. Edit the second container setting json in the the directory `cloudflare-tunnel`, modify cmd. `tunnel run synology-tunnel`.
2. Import the second container setting json and run a new container.
3. The tunnel now is connectable.

## reference

- https://www.youtube.com/watch?v=5IrtNxfzH1o
