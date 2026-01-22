---
title: "Zsh tab 補完無法使用"
date: 2021-12-10T17:44:49+08:00
menu:
  sidebar:
    name: "Zsh tab 補完無法使用"
    identifier: shell-zsh-tab-completion-not-working
    weight: 10
tags: ["Links", "SHELL", "ZSH", "Completion"]
categories: ["Links", "SHELL", "ZSH", "Completion"]
hero: images/hero/shell.png
---

- [Zsh tab 補完無法使用](https://stackoverflow.com/questions/46939906/zsh-tab-completion-not-working)

#### 問題

雖然我之前用過 Oh-My-Zsh，但這次（設定新電腦）我決定盡量不要安裝它，讓環境更精簡。現在我想單獨取用 Oh-My-Zsh 的大小寫不敏感補完功能。翻查原始碼後，我找到下面這行：
`zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'`

我相當確定 Oh-My-Zsh 就是用這行達成我的需求，所以我把它加進 `.zshrc`。重啟終端機後輸入 `cd desk`，再按 [tab]，結果沒有作用，並沒有補完成 `cd Desktop/`。

以下是完整的 `.zshrc` 供參考：

```bash
# Source - https://stackoverflow.com/q
# Posted by kylemart
# Retrieved 2026-01-05, License - CC BY-SA 3.0

# pure shell theme
autoload -U promptinit; promptinit
prompt pure

# completion definitions
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
fpath=(/usr/local/share/zsh-completions $fpath)

# syntax highlighting (must be last line)
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

#### 答案

只要 `autoload` 並執行 `compinit` 即可。

以下是新的 `.zshrc`：

```bash
# Source - https://stackoverflow.com/a
# Posted by kylemart, modified by community. See post 'Timeline' for change history
# Retrieved 2026-01-05, License - CC BY-SA 3.0

autoload -U compinit promptinit

promptinit
prompt pure

compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
fpath=(/usr/local/share/zsh-completions $fpath)

source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```
