---
title: "如何設定時區與NTP服務在RHEL7/CentOS7"
date: 2020-09-29T11:41:43+08:00
menu:
  sidebar:
    name: "如何設定時區與NTP服務在RHEL7/CentOS7"
    identifier: linux-how-to-config-chronyd-on-rhel7-centos7
    weight: 10
tags: ["URL", "Linux", "chrony"]
categories: ["URL", "Linux", "chrony"]
hero: images/hero/linux.png
---

- [如何設定時區與 NTP 服務在 RHEL7/CentOS7](https://blog.skywebster.com/how-to-config-chronyd-on-rhel7-centos7/)

chrony 包含兩個程序，chronyd 是一個可以在啟動時啟動的守護進程，chronyc 是一個命令行界面程序，可用於監控 chronyd 的性能並在運行時更改各種運行參數。

注意 ntpd 和 chronyd 擇一就可，不要同時運作。

##### 設定時區

```shell
~# timedatectl set-timezone Asia/Taipei
~# timedatectl
      Local time: Tue 2018-03-27 14:13:38 CST
  Universal time: Tue 2018-03-27 06:13:38 UTC
        RTC time: Tue 2018-03-27 06:13:40
       Time zone: Asia/Taipei (CST, +0800)
     NTP enabled: no
NTP synchronized: no
 RTC in local TZ: no
      DST active: n/a
```

##### 設定 chronyd

```shell
# 安裝
~# yum install -y chrony

# 配置設定檔
~# cat /etc/chrony.conf
# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (http://www.pool.ntp.org/join.html).
server 0.tw.pool.ntp.org iburst            --->改成本地的伺服器
server 1.tw.pool.ntp.org iburst            --->改成本地的伺服器
server 2.tw.pool.ntp.org iburst            --->改成本地的伺服器
server 3.tw.pool.ntp.org iburst            --->改成本地的伺服器

# 啟動服務和設為開機時啟動
~# systemctl enable chronyd
~# systemctl start chronyd
```

##### racking 參數顯示有關系統時間效能

```shell
~# chronyc tracking
Reference ID    : 3DD8996B (61-216-153-107.hinet-ip.hinet.net)   --->表示現在同步的時間伺服器，如果沒有id表示沒有同步
Stratum         : 4    --->表示計算機有多少"跳hop" 表示本地的是第四層
Ref time (UTC)  : Tue Mar 27 06:03:38 2018   --->最後一次測量的時間
System time     : 0.000040356 seconds fast of NTP time   --->調整系統時間
Last offset     : +0.000163738 seconds
RMS offset      : 0.000163738 seconds
Frequency       : 21.384 ppm fast
Residual freq   : +0.000 ppm
Skew            : 675.319 ppm
Root delay      : 0.008527911 seconds
Root dispersion : 0.066466033 seconds
Update interval : 2.0 seconds
Leap status     : Normal   --->Normal要顯示此值, Insert second, Delete second or Not synchronised.
```

```shell
~# chronyc sources -v
210 Number of sources = 4

  .-- Source mode  '^' = server, '=' = peer, '#' = local clock.
 / .- Source state '*' = current synced, '+' = combined , '-' = not combined,
| /   '?' = unreachable, 'x' = time may be in error, '~' = time too variable.
||                                                 .- xxxx [ yyyy ] +/- zzzz
||      Reachability register (octal) -.           |  xxxx = adjusted offset,
||      Log2(Polling interval) --.      |          |  yyyy = measured offset,
||                                \     |          |  zzzz = estimated error.
||                                 |    |           \
MS Name/IP address         Stratum Poll Reach LastRx Last sample
===============================================================================
^* 59-124-29-241.hinet-ip.h>     3   6    37    24  -1462us[-2363us] +/-   49ms
^+ 61-216-153-107.hinet-ip.>     3   6    37    23   -556us[ -556us] +/-   64ms
^? 59-125-122-217.hinet-ip.>     0   7     0     -     +0ns[   +0ns] +/-    0ns
^- 61-216-153-105.hinet-ip.>     3   6    37    23   -280us[ -280us] +/-   64ms
```

##### 看同步源頭的資訊

```shell
~# chronyc sourcestats -v
210 Number of sources = 4
                             .- Number of sample points in measurement set.
                            /    .- Number of residual runs with same sign.
                           |    /    .- Length of measurement set (time).
                           |   |    /      .- Est. clock freq error (ppm).
                           |   |   |      /           .- Est. error in freq.
                           |   |   |     |           /         .- Est. offset.
                           |   |   |     |          |          |   On the -.
                           |   |   |     |          |          |   samples. \
                           |   |   |     |          |          |             |
Name/IP Address            NP  NR  Span  Frequency  Freq Skew  Offset  Std Dev
==============================================================================
59-124-29-241.hinet-ip.h>   6   5   135     -0.454      4.553   -784us    66us
61-216-153-107.hinet-ip.>   6   6   135     +4.455     19.761   +622us   247us
59-125-122-217.hinet-ip.>   0   0     0     +0.000   2000.000     +0ns  4000ms
61-216-153-105.hinet-ip.>   6   4   136     +8.965     42.440  +1250us   495us
```

##### 將系統時間寫到硬體(主機板上的時間)上

```shell
~# hwclock --systohc
~# date ; hwclock
Tue Mar 27 14:07:57 CST 2018
Tue 27 Mar 2018 02:07:58 PM CST  -0.938012 seconds
```
