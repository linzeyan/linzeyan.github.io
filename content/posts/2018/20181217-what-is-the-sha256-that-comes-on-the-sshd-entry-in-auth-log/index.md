---
title: "What is the SHA256 that comes on the sshd entry in auth.log?"
date: 2018-12-17T16:11:43+08:00
menu:
  sidebar:
    name: "What is the SHA256 that comes on the sshd entry in auth.log?"
    identifier: linux-what-is-the-sha256-that-comes-on-the-sshd-entry-in-auth-log
    weight: 10
tags: ["URL", "Linux"]
categories: ["URL", "Linux"]
hero: images/hero/linux.png
---

- [What is the SHA256 that comes on the sshd entry in auth.log?](https://serverfault.com/questions/888281/what-is-the-sha256-that-comes-on-the-sshd-entry-in-auth-log)

`ssh-keygen -lf .ssh/id_rsa.pub`

```shell
cat .ssh/id_rsa.pub    |
    awk '{ print $2 }' | # Only the actual key data without prefix or comments
    base64 -d          | # decode as base64
    sha256sum          | # SHA256 hash (returns hex)
    awk '{ print $1 }' | # only the hex data
    xxd -r -p          | # hex to bytes
    base64               # encode as base64
```
