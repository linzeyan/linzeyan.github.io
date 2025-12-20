---
title: "使用 Cloudflare 中转 V2Ray 流量"
date: 2024-10-22T09:24:08+08:00
menu:
  sidebar:
    name: "使用 Cloudflare 中转 V2Ray 流量"
    identifier: network-proxy-v2ray-forward-traffic-and-cloudflare-configuration
    weight: 10
tags: ["URL", "V2Ray", "Network", "Proxy"]
categories: ["URL", "V2Ray", "Network", "Proxy"]
hero: images/hero/network.png
---

- [使用 Cloudflare 中转 V2Ray 流量](https://233boy.com/v2ray/v2ray-cloudflare/)
- [最好用的 V2Ray 一键安装脚本](https://233boy.com/v2ray/v2ray-script/)
- [V2Ray 脚本 DNS 设置](https://233boy.com/v2ray/v2ray-dns/)
- [V2Ray 脚本中转教程](https://233boy.com/v2ray/v2ray-dokodemo-door/)

## 安装脚本

```bash
bash <(wget -qO- -o- https://git.io/v2ray.sh)
```

## 准备

我们现在就添加一个 DNS 记录，名称：`ai`，IPv4 地址：`写你的 VPS IP`，代理状态必须关闭，云朵图标为灰色。

提示：你可以使用 `v2ray ip` 查看你的 VPS IP。

## 添加中转配置

使用 `v2ray add ws ai.233boy.com` 添加一个 vmess-ws-tls 配置；记得把 `ai.233boy.com` 改成你的域名

就是刚才添加记录的那个域名，假设你的域名是 233boy.com ，添加的名称是 ai，域名就是 ai.233boy.com

## 开启中转

在 Cloudflare 后台主页，点击你的域名进去，在左侧选项菜单选择 `SSL/TLS`

将 SSL/TLS 加密模式更改为 `完全`

然后在左侧选项菜单选择 `DNS`

编辑添加的那个记录，把代理状态打开，即是 `已代理`，云朵图标为点亮状态，然后保存

把云朵点亮之后，流量就是走的 Cloudflare 中转了。

提醒，把云朵点亮就是流量通过 Cloudflare 中转，点灰云朵图标就是直连，不走 Cloudflare 中转。

## 获取真实客户端 IP

考虑到有些人会有某些特殊需求，因为套 CF 了默认情况在查看日志的时候会显示客户端 IP 是 CF 的。

如果你需要获取真实的客户端 IP，得更改一下 Caddy 的配置

在 `/etc/caddy/233boy/xxx.conf` 找到你的 caddy 配置文件，（xxx 指的是你的域名）

默认配置类似如下：

```
xxx:443 {
    reverse_proxy /56f7be67-809f-4f47-8cae-9bffa908adf5 127.0.0.1:2333
    import /etc/caddy/233boy/xxx.conf.add
}
```

最终更改的配置如下：

```
xxx:443 {
    reverse_proxy /56f7be67-809f-4f47-8cae-9bffa908adf5 127.0.0.1:2333 {
        header_up X-Real-IP {header.CF-Connecting-IP}
        header_up X-Forwarded-For {header.CF-Connecting-IP}
    }
    import /etc/caddy/233boy/xxx.conf.add
}
```

原则上，你仅需要更改增加一下 header_up 选项指定 IP 为 CF 转发就好了，

改好了要重启一下 Caddy：`v2ray restart caddy`

---

## DNS

输入 `v2ray dns` 即可选择相关 DNS

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

备注，https 开头的即是使用 DOH 方式，使用 DOH 方式默认开启本地查询，即是 DOH 本地模式 (DOHL)

set 选项是可以自定义 DNS，

none 选项是不配置任何 DNS

### google

快速设置 Google DNS: `v2ray dns 88`

快速设置 Google DNS DOH: `v2ray dns gg`

### cloudflare

快速设置 Cloudflare DNS: `v2ray dns 11`

快速设置 Cloudflare DNS DOH: `v2ray dns cf`

### nosex

快速设置 Cloudflare Family DNS DOH: `v2ray dns nosex`

备注，使用此方式，将无法打开小电影网站（提供给有特殊需求的时候使用

### set

快速自定义 DNS 使用 9.9.9.9：`v2ray dns set 9.9.9.9`

快速自定义使用 ADGUARD DNS DOH：`v2ray dns set https://dns.adguard-dns.com/dns-query`

使用 `v2ray dns set` 可以手动输入 DNS 值，

或者 `v2ray dns set 1.1.1.1` 直接指定使用 1.1.1.1 作为 DNS，后面的 1.1.1.1 可以自定义成任何你喜欢的 DNS

### none

如果你出现任何问题，请使用 `v2ray dns none` 来重置 DNS 配置

或者如果你想要 V2Ray 走系统 DNS，也使用此命令

---

## 利用 Dokodemo-door 进行转发

假设你有 A-B 两台 VPS，打算使用 A 机器转发流量到 B 机器。

常见的用途是国内连接到 A 机器的网络比较好，然后希望通过 A 机器转发数据到 B 机器，再通过 B 机器干坏事（

又或者是 B 机器可以解锁一些在线服务之类，但是直连效果不好，甚至 IP 都被墙了，想要使用 A 机器做前置转发。

缺点是，只能转发 TCP 或 UDP 流量，带 TLS 的不行

### 添加配置

先在 B 机器添加一个 V2Ray 配置，举例： `v2ray add tcp 233`

这样来就是添加了一个 VMESS-TCP 的配置，并且端口是 233

如果你已经有配置就不用再添加了，反正记下 B 机器的 `IP` 和配置的 `端口` 即可

因为利用 A 机器转发的时候必须要填写上 B 机器的 IP，以及要转到到 B 机器的哪个端口

### door

使用方法： `v2ray add door [port] [remote-addr] [remote-port]`

在 A 机器执行：`v2ray add door`，然后输入 B 机器的 IP 和端口

默认情况下 V2Ray 脚本会随机生成一个端口，如果你需要自定义端口请使用 `v2ray add door 需要自定义的端口`

### 测试

把 B 机器给出的配置里面的地址和端口，改成 A 机器的 IP 和端口即可

就是 B 机器的配置，假设你用 v2rayN 通过 URL 导入了配置，把配置的地址和端口改成 A 机器的 IP 和 Dokodemo-door 端口。

看看是不是能使用了？

### 一键添加

快速添加一个中转配置：

`v2ray add door 233 b.233boy.com 443`

解释：添加一个 Dokodemo-door 配置，端口 233，目标地址 b.233boy.com，目标端口 443。

是的，目标地址你也可以使用域名。

### 机智如我

虽然说上面的例子是来中转 V2Ray 配置使用，但是你也可以做一下跳板机，用来搞一下骚操作

比如说，转发数据到 1.1.1.1 DNS：`v2ray add door 53 1.1.1.1 53`，这样来就是你的 53 端口也可以做 DNS 啦

至于其他的操作，自行发挥！
