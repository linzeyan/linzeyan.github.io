---
title: "Bash Bitwise Operators"
date: 2022-07-04T15:20:39+08:00
menu:
  sidebar:
    name: "Bash Bitwise Operators"
    identifier: bash-bitwise-operators
    weight: 10
tags: ["URL", "BASH"]
categories: ["URL", "BASH"]
---

- [Bash Bitwise Operators](https://www.baeldung.com/linux/bash-bitwise-operators)

### Bash's Tools for Base Conversion

- Bash's arithmetic expansion allows us to write numbers in any base by prefixing the numeric digits of the base followed by the hash symbol.

```bash
$ echo $((2#1001))
9
```

- bc allows us to convert effortlessly between bases, using the parameters ibase (for the input base) and obase (for the output base). So, let's convert the decimal number 9 to base 2

```bash
$ echo "ibase=10;obase=2;9" | bc
1001
```
