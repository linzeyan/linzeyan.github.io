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
---

# [Go Style Decisions - Pass values](https://google.github.io/styleguide/go/decisions.html#pass-values)

Do not pass pointers as function arguments just to save a few bytes. If a function reads its argument `x` only as `*x` throughout, then the argument shouldn't be a pointer. Common instances of this include passing a pointer to a string (`*string`) or a pointer to an interface value (`*io.Reader`). In both cases, the value itself is a fixed size and can be passed directly.

This advice does not apply to large structs, or even small structs that may increase in size. In particular, protocol buffer messages should generally be handled by pointer rather than by value. The pointer type satisfies the `proto.Message` interface (accepted by `proto.Marshal`, `protocmp.Transform`, etc.), and protocol buffer messages can be quite large and often grow larger over time.
