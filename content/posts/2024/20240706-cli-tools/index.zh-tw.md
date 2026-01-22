---
title: "Python 的多種命令列工具"
date: 2024-07-06T20:39:01+08:00
menu:
  sidebar:
    name: "Python 的多種命令列工具"
    identifier: python-pythons-many-command-line-utilities
    weight: 10
tags: ["Links", "Python"]
categories: ["Links", "Python"]
hero: images/hero/python.png
---

- [Python 的多種命令列工具](https://www.pythonmorsels.com/cli-tools/)

這些是 Python 最實用的通用命令列工具。

| Command                 | Purpose                      | More                                                                             |
| ----------------------- | ---------------------------- | -------------------------------------------------------------------------------- |
| `python -m http.server` | 啟動簡易網頁伺服器           | [Video](https://www.pythonmorsels.com/http-server/)                              |
| `python -m webbrowser`  | 開啟預設瀏覽器               | [Docs](https://docs.python.org/3/library/webbrowser.html#command-line-interface) |
| `python -m json.tool`   | 以更易讀的格式輸出 JSON 資料 | [Docs](https://docs.python.org/3/library/json.html#module-json.tool)             |
| `python -m calendar`    | 顯示命令列月曆               | [Docs](https://docs.python.org/3/library/calendar.html#command-line-usage)       |

### `http.server`

將 `http.server` 模組以腳本執行後，會在 8000 埠啟動一個 web server，並提供目前目錄中的檔案。我常常用它來預覽 Sphinx 文件網站（尤其是使用 `dirhtml` 選項時，會以 `index.html` 的子目錄結構呈現）。

```text
$ python -m http.server
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
```

### `webbrowser`

將 `webbrowser` 模組以腳本執行時，會用預設瀏覽器開啟指定 URL。例如，這會開啟 https://pseudorandom.name：

```text
$ python -m webbrowser pseudorandom.name
```

### `json.tool`

`json.tool` 模組可以當作腳本執行，會解析 JSON 文件並輸出更適合人閱讀的格式。

```shell
$ python -m json.tool /home/trey/Downloads/download.json
[
    {
        "title": "Python's walrus operator",
        "is_premium": false,
        "url": "/using-walrus-operator/"
    },
    {
        "title": "Refactoring long boolean expressions",
        "is_premium": true,
        "url": "/refactoring-boolean-expressions/"
    }
]
```

### `calendar`

將 `calendar` 模組以腳本執行時，預設會輸出當年的月曆，也可以透過參數自訂輸出。以下是只顯示某一個月份的範例：

```text
$ python -m calendar 2024 04
     April 2024
Mo Tu We Th Fr Sa Su
 1  2  3  4  5  6  7
 8  9 10 11 12 13 14
15 16 17 18 19 20 21
22 23 24 25 26 27 28
29 30
```

以上 4 個腳本是我覺得在任何機器上都很有用的通用工具。Python 也包含許多在 Linux 與 Mac 上常見（或容易安裝）的工具。

## 在 Windows 機器上特別實用

在 Windows 上使用 Python？或者在 Linux/Mac 上使用 Python，但無法輕易安裝 `uuid`、`sqlite3`、`gzip` 等常見命令列工具？

以下工具都相當於 Linux 上常見的命令列工具，不過 Linux 原生工具通常更強大也更好用。

| Command                 | Purpose                              | More                                                                          |
| ----------------------- | ------------------------------------ | ----------------------------------------------------------------------------- |
| `python3.12 -m uuid`    | 類似 `uuidgen` CLI 工具               | [Docs](https://docs.python.org/3/library/uuid.html#command-line-usage)        |
| `python3.12 -m sqlite3` | 類似 `sqlite3` CLI 工具               | [Docs](https://docs.python.org/3/library/sqlite3.html#command-line-interface) |
| `python -m zipfile`     | 類似 `zip` 與 `unzip` CLI 工具        | [Docs](https://docs.python.org/3/library/zipfile.html#command-line-interface) |
| `python -m gzip`        | 類似 `gzip` 與 `gunzip` CLI 工具      | [Docs](https://docs.python.org/3/library/gzip.html#command-line-interface)    |
| `python -m tarfile`     | 類似 `tar` CLI 工具                   | [Docs](https://docs.python.org/3/library/tarfile.html#command-line-interface) |
| `python -m base64`      | 類似 `base64` CLI 工具                |                                                                               |
| `python -m ftplib`      | 類似 `ftp` 工具                       |                                                                               |
| `python -m smtplib`     | 類似 `sendmail` 工具                  |                                                                               |
| `python -m poplib`      | 類似用 `curl` 讀取電子郵件            |                                                                               |
| `python -m imaplib`     | 類似用 `curl` 讀取電子郵件            |                                                                               |
| `python -m telnetlib`   | 類似 `telnet` 工具                    |                                                                               |

## 分析 Python 程式碼

Python 也內建一些專門用於分析 Python 程式碼的工具。

如果你想分析 Python 程式碼的運作方式，這些工具會很有幫助。

| Command              | Purpose                                | More                                                                          |
| -------------------- | -------------------------------------- | ----------------------------------------------------------------------------- |
| `python -m tokenize` | 將 Python 模組分解為 "tokens"         | [Docs](https://docs.python.org/3/library/tokenize.html#command-line-usage)    |
| `python -m ast`      | 顯示程式碼的抽象語法樹                  | [Docs](https://docs.python.org/3/library/ast.html#command-line-usage)         |
| `python -m dis`      | 將 Python 程式碼反組譯成 bytecode       | [Docs](https://docs.python.org/3/library/dis.html#command-line-interface)     |
| `python -m inspect`  | 檢視 Python 物件的原始碼               | [Docs](https://docs.python.org/3/library/inspect.html#command-line-interface) |
| `python -m pyclbr`   | 查看模組中物件的概覽                   |                                                                               |

## 只是好玩

這些是 Python 的彩蛋腳本。

| Command                 | Purpose                            |
| ----------------------- | ---------------------------------- |
| `python -m __hello__`   | 印出 `Hello world!`                |
| `python -m this`        | 顯示 Zen of Python (PEP 20)         |
| `python -m antigravity` | 在瀏覽器開啟 XKCD 353               |
| `python -m turtledemo`  | 顯示 `turtle` 模組示範              |
