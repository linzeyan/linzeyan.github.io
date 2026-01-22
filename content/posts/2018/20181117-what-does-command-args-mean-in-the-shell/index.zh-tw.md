---
title: "Shell 中 `< <(command args)` 是什麼意思？"
date: 2018-11-17T22:29:23+08:00
menu:
  sidebar:
    name: "Shell 中 `< <(command args)` 是什麼意思？"
    identifier: shell-what-does-command-args-mean-in-the-shell
    weight: 10
tags: ["Links", "SHELL"]
categories: ["Links", "SHELL"]
hero: images/hero/shell.png
---

- [Shell 中 `< <(command args)` 是什麼意思？](https://stackoverflow.com/questions/2443085/what-does-command-args-mean-in-the-shell)

```bash
    while IFS= read -r -d $'\0' file; do
      dosomethingwith "$file"        # 對每個檔案進行處理
    done < <(find /bar -name *foo* -print0)
```

`<()` 在手冊中稱為 [**process substitution**](http://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html#Process-Substitution)，它類似於管線，但會傳遞 `/dev/fd/63` 這種形式的參數，而不是使用 stdin。

`<` 會從命令列指定的檔案讀取輸入。

這兩個運算子合起來的作用與管線完全相同，因此可以改寫為：

```bash
find /bar -name *foo* -print0 | while read line; do
  ...
done
```
