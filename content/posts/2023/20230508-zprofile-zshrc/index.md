---
title: "Zsh Config Files and Priority"
date: 2023-05-08T10:43:10+08:00
menu:
  sidebar:
    name: "Zsh Config Files and Priority"
    identifier: zsh-environment-files-priority
    weight: 10
tags: ["Links", "ZSH"]
categories: ["Links", "ZSH"]
---

- [Zsh Config Files and Priority](https://einverne.github.io/post/2023/01/zprofile-zshrc.html)

### Zsh environment variable config files:

- .zprofile
- .zlogin
- .zshrc
- .zshenv
- .zlogout

.zshrc is used for overall shell customization

- .zprofile and .zlogin are similar. They both set environment variables for login shells, but their load timing differs. .zprofile is based on Bash's .bash_profile, while .zlogin is the CSH-style .login legacy name.
- .zshrc sets environment variables for interactive shells. It loads after .zprofile. Typically used for $PATH, $PROMPT, aliases, functions, etc.
- .zshenv is always read, so you can set environment variables like $PATH or $EDITOR there, but it is generally not used.
- .zlogout is loaded when a session logs out, which is good for cleanup, such as resetting terminal titles.

Zsh loads ~/.zprofile at login (login shell).

Zsh loads ~/.zshrc when opening a new terminal session.

### Note the load order:

It loads /etc/zshenv first, then the config files in HOME:

`.zshenv → [.zprofile if login] → [.zshrc if interactive] → [.zlogin if login] → [.zlogout].`
