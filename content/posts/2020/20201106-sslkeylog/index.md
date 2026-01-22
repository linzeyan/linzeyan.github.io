---
title: "Set SSLKEYLOGFILE on MacBook to decrypt HTTPS traffic"
date: 2020-11-06T20:02:54+08:00
menu:
  sidebar:
    name: "Set SSLKEYLOGFILE on MacBook to decrypt HTTPS traffic"
    identifier: macos-ssl-key-log-file-decrypt-https-traffic
    weight: 10
tags: ["Links", "macOS"]
categories: ["Links", "macOS"]
---

- [Set SSLKEYLOGFILE on MacBook to decrypt HTTPS traffic](http://www.luwenpeng.cn/2020/04/29/MacBook%E8%AE%BE%E7%BD%AESSLKEYLOGFILE%E7%8E%AF%E5%A2%83%E5%8F%98%E9%87%8F%E8%A7%A3%E5%AF%86HTTPS%E6%B5%81%E9%87%8F/)

Create keylogfile

```bash
mkdir ~/sslkeylogfile && touch ~/sslkeylogfile/keylogfile.log # create keylogfile.log
sudo chmod 777 ~/sslkeylogfile/keylogfile.log # change permissions so Chrome can write on startup
```

Configure environment variable

```bash
vim ~/.zshrc # open config file
export SSLKEYLOGFILE=~/sslkeylogfile/keylogfile.log # set environment variable
source ~/.zshrc # reload config
```

Configure Wireshark

preferences -> Protocols -> TLS

- Set TLS debug file to record decryption logs
- Set (Pre)-Master-Secret log filename to the absolute path of keylogfile.log

Start Chrome from terminal

```bash
open -a 'Google Chrome' https://www.baidu.com/
```

Note: start Chrome from terminal to ensure it can read the SSLKEYLOGFILE environment variable.
