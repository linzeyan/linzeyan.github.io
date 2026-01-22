---
title: "撰寫 Bash 腳本的最佳實務"
date: 2021-12-06T11:11:54+08:00
menu:
  sidebar:
    name: "撰寫 Bash 腳本的最佳實務"
    identifier: shell-bash-best-practices
    weight: 10
tags: ["Links", "SHELL", "BASH"]
categories: ["Links", "SHELL", "BASH"]
hero: images/hero/shell.png
---

- [撰寫 Bash 腳本的最佳實務](https://kvz.io/bash-best-practices.html)
- [Shell 腳本撰寫最佳實務](https://www.javacodegeeks.com/2013/10/shell-scripting-best-practices.html)

```bash
#!/usr/bin/env bash
# Bash3 Boilerplate. Copyright (c) 2014, kvz.io
set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename ${__file} .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)" # <-- change this as it depends on your app

arg1="${1:-}"
```

##### 使用 shift 讀取函式參數

> 這樣在日後需要調整參數順序時會更容易。

```bash
# Processes a file.
# $1 - the name of the input file
# $2 - the name of the output file
process_file(){
    local -r input_file="$1";  shift
    local -r output_file="$1"; shift
}
```

##### 宣告你的變數

> 若可攜性是重點，請用 `typeset` 取代 `declare`。

```bash
declare -r -i port_number=8080
declare -r -a my_array=( apple orange )

my_function() {
    local -r name=apple
}
```

##### 為所有參數展開加上引號

##### 適當使用陣列

```bash
# using a string to hold a collection
declare -r hosts="host1 host2 host3"
for host in $hosts  # not quoting $hosts here, since we want word splitting
do
    echo "$host"
done

# use an array instead!
declare -r -a host_array=( host1 host2 host3 )
for host in "${host_array[@]}"
do
    echo "$host"
done
```

##### 使用 "$@" 代表所有參數

> 不要使用 `$*`。

```bash
main() {
    # print each argument
    for i in "$@"
    do
        echo "$i"
    done
}
# pass all arguments to main
main "$@"
```

##### 環境變數才使用大寫變數名稱

##### 優先使用 shell 內建而非外部程式

```bash
declare -r my_file="/var/tmp/blah"

# instead of dirname, use:
declare -r file_dir="{my_file%/*}"

# instead of basename, use:
declare -r file_base="{my_file##*/}"

# instead of sed 's/blah/hello', use:
declare -r new_file="${my_file/blah/hello}"

# instead of bc <<< "2+2", use:
echo $(( 2+2 ))

# instead of grepping a pattern in a string, use:
[[ $line =~ .*blah$ ]]

# instead of cut -d:, use an array:
IFS=: read -a arr <<< "one:two:three"
```

##### 避免不必要的管線

**避免不必要的 `cat`**

```bash
# instead of
cat file | command
# use
command < file
```

**避免不必要的 `echo`**

```bash
# instead of
echo text | command
# use
command <<< text

# for portability, use a heredoc
command << END
text
END
```

**避免不必要的 `grep`**

```bash
# instead of
grep pattern file | awk '{print $1}'
# use
awk '/pattern/{print $1}'

# instead of
grep pattern file | sed 's/foo/bar/g'
# use
sed -n '/pattern/{s/foo/bar/p}' file
```

##### 避免解析 ls

> 請不要使用 `ls`，改用檔名展開或能輸出以 NUL 分隔的替代命令，例如 `find -print0`。

##### 使用檔名展開

> 在 bash 中，你可以透過 `extglob` shell 選項啟用延伸的樣式比對運算子，讓檔名展開更強大。
>
> 另外，啟用 `nullglob`，讓找不到匹配時回傳空清單。

```bash
shopt -s nullglob
shopt -s extglob

# get all files with a .yyyymmdd.txt suffix
declare -a dated_files=( *.[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].txt )

# get all non-zip files
declare -a non_zip_files=( !(*.zip) )
```

##### 儘量使用 NUL 分隔輸出

> 為了正確處理包含空白與換行的檔名，應使用以 NUL 分隔的輸出，也就是每行以 `NUL` (`00`) 字元結尾，而不是換行。多數程式都支援這種方式。例如，`find -print0` 會輸出以 NUL 分隔的檔名，`xargs -0` 則會以 NUL 作為分隔符號來讀取參數。

```bash
# instead of
find . -type f -mtime +5 | xargs rm -f
# use
find . -type f -mtime +5 -print0 | xargs -0 rm -f

# looping over files
find . -type f -print0 | while IFS= read -r -d $'' filename; do
    echo "$filename"
done
```

##### 不要使用反引號

##### 使用行程替換代替建立暫存檔

```bash
# using temp files
command1 > file1
command2 > file2
diff file1 file2
rm file1 file2

# using process substitution
diff <(command1) <(command2)
```

##### 若必須建立暫存檔，請使用 mktemp

##### 在判斷式中使用 [[ 與 ((

##### 在判斷式中直接使用指令，而非用退出狀態

```bash
# don't use exit status
grep -q pattern file
if (( $? == 0 ))
then
    echo "pattern was found"
fi

# use the command as the condition
if grep -q pattern file
then
    echo "pattern was found"
fi
```

##### 使用 set -e

##### 將錯誤訊息輸出到 stderr

```bash
echo "An error message" >&2
```
