---
title: "Style PowerShell with oh-my-posh"
date: 2020-12-10T13:15:59+08:00
menu:
  sidebar:
    name: "Style PowerShell with oh-my-posh"
    identifier: windows-terminal-powershell-oh-my-post
    weight: 10
tags: ["Links", "Windows", "Terminal", "PowerShell"]
categories: ["Links", "Windows", "Terminal", "PowerShell"]
hero: images/hero/microsoft_windows.png
---

- [Style PowerShell with oh-my-posh](https://blog.poychang.net/setting-powershell-theme-with-oh-my-posh/)

```powershell
# This downloads and installs the posh-git and oh-my-posh modules from PowerShell Gallery.
# The former shows Git info in the prompt, and the latter provides the themes.
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser


# Next, edit the PowerShell profile loaded at startup. In PowerShell, $PROFILE shows the current
# user's profile path. The file may not exist; run the commands below to create it and open it.
if (!(Test-Path -Path $PROFILE )) { New-Item -Type File -Path $PROFILE -Force }
notepad $PROFILE
```

Add the following commands to the profile file:

```powershell
Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Paradox
```

oh-my-posh includes many themes. You can use the Get-Theme cmdlet to list all available themes and their file locations.
