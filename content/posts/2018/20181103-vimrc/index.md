---
title: "vimrc Configuration Guide"
date: 2018-11-03T23:30:52+08:00
menu:
  sidebar:
    name: "vimrc Configuration Guide"
    identifier: vim-vimrc-configuration
    weight: 10
tags: ["Links", "Vim"]
categories: ["Links", "Vim"]
---

- [vimrc Configuration Guide](https://wiki.csie.ncku.edu.tw/vim/vimrc)

- :set nu
  - Show line numbers: useful for debugging.
- :set ai
  - Auto-indent: if the previous line has two tab widths, pressing Enter keeps those two tab widths on the next line.
- :set cursorline
  - Cursor line: underline the current line to help locate the cursor.
- :set bg=light
  - Color scheme for light backgrounds.
  - The default assumes a light background (white, etc), but if your terminal background is dark purple, text may disappear (for example, comments in dark blue). Change this to :set bg=dark.
- :set tabstop=4
  - Indent width (default is 8 spaces).
  - Pressing Tab moves the cursor 4 spaces. There may be multiple spaces but actually only one tab character.
  - Note: in other environments, a tab is still 8 spaces wide.
- :set shiftwidth=4
  - Auto-indent shift width: the amount to indent left or right.

Optional settings

- :set mouse=a
  - Enable mouse selection: you can select text, and the scroll wheel scrolls the page (not the cursor).
  - It can replace selecting text with `v`; with ctrl+insert (copy) and shift+insert (paste), it is convenient.
- :set mouse=""
  - Disable mouse selection: you cannot select text, and the scroll wheel only moves the cursor.
- :set ruler
  - (default) show the current line, column, and position percentage in the bottom-right.
- :set backspace=2
  - (default) enable backspace in insert mode.
- :set formatoptions+=r
  - Auto-comment (note: if a line you paste contains a comment, this setting will make each following line a comment).
- :set history=100
  - Keep 100 commands in history.
- :set incsearch
  - Show results before the keyword is fully entered.
  - If this feels too eager, use ctrl+n for auto-completion.
