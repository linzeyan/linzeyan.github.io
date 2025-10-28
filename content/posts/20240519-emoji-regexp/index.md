---
title: "Emoji Regular expression"
date: 2024-05-19T14:37:00+08:00
menu:
  sidebar:
    name: Emoji Regular expression
    identifier: emoji-regexp
    weight: 10
tags: ["regex", "URL", "emoji"]
categories: ["regex", "URL", "emoji"]
---

# [Emoji Regular expression](https://taxodium.ink/post/emoji-regexp/)

`/\p{Emoji}/u`

既然是匹配 Emoji，那么 loneProperty (\p{loneProperty}) 就应该是 Emoji ? 实际测试并不符合需求，因为在 Emoji 官方文档中， 123456789\*# 也是被看作是 Emoji， 如果用这个正则的话，就会把数字也认为是 Emoji，不符合只排除特殊表情的要求。

`/\p{Extended_Pictographic}/u`

而 Extended_Pictographic 表示的 Emoji 才是我们认为的那些表情符号。
