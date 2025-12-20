---
title: "Parse Command Line Arguments in Bash"
date: 2022-06-07T14:48:47+08:00
menu:
  sidebar:
    name: "Parse Command Line Arguments in Bash"
    identifier: linux-bash-parse-command-line-arguments
    weight: 10
tags: ["URL", "Linux", "BASH"]
categories: ["URL", "Linux", "BASH"]
hero: images/hero/linux.png
---

- [Parse Command Line Arguments in Bash](https://www.baeldung.com/linux/bash-parse-command-line-arguments)

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
shift "$(($OPTIND -1))"
```

- optstring represents the supported options. The option expects an argument if there is a colon (:) after it. For instance, if option c expects an argument, then it would be represented as c: in the optstring
- When an option has an associated argument, then getopts stores the argument as a string in the OPTARG shell variable. For instance, the argument passed to option c would be stored in the OPTARG variable.
- opt contains the parsed option.

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
shift "$(($OPTIND -1))"
```

- Note that we've updated optstring as well. Now it starts with the colon(:) character, which suppresses the default error message.
- The getopts function disables error reporting when the OPTERR variable is set to zero.

### Parsing Long Command-Line Options With getopt

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

- `-o` option represents the short command-line options
- `--long` option represents the long command-line options
