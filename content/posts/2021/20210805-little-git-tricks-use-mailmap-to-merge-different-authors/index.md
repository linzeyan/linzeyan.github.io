---
title: "Little Git Tricks: Use .mailmap to Merge Different Authors"
date: 2021-08-05T13:42:14+08:00
menu:
  sidebar:
    name: "Little Git Tricks: Use .mailmap to Merge Different Authors"
    identifier: git-little-git-tricks-use-mailmap-to-merge-different-authors
    weight: 10
tags: ["URL", "Git"]
categories: ["URL", "Git"]
hero: images/hero/git.png
---

- [Little Git Tricks: Use .mailmap to Merge Different Authors](https://improveandrepeat.com/2019/06/little-git-tricks-use-mailmap-to-merge-different-authors/)

`.mailmap` file ==> `Name you want to keep <email> Name you no longer want <email>`

```
John Doe  John Doe
John Doe  John Doe
John Doe  john doe
Max Example  Max
```

##### before

```shell
$ git shortlog -se
     1  John Doe <John@Doe.org>
     1  John Doe <John@doe.org>
     2  John Doe <john@doe.org>
     1  Max <max@test.co.uk>
     3  Max Example <hi@test.com>
     1  john doe <john@doe.org>
```

##### after

```shell
$ git shortlog -se
     5  John Doe <john@doe.org>
     4  Max Example <hi@test.com>
```
