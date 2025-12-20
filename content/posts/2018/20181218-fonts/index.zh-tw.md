---
title: "Linux CentOS 7 安裝字體庫 & 中文本體"
date: 2018-12-18T22:13:40+08:00
menu:
  sidebar:
    name: "Linux CentOS 7 安裝字體庫 & 中文本體"
    identifier: linux-centos7-install-fonts
    weight: 10
tags: ["URL", "Linux"]
categories: ["URL", "Linux"]
hero: images/hero/linux.png
---

- [Linux CentOS 7 安裝字體庫 & 中文本體](https://hk.saowen.com/a/8e1349c5e25aaca06614d56d65fcd43156684d591da80b5a886806ceac06e199)

```shell
yum -y install fontconfig
```

這時在 /usr/shared 目錄就可以看到 fonts 和 fontconfig 目錄了（之前是沒有的）

在這之前我們還需要新建目錄，首先在 /usr/shared/fonts 目錄下新建一個目錄 chinese

`mkdir /usr/shared/fonts/chinese`

只需要將我們需要的字體拷貝出來並上傳至 linux 服務器 /usr/shared/fonts/chinese 目錄下即可，在這裏我選擇宋體和黑體（報表中用到了這兩種字體），可以看到是兩個後綴名為 ttf 和 ttc 的文檔

`chmod -R 755 /usr/share/fonts/chinese`

接下來需要安裝 ttmkfdir 來搜索目錄中所有的字體信息，並彙總生成 fonts.scale 文檔

```shell

yum -y install ttmkfdir

ttmkfdir -e /usr/share/X11/fonts/encodings/encodings.dir
```

```shell
vi /etc/fonts/fonts.conf

<dir>/usr/shared/fonts/chinese<dir>
```

刷新內存中的字體緩存

`fc-cache`
