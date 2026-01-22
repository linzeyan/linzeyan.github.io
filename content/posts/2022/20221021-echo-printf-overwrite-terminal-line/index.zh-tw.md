---
title: "如何讓終端輸出覆蓋同一行"
date: 2022-10-21T17:29:10+08:00
menu:
  sidebar:
    name: "如何讓終端輸出覆蓋同一行"
    identifier: linux-shell-echo-printf-overwrite-terminal-line
    weight: 10
tags: ["Links", "SHELL", "Linux"]
categories: ["Links", "SHELL", "Linux"]
hero: images/hero/linux.png
---

- [如何讓終端輸出覆蓋同一行](https://www.baeldung.com/linux/echo-printf-overwrite-terminal-line)

##### 問題簡介

```bash
$ cat print_status.sh
!/bin/bash
echo "[INFO] Processing file: readme.txt"
sleep 2  To simulate the file processing

echo "[INFO] Processing file: veryPowerfulService.service"
sleep 2

echo "[INFO] Processing file: log.txt"
echo "DONE"


$ ./print_status.sh
[INFO] Processing file: readme.txt
[INFO] Processing file: veryPowerfulService.service
[INFO] Processing file: log.txt
DONE
```

##### 「魔法碼」: `\033[0K\r`

- `-n` 讓 echo 不輸出結尾的換行字元
- `-e` 讓 echo 解讀反斜線逸出字元，例如 `\n`（換行）與 `\r`（回車）
- `\033` - 逸出序列，也就是 ESC
- `\033[` - 變成 "ESC ["，也就是控制序列引導字元（CSI）
- `\033[0k` - 即 "CSI 0 K"，會清除從游標到行尾的文字
- `\r` - 回車，將游標移回行首

```bash
$ cat print_status.sh
#!/bin/bash
echo -ne "[INFO] Processing file: readme.txt\033[0K\r"
sleep 2

echo -ne "[INFO] Processing file: veryPowerfulService.service\033[0K\r"
sleep 2

echo -e "[INFO] Processing file: log.txt\033[0K\r"
echo "DONE"
```

```bash
!/bin/bash
printf "[INFO] Processing file: readme.txt\033[0K\r"
sleep 2

printf "[INFO] Processing file: veryPowerfulService.service\033[0K\r"
sleep 2

printf "[INFO] Processing file: log.txt\033[0K\r\n"
echo "DONE"
```
