---
title: "How to Make Output Overwrite the Same Line in a Terminal"
date: 2022-10-21T17:29:10+08:00
menu:
  sidebar:
    name: "How to Make Output Overwrite the Same Line in a Terminal"
    identifier: linux-shell-echo-printf-overwrite-terminal-line
    weight: 10
tags: ["URL", "SHELL", "Linux"]
categories: ["URL", "SHELL", "Linux"]
hero: images/hero/linux.png
---

- [How to Make Output Overwrite the Same Line in a Terminal](https://www.baeldung.com/linux/echo-printf-overwrite-terminal-line)

##### Introduction to the Problem

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

##### The "Magic Code": `\033[0K\r`

- `-n` option asks the echo command to stop outputting the trailing newline character
- `-e` option allows the echo command to interpret backslash escapes such as `\n` (newline) and `\r` (carriage return)
- `\033` - It's the escape sequence. In other words, it's ESC.
- `\033[` - Then this becomes "ESC [", which is the control sequence introducer (CSI).
- `\033[0k` - So it's "CSI 0 K". Further, "CSI 0 K" erases the text from the cursor to the end of the line.
- `\r` - This is the carriage return. It brings the cursor to the beginning of the line.

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
