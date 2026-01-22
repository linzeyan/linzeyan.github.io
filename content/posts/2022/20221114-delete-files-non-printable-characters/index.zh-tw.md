---
title: "如何刪除檔名含有不可列印字元的檔案"
date: 2022-11-14T13:55:17+08:00
menu:
  sidebar:
    name: "如何刪除檔名含有不可列印字元的檔案"
    identifier: linux-delete-files-non-printable-characters
    weight: 10
tags: ["Links", "Linux", "SHELL", "command line"]
categories: ["Links", "Linux", "SHELL", "command line"]
hero: images/hero/linux.png
---

- [如何刪除檔名含有不可列印字元的檔案](https://www.baeldung.com/linux/delete-files-non-printable-characters)

```bash
ls -l
total 13
-rw-r--r-- 1 ZZ 197121   4 Nov  6 07:08 '      '
-rw-r--r-- 1 ZZ 197121 162 Apr 16  2022 '~$iscord.docx'
-rw-r--r-- 1 ZZ 197121   6 Nov  6 06:03 ''$'\302\226'
-rw-r--r-- 1 ZZ 197121   4 Nov  6 06:01 ''$'\302\226''Λ---ω'
-rw-r--r-- 1 ZZ 197121   4 Nov  6 06:13 '␴?␴??␴??::␴?␴'
-rw-r--r-- 1 ZZ 197121   4 Nov  6 06:12  ␴__␴
-rw-r--r-- 1 ZZ 197121   4 Nov  6 06:14  ␴␴␴␴␴␴␴␴␴␴␴␴␴␴␴␴␴
-rw-r--r-- 1 ZZ 197121   4 Nov  6 06:18 '␴ω␴␴␣␦'$'\342\220\264'
-rw-r--r-- 1 ZZ 197121   4 Nov  6 06:16  ␣␣␣␣␣␣␣␣
-rw-r--r-- 1 ZZ 197121   4 Nov  6 06:26  ␣   μ   μ   Ω  Ω
-rw-r--r-- 1 ZZ 197121  14 Nov  6 06:23 '␣   μ  ␴'$'\342\220\264''Ξ'
-rw-r--r-- 1 ZZ 197121   4 Nov  6 06:27
-rw-r--r-- 1 ZZ 197121   4 Nov  6 06:27

```

##### 使用 ANSI-C Quoting

```bash
# Using ANSI-C Quoting
rm ''$'\302\226'
# We can also use the $ special character before enclosing the filename in single quotes
rm $'\356\200\215'

# pass an item's name to rm without using the ANSI-C quoting
rm '\026\033'
rm: cannot remove '\026\033': No such file or directory
```

##### 使用 Inode 編號

```bash
ls -li
total 11
...
6517085 -rw-r--r-- 1 ZZ 197121   4 Nov  6 06:18 '␴ω␴␴␣␦'$'\342\220\264'
7826050 -rw-r--r-- 1 ZZ 197121   3 Nov  9 04:23 ''$'\356\200\215\356\200\215\356\200\215'
4685554 -rw-r--r-- 1 ZZ 197121   4 Nov  6 06:27
```

可以透過 find 的 -inum 參數指定 inode 來刪除檔案。

```bash
find . -inum 4685554 -exec rm -i {} \;
rm: remove regular file './                '? y
```

##### 搭配 Bash Globbing 使用 rm 互動模式

```bash
rm -i *
rm: remove regular file '      '?y
rm: remove regular file '                            '?y
...
```

##### 使用 Vim 編輯器

`vim .`
選好目標檔案後，使用 `Shift+D`，輸入 y 或 yes，再按 Return 便可刪除。
