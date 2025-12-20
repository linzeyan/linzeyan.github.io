---
title: "Tracking SQLite Database Changes in Git"
date: 2024-02-07T19:20:15+08:00
menu:
  sidebar:
    name: "Tracking SQLite Database Changes in Git"
    identifier: git-tracking_sqlite_database_changes_git
    weight: 10
tags: ["URL", "Git"]
categories: ["URL", "Git"]
hero: images/hero/git.png
---

- [Tracking SQLite Database Changes in Git](https://lobste.rs/s/gnv9ho/tracking_sqlite_database_changes_git)
- [Git hook for diff sqlite table](https://stackoverflow.com/a/21789167)

First, add a diff type called "sqlite3" to your config. The simplest way is to just run these commands:

```shell
git config diff.sqlite3.binary true git config diff.sqlite3.textconv "echo .dump | sqlite3"
```

Alternatively, you can add this snippet to your `~/.gitconfig` or `.git/config` in your repository:

```gitconfig
[diff "sqlite3"] binary = true textconv = "echo .dump | sqlite3"
```

Next, create a file called `.gitattributes` if it's not already present and add this line:

```gitattributes
*.sqlite diff=sqlite3
```

> Note that the filename (`*.sqlite`) may differ from your setup. In my case for example, it should match files with `*.gnucash`.

And that's about it! The next time you run `git diff` or any other command that produces a diff on a sqlite file, you'll see a nicely formatted diff of the changes.
