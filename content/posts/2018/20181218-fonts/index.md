---
title: "Install Font Libraries and Chinese Fonts on Linux CentOS 7"
date: 2018-12-18T22:13:40+08:00
menu:
  sidebar:
    name: "Install Font Libraries and Chinese Fonts on Linux CentOS 7"
    identifier: linux-centos7-install-fonts
    weight: 10
tags: ["Links", "Linux"]
categories: ["Links", "Linux"]
hero: images/hero/linux.png
---

- [Install Font Libraries and Chinese Fonts on Linux CentOS 7](https://hk.saowen.com/a/8e1349c5e25aaca06614d56d65fcd43156684d591da80b5a886806ceac06e199)

```shell
yum -y install fontconfig
```

Now you can see the fonts and fontconfig directories under /usr/shared (they did not exist before).

Before that we need to create a directory. First create /usr/shared/fonts/chinese.

`mkdir /usr/shared/fonts/chinese`

Copy the fonts you need and upload them to /usr/shared/fonts/chinese. Here I use SimSun and HeiTi (used in reports). You will see files with ttf and ttc extensions.

`chmod -R 755 /usr/share/fonts/chinese`

Next, install ttmkfdir to scan font information in the directory and generate the fonts.scale file.

```shell

yum -y install ttmkfdir

ttmkfdir -e /usr/share/X11/fonts/encodings/encodings.dir
```

```shell
vi /etc/fonts/fonts.conf

<dir>/usr/shared/fonts/chinese<dir>
```

Refresh the font cache in memory.

`fc-cache`
