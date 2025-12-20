---
title: "使用 oh-my-posh 美化 PowerShell 樣式"
date: 2020-12-10T13:15:59+08:00
menu:
  sidebar:
    name: "使用 oh-my-posh 美化 PowerShell 樣式"
    identifier: windows-terminal-powershell-oh-my-post
    weight: 10
tags: ["URL", "Windows", "Terminal", "PowerShell"]
categories: ["URL", "Windows", "Terminal", "PowerShell"]
hero: images/hero/microsoft_windows.png
---

- [使用 oh-my-posh 美化 PowerShell 樣式](https://blog.poychang.net/setting-powershell-theme-with-oh-my-posh/)

```powershell
# 這會從 PowerShell Gallery 下載並安裝 posh-git 和 oh-my-posh 這兩個模組，前者是在命令列中顯示 Git 專案的相關資訊，後者則是美美的樣式套件
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser


# 接著我們要修改 PowerShell 啟動時所載入的設定檔，在 PowerShell 中輸入 $PROFILE 可得到當前使用者啟動 PowerShell 時，會載入的個人設定檔位置。
# 你的電腦可能沒有這個實體檔案，這時可以執行下面的指令，如果沒有該設定檔，則建立一個，然後使用 notepad 來開啟該設定檔。
if (!(Test-Path -Path $PROFILE )) { New-Item -Type File -Path $PROFILE -Force }
notepad $PROFILE
```

最後在該設定檔中加入下列指令

```powershell
Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Paradox
```

oh-my-posh 內建了很多樣式，你也可以使用 Get-Theme 這個 Cmdlet 指令取得 oh-my-posh 有提供的所有樣式及相關檔案位置
