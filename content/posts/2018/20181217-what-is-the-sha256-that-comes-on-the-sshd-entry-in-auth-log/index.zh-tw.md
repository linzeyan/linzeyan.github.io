---
title: "auth.log 中 sshd 這行的 SHA256 是什麼？"
date: 2018-12-17T16:11:43+08:00
menu:
  sidebar:
    name: "auth.log 中 sshd 這行的 SHA256 是什麼？"
    identifier: linux-what-is-the-sha256-that-comes-on-the-sshd-entry-in-auth-log
    weight: 10
tags: ["Links", "Linux"]
categories: ["Links", "Linux"]
hero: images/hero/linux.png
---

- [auth.log 中 sshd 這行的 SHA256 是什麼？](https://serverfault.com/questions/888281/what-is-the-sha256-that-comes-on-the-sshd-entry-in-auth-log)

`ssh-keygen -lf .ssh/id_rsa.pub`

```shell
cat .ssh/id_rsa.pub    |
    awk '{ print $2 }' | # 只取實際的 key 資料，不含前綴或註解
    base64 -d          | # 以 base64 解碼
    sha256sum          | # SHA256 雜湊（回傳十六進位）
    awk '{ print $1 }' | # 只取十六進位資料
    xxd -r -p          | # 十六進位轉位元組
    base64               # 以 base64 編碼
```
