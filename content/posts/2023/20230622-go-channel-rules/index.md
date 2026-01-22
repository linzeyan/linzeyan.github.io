---
title: "15 Rules of Channels and Their Implementation"
date: 2023-06-22T21:25:05+08:00
menu:
  sidebar:
    name: "15 Rules of Channels and Their Implementation"
    identifier: go-channel-rules
    weight: 10
tags: ["Links", "Go", "channel"]
categories: ["Links", "Go", "channel"]
hero: images/hero/go.svg
---

- [15 Rules of Channels and Their Implementation](https://mp.weixin.qq.com/s/AsytcOBg0XpTnPzDq7iEhQ)

### Operation rules

| Operation |  nil  |          Closed channel           |                     Open buffered channel                      |        Open unbuffered channel         |
| :--: | :---: | :-------------------------------------: | :-------------------------------------------------------------------------------: | :-------------------------------------------: |
| Close | panic |                  panic                  | Close succeeds; buffered values can be read. After buffer drains, further reads return the zero value of the channel type. | Close succeeds; further reads return the zero value of the channel type. |
| Receive | Block  | Non-blocking; returns the zero value of the channel type | Non-blocking; reads values normally | Block |
| Send | Block  |                  panic                  | Non-blocking; writes values normally | Block |

### Compile-time rules

| Operation | Channel type | Result |
| :--: | :----------: | :------: |
| Receive | Send-only channel | Compile error |
| Send | Receive-only channel | Compile error |
| Close | Receive-only channel | Compile error |
