---
title: "Zsh tab-completion not working"
date: 2021-12-10T17:44:49+08:00
menu:
  sidebar:
    name: "Zsh tab-completion not working"
    identifier: shell-zsh-tab-completion-not-working
    weight: 10
tags: ["URL", "SHELL", "ZSH", "Completion"]
categories: ["URL", "SHELL", "ZSH", "Completion"]
hero: images/hero/shell.png
---

- [Zsh tab-completion not working](https://stackoverflow.com/questions/46939906/zsh-tab-completion-not-working)

#### Question

Although I've used Oh-My-Zsh in the past, I decided this time around (i.e. setting up a new computer) I'd try to avoid installing it to keep things a bit leaner. Right now I'm trying to cherry-pick Oh-My-Zsh's insensitive tab-completion feature. Digging around its source repo, I found the following line:
`zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'`

I'm fairly confident this is the line Oh-My-Zsh executes to do what I want, so I tried adding it to my `.zshrc`. Restarted my terminal. Typed `cd desk`, then hit [tab]. No dice -- I didn't get `cd Desktop/`.

Here's the entire `.zshrc` for reference:

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

#### Answer

Just had to `autoload` and run `compinit`.

Here's the new `.zshrc`:

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
