---
title: "Bash 位元運算子"
date: 2022-07-04T15:20:39+08:00
menu:
  sidebar:
    name: "Bash 位元運算子"
    identifier: bash-bitwise-operators
    weight: 10
tags: ["Links", "BASH"]
categories: ["Links", "BASH"]
---

- [Bash 位元運算子](https://www.baeldung.com/linux/bash-bitwise-operators)

### Bash 的進位轉換工具

- Bash 的算術展開允許我們用「進位數字 + #」的方式表示任意進位的數字。

```bash
$ echo $((2#1001))
9
```

- bc 可以用 ibase（輸入進位）與 obase（輸出進位）輕鬆進行進位轉換。以下將十進位的 9 轉成二進位。

```bash
$ echo "ibase=10;obase=2;9" | bc
1001
```
