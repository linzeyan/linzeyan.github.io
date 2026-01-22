---
title: "進階 Shell 腳本技巧：用 Bash 自動化複雜任務"
date: 2024-09-25T09:23:00+08:00
menu:
  sidebar:
    name: "進階 Shell 腳本技巧：用 Bash 自動化複雜任務"
    identifier: advanced-shell-scripting
    weight: 10
tags: ["Links", "SHELL", "BASH"]
categories: ["Links", "SHELL", "BASH"]
hero: images/hero/shell.png
---

- [進階 Shell 腳本技巧：用 Bash 自動化複雜任務](https://omid.dev/2024/06/19/advanced-shell-scripting-techniques-automating-complex-tasks-with-bash/)

#### 使用內建指令

{{< alert type="info" >}}
內建指令執行更快，因為不需要載入外部程序。
{{< /alert >}}

#### 減少子殼層

{{< alert type="info" >}}
子殼層會帶來效能成本。
{{< /alert >}}

```bash
# Inefficient
output=$(cat file.txt)

# Efficient
output=$(<file.txt)
```

#### 使用陣列處理大量資料

{{< alert type="info" >}}
處理大量資料時，陣列比多個變數更有效率，也更好管理。
{{< /alert >}}

```bash
# Inefficient
item1="apple"
item2="banana"
item3="cherry"

# Efficient
items=("apple" "banana" "cherry")
for item in "${items[@]}"; do
    echo "$item"
done
```

#### 啟用 Noclobber

{{< alert type="info" >}}
避免檔案被意外覆寫。
{{< /alert >}}

```bash
set -o noclobber
```

#### 使用函式

{{< alert type="info" >}}
函式可以封裝並重用程式碼，讓腳本更乾淨、重複更少。
{{< /alert >}}

#### 高效的檔案操作

{{< alert type="info" >}}
進行檔案操作時，使用更有效率的技巧以降低資源消耗。
{{< /alert >}}

```bash
# Inefficient
while read -r line; do
    echo "$line"
done < file.txt

# Efficient
while IFS= read -r line; do
    echo "$line"
done < file.txt
```

#### 平行處理

{{< alert type="info" >}}
像 `xargs` 和 GNU `parallel` 這類工具非常實用。
{{< /alert >}}

#### 錯誤處理

{{< alert type="info" >}}
健全的錯誤處理對建立可靠、易維護的腳本至關重要。
{{< /alert >}}

```bash
# Exit on Error: Using set -e ensures that your script exits immediately if any command fails, preventing cascading errors.
set -e

# Custom Error Messages: Implement custom error messages to provide more context when something goes wrong.
command1 || { echo "command1 failed"; exit 1; }

# Trap Signals: Use the `trap` command to catch and handle signals and errors gracefully.
trap 'echo "Error occurred"; cleanup; exit 1' ERR

function cleanup() {
    # Cleanup code
}

# Validate Inputs: Always validate user inputs and script arguments to prevent unexpected behavior.
if [[ -z "$1" ]]; then
    echo "Usage: $0 <argument>"
    exit 1
fi

# Logging: Implement logging to keep track of script execution and diagnose issues.
logfile="script.log"
exec > >(tee -i $logfile)
exec 2>&1

echo "Script started"
```

#### 自動化複雜的系統管理工作

1.  自動化備份
2.  系統監控
3.  使用者管理
4.  自動更新
5.  網路設定
