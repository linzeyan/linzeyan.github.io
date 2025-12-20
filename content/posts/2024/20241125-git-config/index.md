---
title: "How I configure my Git identities"
date: 2024-11-25T17:35:35+08:00
menu:
  sidebar:
    name: "How I configure my Git identities"
    identifier: git-how-i-configure-my-git-identities
    weight: 10
tags: ["URL", "Git"]
categories: ["URL", "Git"]
hero: images/hero/git.png
---

- [How I configure my Git identities](https://www.benji.dog/articles/git-config/)

**_includeIf_**

```
[includeIf "gitdir:~/code/**"]
  path = ~/.config/git/personal
[includeIf "gitdir:~/work/**"]
  path = ~/.config/git/work
```

**`hasconfig:remote.*.url:`**

```
[includeIf "hasconfig:remote.*.url:git@github.com:*/**"]
  path = ~/.config/git/config-gh
[includeIf "hasconfig:remote.*.url:git@github.com:orgname/**"]
  path = ~/.config/git/config-gh-org
[includeIf "hasconfig:remote.*.url:git@gitlab.com:*/**"]
  path = ~/.config/git/config-gl
[includeIf "hasconfig:remote.*.url:git@git.sr.ht:*/**"]
  path = ~/.config/git/config-srht
```

**_insteadOf_**

```
[url "gh-work:orgname"]
  insteadOf = git@github.com:orgname
```
