---
title: "Using Vim as a Diff Tool"
date: 2022-07-07T17:36:22+08:00
menu:
  sidebar:
    name: "Using Vim as a Diff Tool"
    identifier: command-line-diff-vim
    weight: 10
tags: ["URL", "command line", "Vim"]
categories: ["URL", "command line", "Vim"]
---

- [Using Vim as a Diff Tool](https://www.baeldung.com/linux/vim-diff-tool)

#### command

`vim -d file1.txt file2.txt`
or
`vimdiff file1.txt file2.txt`

- Switching Between Diff Windows: `Ctrl-w + Ctrl-w`
- Changing Split Window Orientation
  - `ctrl-w + K` key combination to change window orientation from vertical to horizontal.
  - `ctrl-w + H` shortcut to switch back window orientation to a vertical split.
- Jumping Between Changes
  - `]c` key combination to go to the next change.
  - `[c` shortcut to jump to the previous change.
- Applying Changes From the Diff Window: `:diffget`, `:diffput`
- Export Diff to the HTML Web Page: `:TOhtml | w ~/diff.html`
