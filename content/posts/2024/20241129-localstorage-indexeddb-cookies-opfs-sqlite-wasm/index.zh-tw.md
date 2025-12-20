---
title: "LocalStorage vs. IndexedDB vs. Cookies vs. OPFS vs. WASM-SQLite"
date: 2024-11-29T14:58:29+08:00
menu:
  sidebar:
    name: "LocalStorage vs. IndexedDB vs. Cookies vs. OPFS vs. WASM-SQLite"
    identifier: localstorage-indexeddb-cookies-opfs-sqlite-wasm
    weight: 10
tags: ["URL", "Browser"]
categories: ["URL", "Browser"]
---

- [LocalStorage vs. IndexedDB vs. Cookies vs. OPFS vs. WASM-SQLite](https://rxdb.info/articles/localstorage-indexeddb-cookies-opfs-sqlite-wasm.html)

#### The available Storage APIs in a modern Browser

**_Cookies_**

Cookies store small pieces of key-value data that are mainly used for session management, personalization, and tracking. Cookies can have several security settings like a time-to-live or the domain attribute to share the cookies between several subdomains.

**_LocalStorage_**

LocalStorage is only suitable for storing small amounts of data that need to persist across sessions and it is limited by a 5MB storage cap. Storing complex data is only possible by transforming it into a string for example with JSON.stringify(). The API is not asynchronous which means if fully blocks your JavaScript process while doing stuff. Therefore running heavy operations on it might block your UI from rendering.

**_IndexedDB_**

IndexedDB is a low-level API for storing large amounts of structured JSON data. While the API is a bit hard to use, IndexedDB can utilize indexes and asynchronous operations. It lacks support for complex queries and only allows to iterate over the indexes which makes it more like a base layer for other libraries then a fully fledged database.

#### Storage Size Limits

| Technology   | Limits                                |
| ------------ | ------------------------------------- |
| Cookie       | 4 KB                                  |
| LocalStorage | 4 MB to 10 MB per origin              |
| IndexedDB    | depends on the browser implementation |
| OPFS         | depends on the available disc space   |

#### Performance Comparison

##### Initialization Time

| Technology              | Time in Milliseconds |
| ----------------------- | -------------------- |
| IndexedDB               | 46                   |
| OPFS Main Thread        | 23                   |
| OPFS WebWorker          | 26.8                 |
| WASM SQLite (memory)    | 504                  |
| WASM SQLite (IndexedDB) | 535                  |

##### Latency of small Writes

| Technology              | Time in Milliseconds |
| ----------------------- | -------------------- |
| Cookies                 | 0.058                |
| LocalStorage            | 0.017                |
| IndexedDB               | 0.17                 |
| OPFS Main Thread        | 1.46                 |
| OPFS WebWorker          | 1.54                 |
| WASM SQLite (memory)    | 0.17                 |
| WASM SQLite (IndexedDB) | 3.17                 |

##### Latency of small Reads

| Technology              | Time in Milliseconds |
| ----------------------- | -------------------- |
| Cookies                 | 0.132                |
| LocalStorage            | 0.0052               |
| IndexedDB               | 0.1                  |
| OPFS Main Thread        | 1.28                 |
| OPFS WebWorker          | 1.41                 |
| WASM SQLite (memory)    | 0.45                 |
| WASM SQLite (IndexedDB) | 2.93                 |
