---
title: Configuring SSH Keys for Multiple GitHub Accounts
date: 2025-02-11T15:06:00+08:00
menu:
  sidebar:
    name: Configuring SSH Keys for Multiple GitHub Accounts
    identifier: configure-ssh-keys-for-multiple-github-accounts
    weight: 10
tags: ["URL", "command line", "ssh", "Github"]
categories: ["URL", "command line", "ssh", "Github"]
---

[Configuring SSH Keys for Multiple GitHub Accounts](https://stevenharman.net/configure-ssh-keys-for-multiple-github-accounts)

### Use Different Host values
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

### Automate Substituting the Host
```bash
[include]
  path = ~/.gitconfig_custom
```

```bash
# See custom `Host github-plnx` in ~/.ssh/config
[url "github-plnx:planet-express"]
  insteadOf = git@github.com:planet-express
```