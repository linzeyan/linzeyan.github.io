---
title: "Til"
date: 2026-10-17T19:20:07+08:00
menu:
  sidebar:
    name: "Til"
    identifier: til-recent-20261017
    weight: 10
tags:
  [
    "Links",
    "Bookmark",
    "Typing",
    "Music",
    "Board Game",
    "Game",
    "Python",
    "Pandas",
    "Linux",
    "Kernel",
    "Interview",
    "Go",
    "HTTP",
    "Diagrams",
    "Audiobook",
    "TTS",
    "LLM",
    "Agent",
    "Memory",
    "macOS",
    "Protobuf",
    "LEGO",
    "OCR",
    "HTML",
    "slides",
    "Skill",
    "MCP",
    "Reverse Engineering",
  ]
categories:
  [
    "Links",
    "Bookmark",
    "Typing",
    "Music",
    "Board Game",
    "Game",
    "Python",
    "Pandas",
    "Linux",
    "Kernel",
    "Interview",
    "Go",
    "HTTP",
    "Diagrams",
    "Audiobook",
    "TTS",
    "LLM",
    "Agent",
    "Memory",
    "macOS",
    "Protobuf",
    "LEGO",
    "OCR",
    "HTML",
    "slides",
    "Skill",
    "MCP",
    "Reverse Engineering",
  ]
---

