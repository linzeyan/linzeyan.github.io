---
title: "channel 的 15 条规则和底层实现"
date: 2023-06-22T21:25:05+08:00
menu:
  sidebar:
    name: "channel 的 15 条规则和底层实现"
    identifier: go-channel-rules
    weight: 10
tags: ["URL", "Go", "channel"]
categories: ["URL", "Go", "channel"]
hero: images/hero/go.svg
---

- [channel 的 15 条规则和底层实现](https://mp.weixin.qq.com/s/AsytcOBg0XpTnPzDq7iEhQ)

### 操作规则

| 操作 |  nil  |            已关闭的 channel             |                             未关闭有缓冲区的 channel                              |           未关闭无缓冲区的 channel            |
| :--: | :---: | :-------------------------------------: | :-------------------------------------------------------------------------------: | :-------------------------------------------: |
| 关闭 | panic |                  panic                  | 成功关闭，然后可以读取缓冲区的值，读取完之后，继续读取到的是 channel 类型的默认值 | 成功关闭，之后读取到的是 channel 类型的默认值 |
| 接收 | 阻塞  | 不阻塞，读取到的是 channel 类型的默认值 |                                不阻塞，正常读取值                                 |                     阻塞                      |
| 发送 | 阻塞  |                  panic                  |                                不阻塞，正常写入值                                 |                     阻塞                      |

### 编译规则

| 操作 | channel 類型 |   結果   |
| :--: | :----------: | :------: |
| 接收 | 只写 channel | 编译错误 |
| 发送 | 只读 channel | 编译错误 |
| 关闭 | 只读 channel | 编译错误 |
