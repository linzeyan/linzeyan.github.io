---
title: "How to use a here documents to write data to a file in bash script"
date: 2021-05-07T11:37:35+08:00
menu:
  sidebar:
    name: "How to use a here documents to write data to a file in bash script"
    identifier: shell-using-heredoc-rediection-in-bash-shell-script-to-write-to-file
    weight: 10
tags: ["URL", "SHELL"]
categories: ["URL", "SHELL"]
hero: images/hero/shell.png
---

- [How to use a here documents to write data to a file in bash script](https://www.cyberciti.biz/faq/using-heredoc-rediection-in-bash-shell-script-to-write-to-file/)

#### allow here-documents within shell scripts to be indented in a natural fashion using `EOF<<-`

```bash
command <<-EOF
  msg1
  msg2
 $var on line
EOF
```

#### Disabling pathname/parameter/variable expansion, command substitution, arithmetic expansion with `'EOF'`

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
