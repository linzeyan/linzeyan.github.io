---
title: "LocalStorage vs. IndexedDB vs. Cookies vs. OPFS vs. WASM-SQLite"
date: 2024-11-29T14:58:29+08:00
menu:
  sidebar:
    name: "LocalStorage vs. IndexedDB vs. Cookies vs. OPFS vs. WASM-SQLite"
    identifier: localstorage-indexeddb-cookies-opfs-sqlite-wasm
    weight: 10
tags: ["Links", "Browser"]
categories: ["Links", "Browser"]
---

- [LocalStorage vs. IndexedDB vs. Cookies vs. OPFS vs. WASM-SQLite](https://rxdb.info/articles/localstorage-indexeddb-cookies-opfs-sqlite-wasm.html)

#### 現代瀏覽器可用的 Storage API

**_Cookies_**

Cookies 會儲存小型的鍵值資料，主要用於工作階段管理、個人化與追蹤。Cookies 可以設定多種安全選項，例如存活時間或網域屬性，以便在多個子網域之間共用。

**_LocalStorage_**

LocalStorage 只適合儲存少量且需要跨 session 保存的資料，並且受限於 5MB 的容量上限。要儲存複雜資料，通常需要轉成字串，例如使用 JSON.stringify()。這個 API 不是非同步的，代表在操作時會阻塞你的 JavaScript 程序，因此執行重型操作可能會讓 UI 無法渲染。

**_IndexedDB_**

IndexedDB 是一個用於儲存大量結構化 JSON 資料的低階 API。雖然使用起來有些困難，但 IndexedDB 可以利用索引並支援非同步操作。它缺乏複雜查詢能力，只能迭代索引，更像是其他函式庫的底層基礎，而非完整的資料庫。

#### 儲存容量限制

| 技術        | 上限                                  |
| ----------- | ------------------------------------- |
| Cookie      | 4 KB                                  |
| LocalStorage | 每個來源 4 MB 到 10 MB                 |
| IndexedDB   | 取決於瀏覽器實作                       |
| OPFS        | 取決於可用的磁碟空間                   |

#### 效能比較

##### 初始化時間

| 技術                  | 時間（毫秒） |
| --------------------- | ---------- |
| IndexedDB             | 46         |
| OPFS 主執行緒         | 23         |
| OPFS WebWorker        | 26.8       |
| WASM SQLite（記憶體） | 504        |
| WASM SQLite（IndexedDB） | 535     |

##### 小型寫入延遲

| 技術                  | 時間（毫秒） |
| --------------------- | ---------- |
| Cookies               | 0.058      |
| LocalStorage          | 0.017      |
| IndexedDB             | 0.17       |
| OPFS 主執行緒         | 1.46       |
| OPFS WebWorker        | 1.54       |
| WASM SQLite（記憶體） | 0.17       |
| WASM SQLite（IndexedDB） | 3.17    |

##### 小型讀取延遲

| 技術                  | 時間（毫秒） |
| --------------------- | ---------- |
| Cookies               | 0.132      |
| LocalStorage          | 0.0052     |
| IndexedDB             | 0.1        |
| OPFS 主執行緒         | 1.28       |
| OPFS WebWorker        | 1.41       |
| WASM SQLite（記憶體） | 0.45       |
| WASM SQLite（IndexedDB） | 2.93    |
