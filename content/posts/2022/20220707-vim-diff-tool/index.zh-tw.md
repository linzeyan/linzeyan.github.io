---
title: "使用 Vim 當作差異比對工具"
date: 2022-07-07T17:36:22+08:00
menu:
  sidebar:
    name: "使用 Vim 當作差異比對工具"
    identifier: command-line-diff-vim
    weight: 10
tags: ["Links", "command line", "Vim"]
categories: ["Links", "command line", "Vim"]
---

- [使用 Vim 當作差異比對工具](https://www.baeldung.com/linux/vim-diff-tool)

#### 指令

`vim -d file1.txt file2.txt`
或
`vimdiff file1.txt file2.txt`

- 在差異視窗間切換: `Ctrl-w + Ctrl-w`
- 切換分割視窗方向
  - `ctrl-w + K` 將視窗方向由垂直切換為水平。
  - `ctrl-w + H` 將視窗方向切回垂直分割。
- 在變更之間跳轉
  - `]c` 前往下一個變更。
  - `[c` 跳回上一個變更。
- 從差異視窗套用變更: `:diffget`, `:diffput`
- 匯出差異為 HTML: `:TOhtml | w ~/diff.html`
