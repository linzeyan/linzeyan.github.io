---
title: "為什麼瀏覽器 user-agent string 總是包含 Mozilla/5.0 ?"
date: 2018-10-17T12:03:04+08:00
menu:
  sidebar:
    name: "為什麼瀏覽器 user-agent string 總是包含 Mozilla/5.0 ?"
    identifier: browser-mozilla5-0-always-user-agent-string
    weight: 10
tags: ["URL", "Browser", "UserAgent"]
categories: ["URL", "Browser", "UserAgent"]
---

- [為什麼瀏覽器 user-agent string 總是包含 Mozilla/5.0 ?](https://yulun.me/2013/mozilla5-0-always-user-agent-string/)
- [What does "Mozilla/5.0" in user agent string signify?](http://stackoverflow.com/questions/12288452/what-does-mozilla-5-0-in-user-agent-string-signify)
- [History of the browser user-agent string](http://webaim.org/blog/user-agent-string-history/)

快速結論

因為網站開發者可能會因為你是某瀏覽器(這裡是 Mozilla)，所以輸出一些特殊功能的程式碼(這裡指好的特殊功能)，所以當其他瀏覽器也支援這種好功能時，就試圖去模仿 Mozilla 瀏覽器讓網站輸出跟 Mozilla 一樣的內容，而不是輸出被閹割功能的程式碼。
