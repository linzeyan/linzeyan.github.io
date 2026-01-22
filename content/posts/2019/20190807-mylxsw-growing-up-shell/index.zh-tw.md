---
title: "Shell 腳本學習筆記"
date: 2019-08-07T15:14:08+08:00
menu:
  sidebar:
    name: "Shell 腳本學習筆記"
    identifier: shell-scripting-notes-mylxsw-growing-up
    weight: 10
tags: ["Links", "SHELL"]
categories: ["Links", "SHELL"]
hero: images/hero/shell.png
---

- [Shell 腳本學習筆記](https://github.com/mylxsw/growing-up/blob/master/doc/Shell%E8%84%9A%E6%9C%AC%E5%AD%A6%E4%B9%A0%E7%AC%94%E8%AE%B0.md)

### 執行算術運算

    val=`expr $a + $b`

### 運算符

| 符號 | 說明                                 | 示例                       |
| ---- | ------------------------------------ | -------------------------- |
| !    | 非運算                               | [ ! false ]                |
| -o   | 或運算                               | [ $a -lt 20 -o $b -gt 20 ] |
| -a   | 與運算                               | [ $a -lt 20 -a $b -gt 20 ] |
| =    | 相等檢測                             | [ $a = $b ]                |
| !=   | 不相等檢測                           | [ $a != $b ]               |
| -z   | 字串長度是否為 0，為 0 則回傳 true   | [ -z $a ]                  |
| -n   | 字串長度不為 0，不為 0 回傳 true     | [ -n $a ]                  |
| str  | 檢測字串是否為空，不為空回傳 true    | [ $a ]                     |
| -b   | 檢測檔案是否是區塊裝置檔             | [ -b $file ]               |
| -c   | 檢測檔案是否是字元裝置               | ..                         |
| -d   | 檢測檔案是否為目錄                   | [ -d $file ]               |
| -f   | 檢測檔案是否為一般檔案               | [ -f $file ]               |
| -r   | 檢測檔案是否可讀                     | ..                         |
| -w   | 檢測檔案是否可寫                     | ..                         |
| -x   | 檢測檔案是否可執行                   | ..                         |
| -s   | 檢測檔案是否為空                     | ..                         |
| -e   | 檢測檔案是否存在                     | ..                         |

### 特殊變數

| 變數 | 含義                                                                          |
| ---- | ----------------------------------------------------------------------------- |
| $0   | 目前腳本的檔名                                                                |
| $n   | 傳遞給腳本或函式的參數，n 表示第幾個參數                                      |
| $#   | 傳遞給腳本或函式的參數個數                                                    |
| $\*  | 傳遞給腳本或函式的所有參數，所有參數視為一個詞，例如 "1 2 3"                |
| $@   | 傳遞給腳本或函式的所有參數，每個參數視為一個詞，用雙引號包含，例如 "1" "2" "3" |
| $?   | 上個命令的退出狀態，或函式的回傳值                                            |
| $$   | 目前 Shell 行程 ID；對 Shell 腳本而言，就是該腳本所在的行程 ID                |

### POSIX 程式退出狀態

| 狀態碼  | 含義                                                              |
| ------- | ----------------------------------------------------------------- |
| 0       | 命令成功退出                                                      |
| > 0     | 在重導向或單詞展開期間（~、變數、命令、算術展開以及單詞切割）失敗 |
| 1 - 125 | 命令不成功退出，各命令自行定義特定退出值含義                      |
| 126     | 命令找到但檔案無法執行                                            |
| 127     | 命令未找到                                                        |
| > 128   | 命令因收到信號而終止                                              |

### 輸入輸出重導向

| 命令           | 說明                                               |
| -------------- | -------------------------------------------------- |
| command > file | 將輸出重導向到 file                                |
| command > file | 將輸出以追加的方式重導向到 file                    |
| n > file       | 將檔案描述符為 n 的檔案重導向到 file               |
| n >> file      | 將檔案描述符為 n 的檔案以追加的方式重導向到 file   |
| n >& m         | 將輸出檔案 m 和 n 合併                             |
| n <& m         | 將輸入檔案 m 和 n 合併                             |
| << tag         | 將開始標記 tag 和結束標記 tag 之間的內容作為輸入   |

### 檔案包含

使用 `.` 或 `source` 包含檔案

    . filename
    source filename

> 被包含的檔案不需要有執行權限

### 使用函式

下面是函式基本結構

    # 直接使用函式名稱即可，前面可選擇加上 function
    function_name(){

        # 使用 $#, $*, $@ 以及 $0-$n 取得函式名稱與其他參數
        val="$1"

        # 帶回傳值，可選，回傳值只能是整數（狀態碼）
        # 若要回傳結果，使用全域變數
        return $val
    }

函式呼叫

    # 呼叫函式直接使用函式名稱即可，後面可用空格傳入多個參數
    function_name 1 2 3 4
    # 使用 $? 取得回傳值
    ret=$?

## 常用程式片段

### 列出目錄下的所有檔案

下面的程式列出 downloads 目錄下所有的 xlsx 檔案。注意，要列出所有檔案需使用 `"$watch_dir"/*` 形式。

    watch_dir="/Users/mylxsw/Downloads"
    # 避免目錄下沒有匹配檔案時回傳帶有 * 的結果
    shopt -s nullglob
    for file in "$watch_dir"/*.xlsx
    do
        echo $file
    done

    for file in "$watch_dir"/*/    # 列出所有目錄
    do
        echo $file
    done

> 參考 [How to get the list of files in a directory in a shell script?](http://stackoverflow.com/questions/2437452/how-to-get-the-list-of-files-in-a-directory-in-a-shell-script) 和 [Bash Shell Loop Over Set of Files](http://www.cyberciti.biz/faq/bash-loop-over-file/)

### 從標準輸入循環讀取

    while read line
    do
        if [ $line != 'EOF' ]
        then
            echo $line
        fi
    done

### 日期時間處理

#### 取得目前日期

    # 輸出: 20161023
    echo $(date +%Y%m%d)

#### 時間比較

時間比較可先轉換為 UNIX 時間戳，然後直接比較時間戳大小即可。

    time1=`date +%s`
    time2=`date -d '2016-10-25 17:20:13' +%s`

    if [ $time1 -gt $time2 ]; then
        echo "time1 > time2"
    else
        echo "time1 < time2"
    fi
