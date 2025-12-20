---
title: "vimrc設定教學"
date: 2018-11-03T23:30:52+08:00
menu:
  sidebar:
    name: "vimrc設定教學"
    identifier: vim-vimrc-configuration
    weight: 10
tags: ["URL", "Vim"]
categories: ["URL", "Vim"]
---

- [vimrc 設定教學](https://wiki.csie.ncku.edu.tw/vim/vimrc)

- :set nu
  - 顯示行號：對於 debug 相當有幫助!
- :set ai
  - 自動對齊縮排：如果上一行有兩個 tab 的寬度，按 enter 繼續編輯下一行時會自動保留兩個 tab 鍵的寬度。
- :set cursorline
  - 光標底線：光標所在的那一行會有底線，幫助尋找光標位置
- :set bg=light
  - 上色模式-針對亮背景上色
  - 預設為亮背景(白色等)上色，但是終端機的初始背景色為深紫色，會出現文字失蹤 ( 例如註解為深藍色 ) 的情況。將這一行換成 :set bg=dark 即可。
- :set tabstop=4
  - 縮排間隔數 ( 預設為 8 個空白對齊 )
  - 也就是說按一次 tab 鍵，游標會自動跳 4 格空白字元的寬度。雖有多個空格但實際上只有一個 tab 字元。
  - 注意：也就是說，在其他環境下，看到 tab 字元，依舊是 8 個空白寬
- :set shiftwidth=4
  - 自動縮排對齊間隔數：向右或向左一個縮排的寬度

以下可以斟酌使用

- :set mouse=a
  - 啟用游標選取：游標可以直接選取文字，滾輪可以直接滑動頁面 ( 非移動游標 )。
  - 可以取代用 v 選取字元的功能，配合 ctrl+insert ( 複製 ) 及 shift+inset ( 貼上 )，相當方便
- :set mouse=""
  - 停用游標選取：游標無法選取文字，滾輪只會移動光標的位置。
- :set ruler
  - ( 預設就有 ) 顯示右下角的 行,列 目前在文件的位置 % 的資訊
- :set backspace=2
  - ( 預設就有 ) 在 insert 模式啟用 backspace 鍵
- :set formatoptions+=r
  - 自動註解(注意：若要貼上的文件某一行有註解，會因為此項設定而讓其以下每一行都變成註解)
- :set history=100
  - 保留 100 個使用過的指令
- :set incsearch
  - 在關鍵字尚未完全輸入完畢前就顯示結果
  - 如果覺得這功能太過熱心的話，可以使用 ctrl+n 來達成自動補完的功能
