---
title: "Bash 腳本如何建立臨時檔案：mktemp 與 trap 教學"
date: 2019-12-30T14:31:45+08:00
menu:
  sidebar:
    name: "Bash 腳本如何建立臨時檔案：mktemp 與 trap 教學"
    identifier: shell-script-mktemp-and-trap-command
    weight: 10
tags: ["Links", "SHELL"]
categories: ["Links", "SHELL"]
hero: images/hero/shell.png
---

- [Bash 腳本如何建立臨時檔案：mktemp 與 trap 教學](http://www.ruanyifeng.com/blog/2019/12/mktemp.html)

#### `mktemp` 命令

- 產生的臨時檔案名稱是隨機的，而且權限只有使用者本人可讀寫。
- 為了確保臨時檔案建立成功，`mktemp` 後面最好使用 OR 運算子（`||`），在建立失敗時退出腳本。
- 為了確保腳本退出時刪除臨時檔案，可以使用 `trap` 指定退出時的清理動作。

```bash
#!/bin/bash

trap 'rm -f "$TMPFILE"' EXIT

TMPFILE=$(mktemp) || exit 1
echo "Our temp file is $TMPFILE"
```

##### mktemp 參數

- `-d` 參數可以建立臨時目錄。
- `-p` 參數可以指定臨時檔案所在的目錄。預設使用 `$TMPDIR` 環境變數指定的目錄；若未設定，使用 `/tmp`。
- `-t` 參數可以指定臨時檔案的檔名模板，模板末尾必須至少包含三個連續的 `X` 字元作為隨機字元，建議至少六個 `X`。預設的檔名模板為 `tmp.` 加上十個隨機字元。

#### `trap` 命令的用法

trap 命令用來在 Bash 腳本中響應系統訊號。

最常見的系統訊號是 SIGINT（中斷），也就是按下 Ctrl + C 產生的訊號。`-l` 參數可以列出所有系統訊號。

```shell
$ trap -l
 1) SIGHUP   2) SIGINT   3) SIGQUIT
 4) SIGILL   5) SIGTRAP  6) SIGABRT
 ... ...
```

trap 的命令格式如下：

```shell
$ trap [動作] [訊號]
```

動作是一個 Bash 命令。

訊號：

- HUP：編號 1，腳本與終端機脫離連線。
- INT：編號 2，使用者按下 Ctrl + C，想中止腳本。
- QUIT：編號 3，使用者按下 Ctrl + 斜線，想退出腳本。
- KILL：編號 9，用於殺死行程。
- TERM：編號 15，kill 命令發出的預設訊號。
- EXIT：編號 0，不是系統訊號，而是 Bash 腳本特有的訊號，腳本退出就會產生。

注意：trap 命令必須放在腳本開頭。否則它上方的任何命令導致腳本退出，都不會被它捕獲。
