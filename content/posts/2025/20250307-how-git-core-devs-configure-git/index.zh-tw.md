---
title: How Core Git Developers Configure Git
date: 2025-03-07T15:46:00+08:00
menu:
  sidebar:
    name: How Core Git Developers Configure Git
    identifier: how-git-core-devs-configure-git
    weight: 10
tags: ["URL", "Git"]
categories: ["URL", "Git"]
hero: images/hero/git.png
---

- [How Core Git Developers Configure Git](https://blog.gitbutler.com/how-git-core-devs-configure-git/)

```bash
# clearly makes git better

[column]
        ui = auto
[branch]
        sort = -committerdate
[tag]
        sort = version:refname
[init]
        defaultBranch = main
[diff]
        algorithm = histogram
        colorMoved = plain
        mnemonicPrefix = true
        renames = true
[push]
        default = simple
        autoSetupRemote = true
        followTags = true
[fetch]
        prune = true
        pruneTags = true
        all = true

# why the hell not?

[help]
        autocorrect = prompt
[commit]
        verbose = true
[rerere]
        enabled = true
        autoupdate = true
[core]
        excludesfile = ~/.gitignore
[rebase]
        autoSquash = true
        autoStash = true
        updateRefs = true

# a matter of taste (uncomment if you dare)

[core]
        # fsmonitor = true
        # untrackedCache = true
[merge]
        # (just 'diff3' if git version < 2.3)
        # conflictstyle = zdiff3
[pull]
        # rebase = true
```
