---
title: "如何使用 Chrome 開發人員工具擷取網頁畫面與製作長截圖？"
date: 2020-07-02T09:07:34+08:00
menu:
  sidebar:
    name: "如何使用 Chrome 開發人員工具擷取網頁畫面與製作長截圖？"
    identifier: chrome-howto-screenshot-page-by-chrome-devtools
    weight: 10
tags: ["URL", "Chrome", "ScreenShot"]
categories: ["URL", "Chrome", "ScreenShot"]
---

- [如何使用 Chrome 開發人員工具擷取網頁畫面與製作長截圖？](https://tedliou.com/archives/howto-screenshot-page-by-chrome-devtools/)

1. 開啟 Chrome 開發人員工具
2. 按下右上角的 more_vert，並選擇 filter_none 將它改成獨立視窗
3. `Ctrl + Shift + P`(`Command + Shift + P`)
4. 輸入 `screenshot`
   1. Capture area screenshot：區域擷圖，選擇後你的滑鼠指標會變成 add，用它在網頁中框選出一個範圍即可擷圖。
   2. Capture full size screenshot：長截圖，延遲一秒左右後將會自動完成擷圖，就是這麼簡單。
   3. Capture node screenshot：節點擷圖，它類似長擷圖，但只有螢幕有顯示到的地方有影像，其餘都是空白。在文章後段我們會放預覽圖讓你比較一下差異。
   4. Capture screenshot：普通擷圖，會自動擷取視窗看得到的網頁。如果剛剛沒有讓開發者工具變成獨立視窗的話，這邊的擷圖結果就會被影響。
