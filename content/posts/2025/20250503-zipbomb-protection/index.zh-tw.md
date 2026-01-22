---
title: "我用 Zip Bomb 來保護我的伺服器"
date: 2025-05-03T11:24:00+08:00
menu:
  sidebar:
    name: "我用 Zip Bomb 來保護我的伺服器"
    identifier: zipbomb-protection
    weight: 10
tags: ["Links", "HTTP", "Security"]
categories: ["Links", "HTTP", "Security"]
---

- [我用 Zip Bomb 來保護我的伺服器](https://idiallo.com/blog/zipbomb-protection)

- 發生的情況是：對方收到檔案後，讀取標頭得知這是壓縮檔，因此嘗試解壓那個 1MB 的檔案來找他們要的內容。但檔案會不斷膨脹，直到耗盡記憶體、伺服器崩潰。1MB 的檔案會解壓成 1GB，這已足以讓多數機器人失敗。不過對於那些死纏爛打的腳本，我就給它 10MB 的檔案，解壓後會變成 10GB，立刻把腳本搞掛。

- `dd if=/dev/zero bs=1G count=10 | gzip -c > 10GB.gz`

  - `dd`：用於複製或轉換資料的指令。
  - `if`：輸入檔案，這裡指定 `/dev/zero`，它會產生無限的零位元組串流。
  - `bs`：區塊大小，設為 1GB（1G），代表 dd 會以 1GB 為單位讀寫。
  - `count=10`：代表處理 10 個區塊、每個 1GB，因此會產生 10GB 的零資料。

- middleware

```
if (ipIsBlackListed() || isMalicious()) {
    header("Content-Encoding: gzip");
    header("Content-Length: ". filesize(ZIP_BOMB_FILE_10G)); // 10 MB
    readfile(ZIP_BOMB_FILE_10G);
    exit;
}
```
