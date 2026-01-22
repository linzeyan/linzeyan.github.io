---
title: "在 Synology 上建立 Cloudflare Tunnel"
date: 2023-09-25T22:01:00+08:00
description: 在 Synology 上建立 Cloudflare Tunnel
menu:
  sidebar:
    name: Cloudflare Tunnel
    identifier: cloudflare-tunnel
    weight: 10
tags: ["Links", "Cloudflare", "tunnel", "Synology"]
categories: ["Links", "Cloudflare", "Synology"]
hero: images/hero/cloudflare.svg
---

- [CLOUDFLARE tunnel on SYNOLOGY. (the raw way)](https://www.youtube.com/watch?v=5IrtNxfzH1o)

{{< youtube 5IrtNxfzH1o >}}

{{< vs >}}

## Setup Synology

1. 在 docker 目錄下建立資料夾，例如 `cloudflare-tunnel`。
2. 下載 cloudflared/cloudflared 映像到 registry。
3. SSH 到 admin@synology。
4. 變更 `cloudflare-tunnel` 擁有者，`sudo chown -R 65532:65532 /volume1/docker/cloudflare-tunnel`。

### Run containers

#### - `cloudflared tunnel login`

1. 執行容器並掛載 volume `docker/cloudflare-tunnel:/home/nonroot/.cloudflared`。
2. 在 network 分頁選擇 `Use the same network as Docker Host`。
3. 在 environment 分頁加入指令 `tunnel login`。
4. 到容器 log 複製登入 URL。
5. 貼上 URL 到瀏覽器並授權 zone。
6. 將容器設定 json 匯出到 `cloudflare-tunnel` 目錄。

#### - `cloudflared tunnel create synology-tunnel`

1. 編輯 `cloudflare-tunnel` 目錄中的容器設定 json，修改 cmd 為 `tunnel create synology-tunnel`。
2. 匯入容器設定 json 並執行新容器。
3. 容器會停止，並在 `cloudflare-tunnel` 中建立 tunnel config json。
4. 建立 config.yml 並撰寫 ingress 規則。
5. 在 config.yml 中，tunnel 的值要與 tunnel config json 檔名一致，credentials-file 為 `/home/nonroot/.cloudflared/tunnel config json`。
6. 將第二個容器設定 json 匯出到 `cloudflare-tunnel` 目錄。

#### - `cloudflared tunnel route dns synology-tunnel synology.ruru910.com`

1. 編輯 `cloudflare-tunnel` 目錄中的第二個容器設定 json，修改 cmd 為 `tunnel route dns synology-tunnel synology.ruru910.com`。
2. 匯入第二個容器設定 json 並執行新容器。
3. 容器會停止並建立 DNS 紀錄，將網域指到 tunnel。

#### - `cloudflared tunnel run synology-tunnel`

1. 編輯 `cloudflare-tunnel` 目錄中的第二個容器設定 json，修改 cmd 為 `tunnel run synology-tunnel`。
2. 匯入第二個容器設定 json 並執行新容器。
3. Tunnel 現在可以連線使用。
