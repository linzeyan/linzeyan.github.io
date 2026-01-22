---
title: "Git 小技巧：用 .mailmap 合併不同作者"
date: 2021-08-05T13:42:14+08:00
menu:
  sidebar:
    name: "Git 小技巧：用 .mailmap 合併不同作者"
    identifier: git-little-git-tricks-use-mailmap-to-merge-different-authors
    weight: 10
tags: ["Links", "Git"]
categories: ["Links", "Git"]
hero: images/hero/git.png
---

- [Git 小技巧：用 .mailmap 合併不同作者](https://improveandrepeat.com/2019/06/little-git-tricks-use-mailmap-to-merge-different-authors/)

`.mailmap` 檔案 ==> `Name you want to keep <email> Name you no longer want <email>`

```
John Doe  John Doe
John Doe  John Doe
John Doe  john doe
Max Example  Max
```

##### 之前

```shell
$ git shortlog -se
     1  John Doe <John@Doe.org>
     1  John Doe <John@doe.org>
     2  John Doe <john@doe.org>
     1  Max <max@test.co.uk>
     3  Max Example <hi@test.com>
     1  john doe <john@doe.org>
```

##### 之後

```shell
$ git shortlog -se
     5  John Doe <john@doe.org>
     4  Max Example <hi@test.com>
```
