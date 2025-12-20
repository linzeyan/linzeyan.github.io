---
title: "What does `< <(command args)` mean in the shell?"
date: 2018-11-17T22:29:23+08:00
menu:
  sidebar:
    name: "What does `< <(command args)` mean in the shell?"
    identifier: shell-what-does-command-args-mean-in-the-shell
    weight: 10
tags: ["URL", "SHELL"]
categories: ["URL", "SHELL"]
hero: images/hero/shell.png
---

- [What does `< <(command args)` mean in the shell?](https://stackoverflow.com/questions/2443085/what-does-command-args-mean-in-the-shell)

```bash
    while IFS= read -r -d $'\0' file; do
      dosomethingwith "$file"        # do something with each file
    done < <(find /bar -name *foo* -print0)
```

`<()` is called [**process substitution**](http://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html#Process-Substitution) in the manual, and is similar to a pipe but passes an argument of the form `/dev/fd/63` instead of using stdin.

`<` reads the input from a file named on command line.

Together, these two operators function exactly like a pipe, so it could be rewritten as

```bash
find /bar -name *foo* -print0 | while read line; do
  ...
done
```
