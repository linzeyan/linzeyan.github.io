---
title: "在 bash 腳本中使用 here-doc 將資料寫入檔案"
date: 2021-05-07T11:37:35+08:00
menu:
  sidebar:
    name: "在 bash 腳本中使用 here-doc 將資料寫入檔案"
    identifier: shell-using-heredoc-rediection-in-bash-shell-script-to-write-to-file
    weight: 10
tags: ["Links", "SHELL"]
categories: ["Links", "SHELL"]
hero: images/hero/shell.png
---

- [在 bash 腳本中使用 here-doc 將資料寫入檔案](https://www.cyberciti.biz/faq/using-heredoc-rediection-in-bash-shell-script-to-write-to-file/)

#### 使用 `EOF<<-` 讓 here-doc 在 shell 腳本中可自然縮排

```bash
command <<-EOF
  msg1
  msg2
 $var on line
EOF
```

#### 使用 `'EOF'` 停用路徑/參數/變數展開、命令替換與算術展開

```bash
#!/bin/bash
OUT=/tmp/output.txt

echo "Starting my script..."
echo "Doing something..."
# No parameter and variable expansion, command substitution, arithmetic expansion, or pathname expansion is performed on word.
# If any part of word is quoted, the delimiter  is  the  result  of  quote removal  on word, and the lines in the here-document
# are not expanded. So EOF is quoted as follows
cat <<'EOF' >$OUT
  Status of backup as on $(date)
  Backing up files $HOME and /etc/
EOF

echo "Starting backup using rsync..."
```
