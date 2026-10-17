---
title: "Til"
date: 2026-10-17T19:20:07+08:00
menu:
  sidebar:
    name: "Til"
    identifier: til-recent-20261017
    weight: 10
tags:
  [
    "Links",
    "Bookmark",
    "Typing",
    "Music",
    "Board Game",
    "Game",
    "Python",
    "Pandas",
    "Linux",
    "Kernel",
    "Interview",
    "Go",
    "HTTP",
    "Diagrams",
    "Audiobook",
    "TTS",
    "LLM",
    "Agent",
    "Memory",
    "macOS",
    "Protobuf",
    "LEGO",
    "OCR",
    "HTML",
    "slides",
    "Skill",
    "MCP",
    "Reverse Engineering",
  ]
categories:
  [
    "Links",
    "Bookmark",
    "Typing",
    "Music",
    "Board Game",
    "Game",
    "Python",
    "Pandas",
    "Linux",
    "Kernel",
    "Interview",
    "Go",
    "HTTP",
    "Diagrams",
    "Audiobook",
    "TTS",
    "LLM",
    "Agent",
    "Memory",
    "macOS",
    "Protobuf",
    "LEGO",
    "OCR",
    "HTML",
    "slides",
    "Skill",
    "MCP",
    "Reverse Engineering",
  ]
---

- [keybr.com is not (just) a typing test](https://www.keybr.com/)
- [Lofi Cities](https://loficities.com/)
- [Hole Punch](https://notoriousbfg.com/hole-punch/)
- [Play board games online with friends](https://buddyboardgames.com/)
- [輔導室：今天也不能倒下](https://claude.ai/artifact/AWwoUVfR7KFTQd7ateyNfb)
- [Virtual Guitar](https://guitoro.com/)
- [Big words for any screen](https://bigwords.page/)
- **Article**
  - [Pandas Should Go Extinct](https://eddie.codes/posts/pandas-should-go-extinct/)
  - https://x.com/**soragoto**/status/2098983783085318491
  - [Better HTTP/1 connection reuse](https://go.dev/blog/http-connection-reuse)
- **Diagram**
  - [reladraw: reladraw is a text language for diagrams where you say where things go.](https://github.com/reladraw/reladraw)
- **Github**
  - [abogen: Generate audiobooks from EPUBs, PDFs and text with synchronized captions.](https://github.com/denizsafak/abogen)
  - [mem0: The Memory Layer for AI Agents - Drop-in memory infrastructure for AI agents and apps. Context that persists. Built for production.](https://github.com/mem0ai/mem0)
  - [ATBClone: The Ultimate macOS App Cloner & Sandbox Bypass Engine.](https://github.com/aitobox/ATBClone)
  - [buf: The best way of working with Protocol Buffers.](https://github.com/bufbuild/buf)
  - [ldraw-nova: Give an AI agent a model idea. Guide it, let it build it, and get an LDraw LEGO© model.](https://github.com/anteloc/ldraw-nova)
  - [Craft APP](https://github.com/storytold)
  - [Chandra OCR 2: OCR model that handles complex tables, forms, handwriting with full layout.](https://github.com/datalab-to/chandra)
- **Present**
  - [effective-html: Agent skills for useful HTML artifacts, wireframes, interactive prototypes, plans, and diagrams.](https://github.com/plannotator/effective-html)
- **Skill**
  - [go-modern-guidelines: Help AI coding agents write modern Go](https://github.com/JetBrains/go-modern-guidelines)
  - [Reverse Engineer Anything: One MCP for reverse engineering across binaries, applications, and runtime behavior.](https://github.com/morluto/rea)

## https://x.com/**soragoto**/status/2098983783085318491

> 面试官：我看你简历上写熟悉 Linux，大概有多熟悉？看过源码吗？
>
> 我：看过一些。
>
> 面试官：那说说有什么优秀设计，或者让你印象比较深的地方。
>
> 我：那就要说到华硕的 HID 驱动了。
>
> 面试官：？
>
> 我：华硕有些键盘会在某些特定情况下往 host 发送电源相关的键值，导致 host 关机，所以内核驱动里专门把那个键值屏蔽了。
>
> 面试官：nmd，现在也是我印象最深的地方了。

https://github.com/torvalds/linux/blob/master/drivers/hid/hid-asus.c
