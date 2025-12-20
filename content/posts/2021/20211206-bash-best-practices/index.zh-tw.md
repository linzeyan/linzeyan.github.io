---
title: "Best Practices for Writing Bash Scripts"
date: 2021-12-06T11:11:54+08:00
menu:
  sidebar:
    name: "Best Practices for Writing Bash Scripts"
    identifier: shell-bash-best-practices
    weight: 10
tags: ["URL", "SHELL", "BASH"]
categories: ["URL", "SHELL", "BASH"]
hero: images/hero/shell.png
---

- [Best Practices for Writing Bash Scripts](https://kvz.io/bash-best-practices.html)
- [Shell Scripting - Best Practices](https://www.javacodegeeks.com/2013/10/shell-scripting-best-practices.html)

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

##### Use shift to read function arguments

> This makes it easier to reorder arguments, if you change your mind later.

```bash
# Processes a file.
# $1 - the name of the input file
# $2 - the name of the output file
process_file(){
    local -r input_file="$1";  shift
    local -r output_file="$1"; shift
}
```

##### Declare your variables

> If portability is a concern, use `typeset` instead of `declare`.

```bash
declare -r -i port_number=8080
declare -r -a my_array=( apple orange )

my_function() {
    local -r name=apple
}
```

##### Quote all parameter expansions

##### Use arrays where appropriate

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

##### Use "$@" to refer to all arguments

> Don't use `$*`.

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

##### Use uppercase variable names for environment variables only

##### Prefer shell builtins over external programs

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

##### Avoid unnecessary pipelines

**Avoid unnecessary `cat`**

```bash
# instead of
cat file | command
# use
command < file
```

**Avoid unnecessary `echo`**

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

**Avoid unnecessary `grep`**

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

##### Avoid parsing ls

> Instead of `ls`, use file globbing or an alternative command which outputs null terminated filenames, such as `find -print0`.

##### Use globbing

> In bash, you can make globbing more powerful by enabling extended pattern matching operators using the `extglob` shell option.
>
> Also, enable `nullglob` so that you get an empty list if no matches are found.

```bash
shopt -s nullglob
shopt -s extglob

# get all files with a .yyyymmdd.txt suffix
declare -a dated_files=( *.[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].txt )

# get all non-zip files
declare -a non_zip_files=( !(*.zip) )
```

##### Use null delimited output where possible

> In order to correctly handle filenames containing whitespace and newline characters, you should use null delimited output, which results in each line being terminated by a `NUL` (`00`) character instead of a newline. Most programs support this. For example, `find -print0` outputs filenames followed by a null character and `xargs -0` reads arguments separated by null characters.

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

##### Don't use backticks

##### Use process substitution instead of creating temporary files

```bash
# using temp files
command1 > file1
command2 > file2
diff file1 file2
rm file1 file2

# using process substitution
diff <(command1) <(command2)
```

##### Use mktemp if you have to create temporary files

##### Use [[ and (( for test conditions

##### Use commands in test conditions instead of exit status

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

##### Use set -e

##### Write error messages to stderr

```bash
echo "An error message" >&2
```
