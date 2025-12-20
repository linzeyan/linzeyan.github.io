---
title: "How to Use which on an Aliased Command"
date: 2022-11-10T16:24:30+08:00
menu:
  sidebar:
    name: "How to Use which on an Aliased Command"
    identifier: linux-which-on-an-aliased-command
    weight: 10
tags: ["URL", "Linux", "SHELL", "command line"]
categories: ["URL", "Linux", "SHELL", "command line"]
hero: images/hero/linux.png
---

- [How to Use which on an Aliased Command](https://www.baeldung.com/linux/which-on-an-aliased-command)

##### type

```bash
type grep
grep is an alias for grep --color=auto


# Bash's type
type -P grep
/usr/bin/grep

# Zsh's type
type -p grep
grep is /usr/bin/grep
```

##### GNU which

```bash
which -a which
which: shell built-in command
/usr/bin/which


alias top10
top10='print -l  ${(o)history%% *} | uniq -c | sort -nr | head -n 10'

alias | /usr/bin/which -i top10
top10='print -l  ${(o)history%% *} | uniq -c | sort -nr | head -n 10'
	/usr/bin/uniq
	/usr/bin/sort
	/usr/bin/head
```
