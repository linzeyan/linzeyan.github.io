---
title: "Go Style Decisions - Pass values"
date: 2024-04-13T17:38:00+08:00
menu:
  sidebar:
    name: Go Style Decisions - Pass values
    identifier: golang-go-style-decisions-pass-values
    weight: 10
tags: ["Go", "URL"]
categories: ["Go", "URL"]
hero: images/hero/go.svg
---

- [Go Style Decisions - Pass values](https://google.github.io/styleguide/go/decisions.html#pass-values)

不要僅僅為了節省一些位元組而將指標作為函數參數傳遞。如果函數始終將其參數 `x` 讀取為 `*x`，則該參數不應該是指標。常見的實例包括傳遞指向字串的指標 (`*string`) 或指向介面值的指標 (`*io.Reader`)。在這兩種情況下，值本身都是固定大小的，可以直接傳遞。

此建議不適用於大型結構，甚至不適用於可能增加大小的小型結構。特別是，協定緩衝區訊息通常應透過指標而不是值來處理。指標類型滿足 `proto.Message` 介面（被 `proto.Marshal` 、 `protocmp.Transform` 等接受），且協定緩衝區訊息可能非常大，並且通常會隨著時間的推移而變得更大。
