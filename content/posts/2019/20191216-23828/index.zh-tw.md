---
title: "Golang 服務的檔案句柄超出系統限制（too many open files）"
date: 2019-12-16T10:14:33+08:00
menu:
  sidebar:
    name: "Golang 服務的檔案句柄超出系統限制（too many open files）"
    identifier: golang-service-has-exceeded-the-system-limit-for-file-handles-too-many-open-files
    weight: 10
tags: ["Links", "Go"]
categories: ["Links", "Go"]
hero: images/hero/go.svg
---

- [Golang 服務的檔案句柄超出系統限制（too many open files）](https://studygolang.com/articles/23828)

1. 查看系統設定：`ulimit -a | grep open`，系統設定正常。

2. 查看服務的開啟檔案限制：`cat /proc/40636/limits`，服務沒有繼承系統設定，仍是預設的 1024 限制。

3. 查看服務開啟檔案數（連線數）：`lsof -p 40636 | wc -l`，已超過限制，因此報錯。

4. 查看開啟了哪些連線：`lsof -p 40636 > openfiles.log`，發現很多 HTTP 連線未關閉，IP 是告警服務的介面。沿著線索找到原因：程式解析設定時出錯，對告警服務大量連線後未關閉，導致 too many open files。至於為何服務未繼承系統最大限制，還需進一步查看。

5. 最終原因：服務由 supervisor 管理，supervisor 預設 minfds 為 1024。於設定中加入 `minfds=81920`，並重啟 `supervisorctl reload`。
