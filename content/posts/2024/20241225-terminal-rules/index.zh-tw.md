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

- ["Rules" that terminal programs follow](https://jvns.ca/blog/2024/11/26/terminal-rules/)

- 規則 1：非互動程式應在按 Ctrl-C 時退出
- 規則 2：按 q 時，TUI 應退出
- 規則 3：在空白行上按 Ctrl-D 時，REPL 應退出
- 規則 4：不要使用超過 16 種顏色
- 規則 5：支援 readline 鍵綁定
  - 規則 5.1：Ctrl-W 應刪除最後一個單字
- 規則 6：寫入管道時禁用顏色
- 規則 7： - 表示 stdin/stdout
