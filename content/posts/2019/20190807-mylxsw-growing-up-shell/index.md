---
title: "Shell Script Study Notes"
date: 2019-08-07T15:14:08+08:00
menu:
  sidebar:
    name: "Shell Script Study Notes"
    identifier: shell-scripting-notes-mylxsw-growing-up
    weight: 10
tags: ["Links", "SHELL"]
categories: ["Links", "SHELL"]
hero: images/hero/shell.png
---

- [Shell Script Study Notes](https://github.com/mylxsw/growing-up/blob/master/doc/Shell%E8%84%9A%E6%9C%AC%E5%AD%A6%E4%B9%A0%E7%AC%94%E8%AE%B0.md)

### Arithmetic operations

    val=`expr $a + $b`

### Operators

| Symbol | Description                                   | Example                    |
| ------ | --------------------------------------------- | -------------------------- |
| !      | NOT                                           | [ ! false ]                |
| -o     | OR                                            | [ $a -lt 20 -o $b -gt 20 ] |
| -a     | AND                                           | [ $a -lt 20 -a $b -gt 20 ] |
| =      | equality check                                | [ $a = $b ]                |
| !=     | inequality check                              | [ $a != $b ]               |
| -z     | string length is 0, returns true if 0         | [ -z $a ]                  |
| -n     | string length is not 0, returns true if not 0 | [ -n $a ]                  |
| str    | check whether string is empty, true if not    | [ $a ]                     |
| -b     | check whether file is a block device          | [ -b $file ]               |
| -c     | check whether file is a character device      | ..                         |
| -d     | check whether file is a directory             | [ -d $file ]               |
| -f     | check whether file is a regular file          | [ -f $file ]               |
| -r     | check whether file is readable                | ..                         |
| -w     | check whether file is writable                | ..                         |
| -x     | check whether file is executable              | ..                         |
| -s     | check whether file is empty                   | ..                         |
| -e     | check whether file exists                     | ..                         |

### Special variables

| Variable | Meaning                                                                 |
| -------- | ----------------------------------------------------------------------- |
| $0       | file name of the current script                                         |
| $n       | arguments passed to a script or function; n is the position             |
| $#       | number of arguments passed to a script or function                      |
| $\*      | all arguments as a single word, e.g., "1 2 3"                           |
| $@       | all arguments as separate words, e.g., "1" "2" "3"                  |
| $?       | exit status of the last command or return value of a function           |
| $$       | current shell process ID; for scripts, the PID of the script process    |

### POSIX program exit statuses

| Code    | Meaning                                                                 |
| ------- | ----------------------------------------------------------------------- |
| 0       | command exited successfully                                             |
| > 0     | failure during redirection or word expansion (~, variables, commands, arithmetic, and word splitting) |
| 1 - 125 | command exited unsuccessfully; specific meanings are command-defined    |
| 126     | command found but file is not executable                                |
| 127     | command not found                                                      |
| > 128   | command died from a signal                                              |

### Input/output redirection

| Command           | Description                                               |
| ----------------- | --------------------------------------------------------- |
| command > file    | redirect output to file                                   |
| command > file    | redirect output to file by appending                      |
| n > file          | redirect file descriptor n to file                        |
| n >> file         | redirect file descriptor n to file by appending           |
| n >& m            | merge output file m and n                                 |
| n <& m            | merge input file m and n                                  |
| << tag            | use content between start tag and end tag as input        |

### File include

Use `.` or `source` to include files.

    . filename
    source filename

> Included files do not need execute permissions.

### Using functions

Basic function structure

    # Use the function name directly; optionally prefix with function
    function_name(){

        # Use $#,$*,$@ and $0-$n to get the function name and other parameters
        val="$1"

        # Optional return value (must be an integer status code)
        # To return results, use global variables
        return $val
    }

Function invocation

    # Call the function name directly, space-separated arguments are allowed
    function_name 1 2 3 4
    # Use $? to get the return value
    ret=$?

## Common snippets

### List all files in a directory

The code below lists all xlsx files in the downloads directory. Note that to list all files, use `"$watch_dir"/*`.

    watch_dir="/Users/mylxsw/Downloads"
    # Avoid returning a * when there is no match
    shopt -s nullglob
    for file in "$watch_dir"/*.xlsx
    do
        echo $file
    done

    for file in "$watch_dir"/*/    # List all directories
    do
        echo $file
    done

> See [How to get the list of files in a directory in a shell script?](http://stackoverflow.com/questions/2437452/how-to-get-the-list-of-files-in-a-directory-in-a-shell-script) and [Bash Shell Loop Over Set of Files](http://www.cyberciti.biz/faq/bash-loop-over-file/)

### Read lines from stdin

    while read line
    do
        if [ $line != 'EOF' ]
        then
            echo $line
        fi
    done

### Date and time

#### Get current date

    # Output: 20161023
    echo $(date +%Y%m%d)

#### Time comparison

Convert to UNIX timestamps, then compare directly.

    time1=`date +%s`
    time2=`date -d '2016-10-25 17:20:13' +%s`

    if [ $time1 -gt $time2 ]; then
        echo "time1 > time2"
    else
        echo "time1 < time2"
    fi