- [keybr.com is not (just) a typing test](https://www.keybr.com/)
- [Lofi Cities](https://loficities.com/)
- [Hole Punch](https://notoriousbfg.com/hole-punch/)
- [Play board games online with friends](https://buddyboardgames.com/)
- [輔導室：今天也不能倒下](https://claude.ai/artifact/AWwoUVfR7KFTQd7ateyNfb)
- [Virtual Guitar](https://guitoro.com/)
- [Big words for any screen](https://bigwords.page/)
- **Article**
  - [Pandas Should Go Extinct](https://eddie.codes/posts/pandas-should-go-extinct/)
  - https://x.com/soragoto/status/2098983783085318491
  - [Better HTTP/1 connection reuse](https://go.dev/blog/http-connection-reuse)
- **Diagram**
  - [reladraw: reladraw is a text language for diagrams where you say where things go.](https://github.com/reladraw/reladraw)
- **Github**
  - [abogen: Generate audiobooks from EPUBs, PDFs and text with synchronized captions.](https://github.com/denizsafak/abogen)
  - [mem0: The Memory Layer for AI Agents - Drop-in memory infrastructure for AI agents and apps. Context that persists. Built for production.](https://github.com/mem0ai/mem0)
  - [ATBClone: The Ultimate macOS App Cloner & Sandbox Bypass Engine.](https://github.com/aitobox/ATBClone)
  - [buf: The best way of working with Protocol Buffers.](https://github.com/bufbuild/buf)
  - [ldraw-nova: Give an AI agent a model idea. Guide it, let it build it, and get an LDraw LEGO© model.](https://github.com/anteloc/ldraw-nova)
  - [Craft APP](https://github.com/storytold)
  - [Chandra OCR 2: OCR model that handles complex tables, forms, handwriting with full layout.](https://github.com/datalab-to/chandra)
- **Present**
  - [effective-html: Agent skills for useful HTML artifacts, wireframes, interactive prototypes, plans, and diagrams.](https://github.com/plannotator/effective-html)
- **Skill**
  - [go-modern-guidelines: Help AI coding agents write modern Go](https://github.com/JetBrains/go-modern-guidelines)
  - [Reverse Engineer Anything: One MCP for reverse engineering across binaries, applications, and runtime behavior.](https://github.com/morluto/rea)

## https://x.com/soragoto/status/2098983783085318491

> 面试官：我看你简历上写熟悉 Linux，大概有多熟悉？看过源码吗？
>
> 我：看过一些。
>
> 面试官：那说说有什么优秀设计，或者让你印象比较深的地方。
>
> 我：那就要说到华硕的 HID 驱动了。
>
> 面试官：？
>
> 我：华硕有些键盘会在某些特定情况下往 host 发送电源相关的键值，导致 host 关机，所以内核驱动里专门把那个键值屏蔽了。
>
> 面试官：nmd，现在也是我印象最深的地方了。

https://github.com/torvalds/linux/blob/master/drivers/hid/hid-asus.c

## [Pandas Should Go Extinct](https://eddie.codes/posts/pandas-should-go-extinct/)

### [Polars](https://github.com/pola-rs/polars)

官方原生支援 Python、Rust、Node.js、R,另外也有 SQL 介面可用。

| 語言    | 安裝方式                                                                    |
| ------- | --------------------------------------------------------------------------- |
| Python  | `pip install polars`                                                        |
| Rust    | `cargo add polars` (原生函式庫,其他語言綁定都是包在這之上)                  |
| Node.js | `npm install nodejs-polars`                                                 |
| R       | `install.packages("polars")`(提供 R 語言的綁定,可用來處理 Polars DataFrame) |

比較特別的是,Python 綁定所使用的 Rust crate 叫做 py-polars,但無論是 Python 套件還是模組本身都叫做 polars,所以還是 `pip install polars` 再 `import polars` 就好。另外也支援 GPU 加速(NVIDIA GPU)。

### [DuckDB](https://github.com/duckdb/duckdb)

支援的語言更多,官方主要維護的 client API 包括:

C、CLI(命令列)、Java (JDBC)、Go、Node.js、ODBC、Python、R、Rust,還有 C++、Julia、WebAssembly (Wasm)、ADBC API、Swift。

除此之外還有社群維護的「第三方」綁定:C#、Common Lisp、Crystal、Elixir、Ruby、Zig。

比較值得一提的:

- **Wasm 版本**:可以直接在瀏覽器裡跑 DuckDB,不需要伺服器
- **R 有兩種介面**:標準 `install.packages("duckdb")`,或是 dplyr 相容的 duckplyr 套件,寫法更貼近 tidyverse
- DuckDB 支援 PostgreSQL 相容的 SQL 語言,所有 client 都用同一套 SQL
- DuckDB 最大的賣點之一——**不需要先把資料匯入(import)進 DuckDB,就可以直接查詢**。以 R 為例,主要有兩種情境:

**1. 直接查詢外部檔案(CSV、Parquet、JSON)**

不需要 `read.csv()` 讀進記憶體、也不需要先建表,DuckDB 會自動偵測 schema,只讀取查詢需要的欄位跟資料列, no read.csv, no temporary table, no RAM spike, and it reads only the columns and rows the query needs:

```r
library(DBI)
library(duckdb)
con <- dbConnect(duckdb())

# 直接對 CSV / Parquet 檔案下 SQL,檔案從沒真的「匯入」過
dbGetQuery(con, "SELECT * FROM 'sales.csv' LIMIT 10")
dbGetQuery(con, "SELECT * FROM read_parquet('data/*.parquet')")
```

甚至可以直接查詢遠端的 Parquet(例如放在 S3 或網址上),完全不用下載。

**2. 直接查詢 R 記憶體裡已經存在的 data frame**

這點更特別——DuckDB 可以把 R 的 data frame「註冊」成一個零複製(zero-copy)的視圖,資料仍然留在 R 的記憶體裡,DuckDB 只是直接讀取它,不會另外複製一份DuckDB keeps a reference to the R data frame after registration, which prevents the data frame from being garbage-collected, and the reference is cleared when the connection closes or via duckdb_unregister():

```r
duckdb_register(con, "flights", nycflights13::flights)

dbGetQuery(con, "SELECT dest, AVG(dep_delay) FROM flights GROUP BY dest")
```

也可以搭配 dbplyr/dplyr 語法,一樣是直接對 data frame 或檔案操作using dbplyr, CSV and Parquet files can also be read directly through dplyr::tbl。

**簡單來說**:DuckDB 比較像是一個「查詢引擎」而不是傳統要先 ETL 匯入的資料庫,「資料放哪就查哪」是它的核心設計理念,這也是為什麼它常被拿來取代「先用 pandas/R 把整個檔案讀進記憶體再處理」的傳統做法。
