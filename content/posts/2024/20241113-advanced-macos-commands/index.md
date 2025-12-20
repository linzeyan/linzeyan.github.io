---
title: "Advanced macOS Command-Line Tools"
date: 2024-11-13T09:14:26+08:00
menu:
  sidebar:
    name: "Advanced macOS Command-Line Tools"
    identifier: macos-advanced-macos-built-in-commands
    weight: 10
tags: ["URL", "macOS", "command line"]
categories: ["URL", "macOS", "command line"]
---

- [Advanced macOS Command-Line Tools](https://saurabhs.org/advanced-macos-commands)
- [Useful built-in macOS command-line utilities](https://weiyen.net/articles/useful-macos-cmd-line-utilities/)
- [苹果：为了安全让 M2 吃灰](https://catcoding.me/p/apple-perf/)

#### sips - image manipulation

`sips -z <height> <width> <image>` resizes the specified image, ignoring the previous aspect ratio.

`sips -Z <size> <image>` resizes the largest side of the specified image, preserving the aspect ratio.

`sips -c <height> <width> <image>` crops the specified image to the given dimensions (relative to the center of the original image).

`sips -r <degrees> <image>` rotates the image by the specified degrees.

By default, sips will destructively overwrite the input image. Use the -o flag to specify a different output file path (which must have the same file extension as the input image).

#### textutil - document file converter

textutil can convert files to and from Microsoft Word, plain text, rich text, and HTML formats.

`textutil -convert html journal.doc` converts journal.doc into journal.html.

The possible values for -convert are: txt, html, rtf, rtfd, doc, docx.

#### pmset - configure power management

`pmset -g` prints all available power configuration information.

`pmset -g assertions` displays information about power-related assertions made by other processes. This can be useful for finding a process that is preventing your Mac from going to sleep.

`pmset -g thermlog` displays information about any processes that have been throttled (useful when running benchmarks).

`pmset displaysleepnow` immediately puts the display to sleep without putting the rest of the system to sleep.

`pmset sleepnow` immediately puts the entire system to sleep.

---

#### SIP 是什么？

这东西全称 System Integrity Protection，译为系统完整性保护

SIP 是 OS X El Capitan 时开始采用的一项安全技术，目的是为了限制 root 账户对系统的完全控制权，也叫 Rootless 保护机制。从文档看出，苹果自家的 Xcode 系统是做了特殊处理的，但第三方软件需要经过 SIP 的检查。

简而言之 SIP 会在我们跑任软件之前，把你的执行文件做一个校验和，然后通过网络请求发送到让人敬畏的苹果服务器，就是为了检测是否是恶意软件！

如果你想关闭 SIP，还有那么点麻烦：

- 重启 Mac，按住 Command + R 直到屏幕上出现苹果的标志和进度条，进入 Recovery 模式。(如果是新的 Mac 就在启动的时候长按住电源键)
- 在屏幕上方的工具栏找到并打开终端，输入命令 `csrutil disable` ；
- 关掉终端，重启 Mac；
- 重启以后可以在终端中查看状态确认。

##### 一个读者指出了更简单的办法，把你信任的工具加入到 Developer Tools(必须通过 UI 设置)

Setting ==> Privacy & Security ==> Developer Tools
