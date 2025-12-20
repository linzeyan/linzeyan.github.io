---
title: "How to Delete Files With Names That Contain Non-printable Characters"
date: 2022-11-14T13:55:17+08:00
menu:
  sidebar:
    name: "How to Delete Files With Names That Contain Non-printable Characters"
    identifier: linux-delete-files-non-printable-characters
    weight: 10
tags: ["URL", "Linux", "SHELL", "command line"]
categories: ["URL", "Linux", "SHELL", "command line"]
hero: images/hero/linux.png
---

- [How to Delete Files With Names That Contain Non-printable Characters](https://www.baeldung.com/linux/delete-files-non-printable-characters)

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

##### Using ANSI-C Quoting

```bash
# Using ANSI-C Quoting
rm ''$'\302\226'
# We can also use the $ special character before enclosing the filename in single quotes
rm $'\356\200\215'

# pass an item's name to rm without using the ANSI-C quoting
rm '\026\033'
rm: cannot remove '\026\033': No such file or directory
```

##### Using Inode Numbers

```bash
ls -li
total 11
...
6517085 -rw-r--r-- 1 ZZ 197121   4 Nov  6 06:18 '␴ω␴␴␣␦'$'\342\220\264'
7826050 -rw-r--r-- 1 ZZ 197121   3 Nov  9 04:23 ''$'\356\200\215\356\200\215\356\200\215'
4685554 -rw-r--r-- 1 ZZ 197121   4 Nov  6 06:27
```

we can delete the desired file by passing its inode number to the -inum switch of the find command

```bash
find . -inum 4685554 -exec rm -i {} \;
rm: remove regular file './                '? y
```

##### Using rm Interactive Option With Bash Globbing

```bash
rm -i *
rm: remove regular file '      '?y
rm: remove regular file '                            '?y
...
```

##### Using the Vim Text Editor

`vim .`
After choosing the target file, we simply use `Shift+D`, type y or yes, and hit the Return key to delete it.
