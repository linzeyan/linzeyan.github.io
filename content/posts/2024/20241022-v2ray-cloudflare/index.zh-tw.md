---
title: "使用 Cloudflare 中轉 V2Ray 流量"
date: 2024-10-22T09:24:08+08:00
menu:
  sidebar:
    name: "使用 Cloudflare 中轉 V2Ray 流量"
    identifier: network-proxy-v2ray-cloudflare-configuration
    weight: 10
tags: ["Links", "V2Ray", "Network", "Proxy"]
categories: ["Links", "V2Ray", "Network", "Proxy"]
hero: images/hero/network.png
---

- [使用 Cloudflare 中轉 V2Ray 流量](https://233boy.com/v2ray/v2ray-cloudflare/)
- [最好用的 V2Ray 一鍵安裝腳本](https://233boy.com/v2ray/v2ray-script/)
- [V2Ray 腳本 DNS 設定](https://233boy.com/v2ray/v2ray-dns/)
- [V2Ray 腳本中轉教學](https://233boy.com/v2ray/v2ray-dokodemo-door/)

## 安裝腳本

```bash
bash <(wget -qO- -o- https://git.io/v2ray.sh)
```

## 準備

我們現在就新增一筆 DNS 記錄，名稱：`ai`，IPv4 位址：`寫你的 VPS IP`，代理狀態必須關閉，雲朵圖示為灰色。

提示：你可以使用 `v2ray ip` 查看你的 VPS IP。

## 新增中轉配置

使用 `v2ray add ws ai.233boy.com` 新增一個 vmess-ws-tls 配置；記得把 `ai.233boy.com` 改成你的網域。

就是剛才新增記錄的那個網域，假設你的網域是 233boy.com，新增的名稱是 ai，網域就是 ai.233boy.com。

## 開啟中轉

在 Cloudflare 後台首頁，點你的網域進去，在左側選項選單選擇 `SSL/TLS`。

把 SSL/TLS 加密模式改成 `完全`。

接著在左側選項選單選擇 `DNS`。

編輯剛新增的記錄，把代理狀態打開，也就是 `已代理`，雲朵圖示為點亮狀態，然後儲存。

雲朵點亮後，流量就會走 Cloudflare 中轉。

提醒：雲朵點亮代表流量經由 Cloudflare 中轉；雲朵灰色代表直連，不走 Cloudflare 中轉。

## 取得真實客戶端 IP

有些人可能有特殊需求，因為套上 CF 後，預設在查看日誌時會顯示客戶端 IP 為 CF 的 IP。

如果你需要取得真實客戶端 IP，就得修改 Caddy 的配置。

在 `/etc/caddy/233boy/xxx.conf` 找到你的 Caddy 配置檔（xxx 是你的網域）。

預設配置如下：

```
xxx:443 {
    reverse_proxy /56f7be67-809f-4f47-8cae-9bffa908adf5 127.0.0.1:2333
    import /etc/caddy/233boy/xxx.conf.add
}
```

修改後的配置如下：

```
xxx:443 {
    reverse_proxy /56f7be67-809f-4f47-8cae-9bffa908adf5 127.0.0.1:2333 {
        header_up X-Real-IP {header.CF-Connecting-IP}
        header_up X-Forwarded-For {header.CF-Connecting-IP}
    }
    import /etc/caddy/233boy/xxx.conf.add
}
```

原則上，你只需要增加 `header_up` 選項，把 IP 指定為 CF 轉發即可。

改完後要重啟 Caddy：`v2ray restart caddy`

---

## DNS

輸入 `v2ray dns` 即可選擇相關 DNS。

```shell

请选择 DNS:

1) 1.1.1.1
2) 8.8.8.8
3) https://dns.google/dns-query
4) https://cloudflare-dns.com/dns-query
5) https://family.cloudflare-dns.com/dns-query
6) set
7) none

请选择 [1-7]:
```

備註：以 https 開頭的即是使用 DOH 方式，使用 DOH 方式預設開啟本地查詢，即是 DOH 本地模式（DOHL）。

set 選項可以自訂 DNS。

none 選項表示不設定任何 DNS。

### google

快速設定 Google DNS：`v2ray dns 88`

快速設定 Google DNS DOH：`v2ray dns gg`

### cloudflare

快速設定 Cloudflare DNS：`v2ray dns 11`

快速設定 Cloudflare DNS DOH：`v2ray dns cf`

### nosex

快速設定 Cloudflare Family DNS DOH：`v2ray dns nosex`

備註：使用此方式將無法開啟某些成人網站（提供給有特殊需求時使用）。

### set

快速自訂 DNS 使用 9.9.9.9：`v2ray dns set 9.9.9.9`

快速自訂使用 ADGUARD DNS DOH：`v2ray dns set https://dns.adguard-dns.com/dns-query`

使用 `v2ray dns set` 可以手動輸入 DNS 值。

或者 `v2ray dns set 1.1.1.1` 直接指定使用 1.1.1.1 作為 DNS，後面的 1.1.1.1 可以自訂成你喜歡的 DNS。

### none

如果你出現任何問題，請使用 `v2ray dns none` 來重置 DNS 配置。

或者如果你想讓 V2Ray 走系統 DNS，也使用此命令。

---

## 利用 Dokodemo-door 進行轉發

假設你有 A、B 兩台 VPS，打算使用 A 機器轉發流量到 B 機器。

常見用途是國內連到 A 機器的網路比較好，然後希望透過 A 機器轉發資料到 B 機器，再透過 B 機器做其他用途。

或者 B 機器可以解鎖一些線上服務，但直連效果不好，甚至 IP 都被封鎖了，就用 A 機器做前置轉發。

缺點是只能轉發 TCP 或 UDP 流量，帶 TLS 的不行。

### 新增配置

先在 B 機器新增一個 V2Ray 配置，舉例：`v2ray add tcp 233`

這樣就新增了一個 VMESS-TCP 的配置，且埠號是 233。

如果你已經有配置就不用再新增了，記下 B 機器的 `IP` 和配置的 `埠號` 即可。

因為使用 A 機器轉發時必須填寫 B 機器的 IP，以及要轉到 B 機器的哪個埠號。

### door

使用方法：`v2ray add door [port] [remote-addr] [remote-port]`

在 A 機器執行：`v2ray add door`，然後輸入 B 機器的 IP 和埠號。

預設情況下 V2Ray 腳本會隨機產生一個埠號，如果你需要自訂埠號請使用 `v2ray add door 自訂埠號`。

### 測試

把 B 機器給出的配置裡的位址和埠號改成 A 機器的 IP 和埠號即可。

就是 B 機器的配置，假設你用 v2rayN 透過 URL 匯入了配置，把配置的位址和埠號改成 A 機器的 IP 和 Dokodemo-door 埠號。

看看是不是能使用了？

### 一鍵新增

快速新增一個中轉配置：

`v2ray add door 233 b.233boy.com 443`

說明：新增一個 Dokodemo-door 配置，埠號 233，目標位址 b.233boy.com，目標埠號 443。

是的，目標位址也可以使用網域。

### 機智如我

雖然說上面的例子是用來中轉 V2Ray 配置，但你也可以做個跳板機，用來玩點技巧。

例如，轉發資料到 1.1.1.1 DNS：`v2ray add door 53 1.1.1.1 53`，這樣你的 53 埠也可以做 DNS。

其他操作就自行發揮吧！
