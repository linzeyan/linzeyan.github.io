---
title: "SSH failing with Error : fatal: daemon() failed: No such device"
date: 2021-03-04T18:48:39+08:00
menu:
  sidebar:
    name: "SSH failing with Error : fatal: daemon() failed: No such device"
    identifier: linux-ssh-failing-with-error-fatal-daemon-failed-no-such-device
    weight: 10
tags: ["URL", "Linux", "SSH"]
categories: ["URL", "Linux", "SSH"]
hero: images/hero/linux.png
---

- [SSH failing with Error : fatal: daemon() failed: No such device](<https://admin-ahead.com/forum/general-linux/ssh-failing-with-error-fatal-daemon()-failed-no-such-device/>)

/var/log/secure

`Oct 10 10:58:05 vps sshd[23799]: fatal: daemon() failed: No such device`

```bash
# rm -vf /dev/null
removed `/dev/null`
-bash-3.2# mknod /dev/null c 1 3
Started SSH and the SSH started responding:

# service sshd restart
Stopping sshd: [ OK ]
Starting sshd: [ OK ]
-bash-3.2# service sshd status
openssh-daemon (pid 30608) is running…
```
