---
title: 設定多個 GitHub 帳號的 SSH 金鑰
date: 2025-02-11T15:06:00+08:00
menu:
  sidebar:
    name: 設定多個 GitHub 帳號的 SSH 金鑰
    identifier: configure-ssh-keys-for-multiple-github-accounts
    weight: 10
tags: ["Links", "command line", "SSH", "Github"]
categories: ["Links", "command line", "SSH", "Github"]
hero: images/hero/github.png
---

- [設定多個 GitHub 帳號的 SSH 金鑰](https://stevenharman.net/configure-ssh-keys-for-multiple-github-accounts)

### 使用不同的 Host 值

```bash
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_fry_ed25519

Host github-plnx
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_fry_plnx_ed25519
```

```bash
# Instead of the actual URL
$ git clone git@github.com:planet-express/delivery_service.git

# Substitue in our custom Host value for the `github.com` part
$ git clone git@github-plnx:planet-express/delivery_service.git
```

### 自動替換 Host

```bash
[include]
  path = ~/.gitconfig_custom
```

```bash
# See custom `Host github-plnx` in ~/.ssh/config
[url "github-plnx:planet-express"]
  insteadOf = git@github.com:planet-express
```
