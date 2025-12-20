---
title: "我就感觉到快 —— zsh 和 oh my zsh 冷启动速度优化"
date: 2021-07-15T18:19:06+08:00
menu:
  sidebar:
    name: "我就感觉到快 —— zsh 和 oh my zsh 冷启动速度优化"
    identifier: terminal-zsh-make-oh-my-zsh-fly
    weight: 10
tags: ["URL", "Zsh"]
categories: ["URL", "Zsh"]
---

- [我就感觉到快 —— zsh 和 oh my zsh 冷启动速度优化](https://blog.skk.moe/post/make-oh-my-zsh-fly/)

#### Profiling

```shell
# .zshrc
zmodload zsh/zprof

```

```bash
$ /bin/zsh
$ zprof

num  calls                time                       self            name
-----------------------------------------------------------------------------------
 1)    1         395.66   395.66   33.10%    395.59   395.59   33.09%  _zsh_nvm_auto_use
 2)    1         216.22   216.22   18.09%    216.13   216.13   18.08%  nvm_die_on_prefix
 3)    1         648.00   648.00   54.20%    168.85   168.85   14.12%  nvm_auto
 4)    2         479.15   239.57   40.08%    160.50    80.25   13.43%  nvm
 5)    1         102.30   102.30    8.56%     84.99    84.99    7.11%  nvm_ensure_version_installed
 6)    2          51.21    25.60    4.28%     29.55    14.78    2.47%  compinit
 7)    1         680.18   680.18   56.89%     22.17    22.17    1.85%  _zsh_nvm_load
 8)    2          21.66    10.83    1.81%     21.66    10.83    1.81%  compaudit
 9)    1          17.31    17.31    1.45%     17.31    17.31    1.45%  nvm_is_version_installed
10)  193          17.43     0.09    1.46%     14.50     0.08    1.21%  _zsh_autosuggest_bind_widget
[Redacted]
```

`zprof` 模块只能获取每个 zsh 函数的用时，因此适合找出拖累 zsh 冷启动的 oh my zsh 的插件。如果要获取完整的 `.zshrc` 性能分析，应该使用 `xtrace`。在 `.zshrc` 开头添加如下命令

```bash
# .zshrc
zmodload zsh/datetime
setopt PROMPT_SUBST
PS4='+$EPOCHREALTIME %N:%i> '

logfile=$(mktemp zsh_profile.7Pw1Ny0G)
echo "Logging to $logfile"
exec 3>&2 2>$logfile

setopt XTRACE

# ...
# 并在 .zshrc 结尾添加如下命令
unsetopt XTRACE
exec 2>&3 3>&-
```

这会在 $HOME 目录下生成一个文件名包含随机字符串的文件（`zsh_profile.123456` ）。一些介绍 zsh profiling 的文章会推荐使用 [kcachegrind](http://kcachegrind.sourceforge.net/html/Home.html) 这个工具可视化这个文件，但是我们只需要知道是什么拖累了 zsh 冷启动，将这个文件格式化一下即可。这里提供一个简单的脚本

```bash
# $HOME/format_profile.zsh
#!/usr/bin/env zsh

typeset -a lines
typeset -i prev_time=0
typeset prev_command

while read line; do
    if [[ $line =~ '^.*\+([0-9]{10})\.([0-9]{6})[0-9]* (.+)' ]]; then
        integer this_time=$match[1]$match[2]

        if [[ $prev_time -gt 0 ]]; then
            time_difference=$(( $this_time - $prev_time ))
            lines+="$time_difference $prev_command"
        fi

        prev_time=$this_time

        local this_command=$match[3]
        if [[ ${#this_command} -le 80 ]]; then
            prev_command=$this_command
        else
            prev_command="${this_command:0:77}..."
        fi
    fi
done < ${1:-/dev/stdin}

print -l ${(@On)lines}
```

```shell
$ cd $HOME
$ chmod +x format_profile.zsh
$ ./format_profile.zsh zsh_profile.123456 | head -n 30

356910 _zsh_nvm_auto_use:14> [[ none != N/A ]]
307791 /Users/sukka/.zshrc:312> hexo '--completion=zsh'
178444 /Users/sukka/.zshrc:310> thefuck --alias
161193 nvm_version:21> VERSION=N/A
148555 nvm_version:21> VERSION=N/A
96497 (eval):4> pyenv rehash
58759 /Users/sukka/.zshrc:311> pyenv init -
48629 nvm_auto:15> VERSION=''
42779 /Users/sukka/.zshrc:114> FPATH=/usr/local/share/zsh/site-functions:/usr/local...
42527 nvm_auto:15> nvm_resolve_local_alias default
41620 nvm_resolve_local_alias:7> VERSION=''
35577 nvm_resolve_local_alias:7> VERSION=''
29444 _zsh_nvm_load:6> source /Users/sukka/.nvm/nvm.sh
24967 compaudit:154> _i_wfiles=( )
24889 nvm_resolve_alias:15> ALIAS_TEMP=''
22000 nvm_auto:18> nvm_rc_version
20890 nvm_ls:29> PATTERN=default
[Redacted]
```

这样就一目了然了。可以看到，除了 `nvm` 以外、`hexo` 的自动补全、`thefuck` 的初始化、`pyenv` 都大幅拖慢了 zsh 的启动速度。

#### Lazyload

```bash
# 提前将 .pyenv/shims 添加到 PATH 中，这样即使 pyenv 没有初始化也可以使用 Python
export PATH="/Users/sukka/.pyenv/shims:${PATH}"

pyenv() {
  # 移除占位函数
  unfuntion pyenv

  # 初始化 pyenv
  eval "$(command pyenv init -)"

  # 继续执行 pyenv 命令
  pyenv "$@"
}


##### pyenv 在初始化时会自动加载补全（completion），但是由于 lazyload、第一次执行 pyenv 时就没有补全了，因此还需要为补全添加 lazyload
__lazyload_completion_pyenv() {
  # 删除 pyenv 命令补全的占位
  comdef -d pyenv
  # 移除 pyenv 占位函数
  unfunction pyenv
  # 加载真正的 pyenv 命令补全
  source "$(brew --prefix pyenv)/completions/pyenv.zsh"
}

compdef __lazyload_completion_pyenv pyenv
```

这样，当首次输入 pyenv 并按下 Tab 时会加载 pyenv 的命令补全，第二次按下 Tab 时就可以正常显示命令补全了。

将上述 lazyload 封装成函数便于调用：

```bash
sukka_lazyload_add_command() {
    eval "$1() { \
        unfunction $1 \
        _sukka_lazyload__command_$1 \
        $1 \$@ \
    }"
}

sukka_lazyload_add_completion() {
    local comp_name="_sukka_lazyload__compfunc_$1"
    eval "${comp_name}() { \
        compdef -d $1; \
        _sukka_lazyload_completion_$1; \
    }"
    compdef $comp_name $1
}

```

```bash
_sukka_lazyload__command_pyenv() {
  # pyenv 初始化
  eval "$(command pyenv init -)"
}
_sukka_lazyload__compfunc_pyenv() {
  # pyenv 命令补全
  source "$(brew --prefix pyenv)/completions/pyenv.zsh"
}
# 添加 pyenv 的 lazyload
sukka_lazyload_add_command pyenv
sukka_lazyload_add_completion pyenv

_sukka_lazyload__command_fuck() {
  # fuck 初始化
  eval $(thefuck --alias)
}
# 添加 fuck 的 lazyload
sukka_lazyload_add_command fuck

_sukka_lazyload__completion_hexo() {
  # hexo 的 completion
  eval $(hexo --completion=zsh)
}
# 添加 hexo completion 的 lazyload
sukka_lazyload_add_completion hexo
```

#### zsh 判断命令是否存在

通常情况下我们会写出以下三种条件判断方式：

```bash
[[ command -v node &>/dev/null ]] && node -v
[[ which -a node &>/dev/null ]] && node -v
[[ type node &>/dev/null ]] && node -v
```

但是在 zsh 中，还有一种速度更快的判断命令存在的方法：

```bash
(( $+commands[node] )) && node -v
```

zsh 提供了一个数组元素查找语法 `$+array[item]` （元素存在则返回 1 否则返回 0），同时 zsh 也维护了一个命令数组 `$commands`，在数组中检索元素比调用 which、type、command -v 命令都要快许多。

#### 变量字符串查找

在 .zshrc 中鲜少需要用到这样的语法，不过依然存在一些 case，比如为了避免向 $FPATH 中重复添加 Homebrew 的自动补全，提前检查 $FPATH 中是否已经包含了 Homebrew 的路径。一般常见的写法都涉及到 echo 和 grep ：

```bash
[[ $(echo $FPATH | grep "/usr/local/share/zsh/site-functions") ]] && echo "homebrew exists in fpath"
```

但是在 zsh 中我们不需要 grep 也可以实现同样的功能：

```zsh
(( $FPATH[(I)/usr/local/share/zsh/site-functions] )) && echo "homebrew exists in fpath"
```

zsh 内置了在变量中匹配字符串的语法：`$variable[(i)keyword]` 和 `$variable[(I)keyword]`，前者是从左往右寻找、后者是从右往左寻找，返回值为第一个匹配的首字符位置，当没有匹配时返回值则是变量的最终位置，也就是说当找不到匹配时 `(i)` 会返回字符串的长度、而 `(I)` 会返回 0。因此只需要从右往左寻找、判断返回值是否为 0 即可，搭配将数字转化为布尔值的 `(( ))` 就可以写出又快又漂亮的条件语句。
