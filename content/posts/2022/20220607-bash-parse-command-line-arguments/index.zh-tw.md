---
title: "在 Bash 中解析命令列參數"
date: 2022-06-07T14:48:47+08:00
menu:
  sidebar:
    name: "在 Bash 中解析命令列參數"
    identifier: linux-bash-parse-command-line-arguments
    weight: 10
tags: ["Links", "Linux", "BASH"]
categories: ["Links", "Linux", "BASH"]
hero: images/hero/linux.png
---

- [在 Bash 中解析命令列參數](https://www.baeldung.com/linux/bash-parse-command-line-arguments)

### getopts

> `getopts optstring opt [arg ...]`

```bash
#!/bin/bash

while getopts 'abc:h' opt; do
  case "$opt" in
    a)
      echo "Processing option 'a'"
      ;;

    b)
      echo "Processing option 'b'"
      ;;

    c)
      arg="$OPTARG"
      echo "Processing option 'c' with '${OPTARG}' argument"
      ;;

    ?|h)
      echo "Usage: $(basename $0) [-a] [-b] [-c arg]"
      exit 1
      ;;
  esac
done
shift "$(( $OPTIND -1 ))"
```

- optstring 代表支援的選項。若某個選項需要參數，則在它後面加冒號 (:)。例如選項 c 需要參數，會寫成 c:
- 當選項有關聯參數時，getopts 會將參數字串存到 OPTARG shell 變數中。例如 option c 的參數會存到 OPTARG。
- opt 包含已解析的選項。

```bash
#!/bin/bash

while getopts ':abc:h' opt; do
  case "$opt" in
    a)
      echo "Processing option 'a'"
      ;;

    b)
      echo "Processing option 'b'"
      ;;

    c)
      arg="$OPTARG"
      echo "Processing option 'c' with '${OPTARG}' argument"
      ;;

    h)
      echo "Usage: $(basename $0) [-a] [-b] [-c arg]"
      exit 0
      ;;

    :)
      echo -e "option requires an argument.\nUsage: $(basename $0) [-a] [-b] [-c arg]"
      exit 1
      ;;

    ?)
      echo -e "Invalid command option.\nUsage: $(basename $0) [-a] [-b] [-c arg]"
      exit 1
      ;;
  esac
done
shift "$(( $OPTIND -1 ))"
```

- 注意我們也更新了 optstring，現在以冒號 (:) 開頭，會抑制預設的錯誤訊息。
- 當 OPTERR 變數設為 0 時，getopts 會停用錯誤訊息輸出。

### 使用 getopt 解析長選項

```bash
#!/bin/bash

VALID_ARGS=$(getopt -o abg:d: --long alpha,beta,gamma:,delta: -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -a | --alpha)
        echo "Processing 'alpha' option"
        shift
        ;;
    -b | --beta)
        echo "Processing 'beta' option"
        shift
        ;;
    -g | --gamma)
        echo "Processing 'gamma' option. Input argument is '$2'"
        shift 2
        ;;
    -d | --delta)
        echo "Processing 'delta' option. Input argument is '$2'"
        shift 2
        ;;
    --) shift;
        break
        ;;
  esac
done
```

- `-o` 選項代表短選項
- `--long` 選項代表長選項
