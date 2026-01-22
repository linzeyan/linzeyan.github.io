---
title: "終端機程式遵循的規則"
date: 2024-12-25T08:45:00+08:00
menu:
  sidebar:
    name: "終端機程式遵循的規則"
    identifier: url-terminal-rules
    weight: 10
tags: ["Links", "terminal", "command line"]
categories: ["Links", "terminal", "command line"]
---

- [終端機程式遵循的「規則」](https://jvns.ca/blog/2024/11/26/terminal-rules/)

- 規則 1：非互動程式應在按 Ctrl-C 時退出
- 規則 2：按 q 時，TUI 應退出
- 規則 3：在空白行上按 Ctrl-D 時，REPL 應退出
- 規則 4：不要使用超過 16 種顏色
- 規則 5：支援 readline 鍵綁定
  - 規則 5.1：Ctrl-W 應刪除最後一個單字
- 規則 6：寫入管道時停用顏色
- 規則 7：- 表示 stdin/stdout
