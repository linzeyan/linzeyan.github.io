---
title: "MacBook 设置 SSLKEYLOGFILE 环境变量解密 HTTPS 流量"
date: 2020-11-06T20:02:54+08:00
menu:
  sidebar:
    name: "MacBook 设置 SSLKEYLOGFILE 环境变量解密 HTTPS 流量"
    identifier: macos-ssl-key-log-file-decrypt-https-traffic
    weight: 10
tags: ["URL", "MacOS"]
categories: ["URL", "MacOS"]
---

- [MacBook 设置 SSLKEYLOGFILE 环境变量解密 HTTPS 流量](http://www.luwenpeng.cn/2020/04/29/MacBook%E8%AE%BE%E7%BD%AESSLKEYLOGFILE%E7%8E%AF%E5%A2%83%E5%8F%98%E9%87%8F%E8%A7%A3%E5%AF%86HTTPS%E6%B5%81%E9%87%8F/)

创建 keylogfile

```bash
mkdir ~/sslkeylogfile && touch ~/sslkeylogfile/keylogfile.log # 创建 keylogfile.log 文件
sudo chmod 777 ~/sslkeylogfile/keylogfile.log # 更改权限，确保 chrome 启动时能写入数据
```

配置环境变量

```bash
vim ~/.zshrc # 打开配置文件
export SSLKEYLOGFILE=~/sslkeylogfile/keylogfile.log # 配置环境变量
source ~/.zshrc # 使配置文件生效
```

配置 wireshark

perferences -> Protocols -> TLS

- 配置 TSL debug file 记录解密日志
- 配置 (Pre)-Master-Secret log filename 路径为 keylogfile.log 的绝对路径

使用 termial 启动 chrome

```bash
open -a 'Google Chrome' https://www.baidu.com/
```

注意：从 termial 启动 chrome，为了确保 chrome 可以读取 SSLKEYLOGFILE 环境变量。
