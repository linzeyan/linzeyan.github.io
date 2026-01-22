---
title: "How to capture web pages and long screenshots with Chrome DevTools?"
date: 2020-07-02T09:07:34+08:00
menu:
  sidebar:
    name: "How to capture web pages and long screenshots with Chrome DevTools?"
    identifier: chrome-howto-screenshot-page-by-chrome-devtools
    weight: 10
tags: ["Links", "Chrome", "ScreenShot"]
categories: ["Links", "Chrome", "ScreenShot"]
---

- [How to capture web pages and long screenshots with Chrome DevTools?](https://tedliou.com/archives/howto-screenshot-page-by-chrome-devtools/)

1. Open Chrome DevTools
2. Click more_vert in the top-right, then choose filter_none to make it a separate window
3. `Ctrl + Shift + P`(`Command + Shift + P`)
4. Type `screenshot`
   1. Capture area screenshot: area screenshot. After selecting it, your cursor changes to add. Use it to select an area on the page.
   2. Capture full size screenshot: long screenshot. It completes automatically after about one second.
   3. Capture node screenshot: node screenshot. Similar to a long screenshot, but only visible parts are captured and the rest is blank.
   4. Capture screenshot: normal screenshot. It captures the visible page. If DevTools is not in a separate window, the result is affected.
