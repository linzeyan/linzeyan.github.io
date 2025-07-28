---
title: "Marp教學：Markdown搭配VS Code做簡報，快速輸出為PPTX或PDF，提昇做簡報效率"
date: 2025-04-08T09:12:00+08:00
menu:
  sidebar:
    name: "Marp教學：Markdown搭配VS Code做簡報，快速輸出為PPTX或PDF，提昇做簡報效率"
    identifier: vscode-marp-presentation
    weight: 10
tags: ["URL", "markdown", "VScode"]
categories: ["URL", "markdown", "VScode"]
---

[Marp教學：Markdown搭配VS Code做簡報，快速輸出為PPTX或PDF，提昇做簡報效率](https://ivonblog.com/posts/vscode-marp-presentation/)

1. Install 'Marp for VS Code'
2. 在Markdown最前面的FrontMatter，插入以下屬性，啟用Marp，並開啟顯示頁數功能
```
---
marp:true
paginate: true
---
```
3. Markdown文字都是直排排列的，需要換行請加上`\`。
4. 輸入三條橫線`---`分隔投影片。
5. 插入註解請用`<!-- -->`語法。