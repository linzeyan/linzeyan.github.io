---
title: Rules that terminal programs follow
date: 2024-12-25T08:45:00+08:00
menu:
  sidebar:
    name: Rules that terminal programs follow
    identifier: url-terminal-rules
    weight: 10
tags: ["URL", "terminal", "command line"]
categories: ["URL", "terminal", "command line"]
---

["Rules" that terminal programs follow](https://jvns.ca/blog/2024/11/26/terminal-rules/)

- rule 1: noninteractive programs should quit when you press Ctrl-C
- rule 2: TUIs should quit when you press q
- rule 3: REPLs should quit when you press Ctrl-D on an empty line
- rule 4: don't use more than 16 colours
- rule 5: vaguely support readline keybindings
  - rule 5.1: Ctrl-W should delete the last word
- rule 6: disable colours when writing to a pipe
- rule 7: - means stdin/stdout
