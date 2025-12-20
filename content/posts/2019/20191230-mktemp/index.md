---
title: "Bash 脚本如何创建临时文件：mktemp 命令和 trap 命令教程"
date: 2019-12-30T14:31:45+08:00
menu:
  sidebar:
    name: "Bash 脚本如何创建临时文件：mktemp 命令和 trap 命令教程"
    identifier: shell-script-mktemp-and-trap-command
    weight: 10
tags: ["URL", "SHELL"]
categories: ["URL", "SHELL"]
hero: images/hero/shell.png
---

- [Bash 脚本如何创建临时文件：mktemp 命令和 trap 命令教程](http://www.ruanyifeng.com/blog/2019/12/mktemp.html)

#### `mktemp` 命令

- 生成的临时文件名是随机的，而且权限是只有用户本人可读写
- 为了确保临时文件创建成功，`mktemp` 命令后面最好使用 OR 运算符（`||`），指定创建失败时退出脚本
- 为了保证脚本退出时临时文件被删除，可以使用`trap`命令指定退出时的清除操作

```bash
#!/bin/bash

trap 'rm -f "$TMPFILE"' EXIT

TMPFILE=$(mktemp) || exit 1
echo "Our temp file is $TMPFILE"
```

##### mktemp 命令的参数

- `-d` 参数可以创建一个临时目录
- `-p` 参数可以指定临时文件所在的目录。默认是使用 `$TMPDIR` 环境变量指定的目录，如果这个变量没设置，那么使用 `/tmp` 目录。
- `-t` 参数可以指定临时文件的文件名模板，模板的末尾必须至少包含三个连续的 `X` 字符，表示随机字符，建议至少使用六个 `X`。默认的文件名模板是 `tmp.后接十个随机字符`

#### `trap` 命令的用法

trap 命令用来在 Bash 脚本中响应系统信号。

最常见的系统信号就是 SIGINT（中断），即按 Ctrl + C 所产生的信号。trap 命令的-l 参数，可以列出所有的系统信号。

```shell
$ trap -l
 1) SIGHUP   2) SIGINT   3) SIGQUIT
 4) SIGILL   5) SIGTRAP  6) SIGABRT
 ... ...
```

trap 的命令格式如下。

```shell
$ trap [动作] [信号]
```

动作是一个 Bash 命令

信号:

- HUP：编号 1，脚本与所在的终端脱离联系。
- INT：编号 2，用户按下 Ctrl + C，意图让脚本中止运行。
- QUIT：编号 3，用户按下 Ctrl + 斜杠，意图退出脚本。
- KILL：编号 9，该信号用于杀死进程。
- TERM：编号 15，这是 kill 命令发出的默认信号。
- EXIT：编号 0，这不是系统信号，而是 Bash 脚本特有的信号，不管什么情况，只要退出脚本就会产生。

注意，trap 命令必须放在脚本的开头。否则，它上方的任何命令导致脚本退出，都不会被它捕获。
