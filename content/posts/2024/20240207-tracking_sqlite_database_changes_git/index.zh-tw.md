---
title: "在 Git 中追蹤 SQLite 資料庫變更"
date: 2024-02-07T19:20:15+08:00
menu:
  sidebar:
    name: "在 Git 中追蹤 SQLite 資料庫變更"
    identifier: git-tracking_sqlite_database_changes_git
    weight: 10
tags: ["Links", "Git"]
categories: ["Links", "Git"]
hero: images/hero/git.png
---

- [在 Git 中追蹤 SQLite 資料庫變更](https://lobste.rs/s/gnv9ho/tracking_sqlite_database_changes_git)
- [用於 diff sqlite 資料表的 Git hook](https://stackoverflow.com/a/21789167)

首先，在設定中加入名為 "sqlite3" 的 diff 類型。最簡單的方式是直接執行這些指令：

```shell
git config diff.sqlite3.binary true git config diff.sqlite3.textconv "echo .dump | sqlite3"
```

或者，你也可以把這段加入你的 `~/.gitconfig` 或專案的 `.git/config`：

```gitconfig
[diff "sqlite3"] binary = true textconv = "echo .dump | sqlite3"
```

接著，若尚未存在 `.gitattributes`，就建立它並加入這一行：

```gitattributes
*.sqlite diff=sqlite3
```

> 注意檔名 (`*.sqlite`) 可能會因你的設定而不同。以我的情況為例，它應該要匹配 `*.gnucash`。

大致上就是這樣！下次執行 `git diff` 或任何會對 sqlite 檔案產生 diff 的指令時，你會看到格式化良好的變更差異。
