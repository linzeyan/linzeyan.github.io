---
title: "Google 搜尋運算子：完整清單（44 個進階運算子）"
date: 2020-08-14T14:21:06+08:00
menu:
  sidebar:
    name: "Google 搜尋運算子：完整清單（44 個進階運算子）"
    identifier: google-advanced-search-operators
    weight: 10
tags: ["Links", "Google"]
categories: ["Links", "Google"]
---

- [Google Search Operators: The Complete List (44 Advanced Operators)](https://ahrefs.com/blog/google-advanced-search-operators/)

#### 可用

| 搜尋運算子 | 用途 | 範例 |
| --------------- | ----------------------------------------------------------- | ------------------------- |
| `" "`           | 搜尋包含特定字詞或片語的結果。           | `"steve jobs"`            |
| `OR`            | 搜尋與 X 或 Y 相關的結果。                       | `jobs OR gates`           |
| `\|`            | 與 `OR` 相同。                                               | `jobs \| gates`           |
| `AND`           | 搜尋與 X 與 Y 相關的結果。                      | `jobs AND gates`          |
| `-`             | 排除包含特定字詞或片語的結果。     | `jobs -apple`             |
| `*`             | 萬用字元，可匹配任何字詞或片語。                       | `steve * apple`           |
| `( )`           | 將多個搜尋條件分組。                                    | `(ipad OR iphone) apple`  |
| `define:`       | 查詢字詞或片語的定義。              | `define:entrepreneur`     |
| `cache:`        | 查看網頁的最新快取版本。                    | `cache:apple.com`         |
| `filetype:`     | 搜尋特定檔案類型（例如 PDF）。           | `apple filetype:pdf`      |
| `ext:`          | 與 `filetype:` 相同。                                         | `apple ext:pdf`           |
| `site:`         | 只搜尋特定網站的結果。               | `site:apple.com`          |
| `related:`      | 搜尋與指定網域相關的網站。                 | `related:apple.com`       |
| `intitle:`      | 搜尋標題包含特定字詞的頁面。   | `intitle:apple`           |
| `allintitle:`   | 搜尋標題包含多個字詞的頁面。      | `allintitle:apple iphone` |
| `inurl:`        | 搜尋 URL 中包含特定字詞的頁面。         | `inurl:apple`             |
| `allinurl:`     | 搜尋 URL 中包含多個字詞的頁面。            | `allinurl:apple iphone`   |
| `intext:`       | 搜尋內容包含特定字詞的頁面。   | `intext:apple iphone`     |
| `allintext:`    | 搜尋內容包含多個字詞的頁面。  | `allintext:apple iphone`  |
| `weather:`      | 查詢某個地點的天氣。                       | `weather:san francisco`   |
| `stocks:`       | 查詢股票代碼的股價資訊。                  | `stocks:aapl`             |
| `map:`          | 強制顯示地圖結果。                           | `map:silicon valley`      |
| `movie:`        | 搜尋電影資訊。                       | `movie:steve jobs`        |
| `in`            | 單位換算。                                | `$329 in GBP`             |
| `source:`       | 在 Google 新聞中搜尋特定來源的結果。 | `apple source:the_verge`  |
| `before:`       | 搜尋特定日期之前的結果。           | `apple before:2007-06-29` |
| `after:`        | 搜尋特定日期之後的結果。            | `apple after:2007-06-29`  |

#### 不穩定

| 搜尋運算子 | 用途                                                                    | 範例                          |
| --------------- | ------------------------------------------------------------------------------- | -------------------------------- |
| `#..#`          | 搜尋數字範圍內的結果。                                               | `iphone case $50..$60`           |
| `inanchor:`     | 搜尋反向連結錨點文字包含特定字詞的頁面。                | `inanchor:apple`                 |
| `allinanchor:`  | 搜尋反向連結錨點文字包含多個字詞的頁面。 | `allinanchor:apple iphone`       |
| `AROUND(X)`     | 搜尋兩個字詞或片語在彼此 X 個字以內的頁面。       | `apple AROUND(4) iphone`         |
| `loc:`          | 搜尋指定地區的結果。                                                 | `loc:"san francisco" apple`      |
| `location:`     | 在 Google 新聞中搜尋特定地點的新聞。                               | `location:"san francisco" apple` |
| `daterange:`    | 搜尋特定日期範圍的結果。                                | `daterange:11278-13278`          |

#### 不可用（Google 已正式移除）

| 搜尋運算子    | 用途                                                                           | 範例                      |
| ------------------ | -------------------------------------------------------------------------------------- | ---------------------------- |
| `~`                | 包含同義詞（2013 已移除）。                                         | `~apple`                     |
| `+`                | 搜尋包含精確字詞或片語的結果（2011 已移除）。                  | `jobs +apple`                |
| `inpostauthor:`    | 在 Google Blog Search 中搜尋特定作者的文章（已停止）。            | `inpostauthor:"steve jobs"`  |
| `allinpostauthor:` | 與 `inpostauthor:` 相同，但不需要加引號。                              | `allinpostauthor:steve jobs` |
| `inposttitle:`     | 在已停用的 Google Blog Search 中搜尋標題包含特定字詞的文章。 | `inposttitle:apple iphone`   |
| `link:`            | 搜尋連到特定網域或 URL 的頁面（2017 已移除）。                 | `link:apple.com`             |
| `info:`            | 查詢特定頁面或網站的資訊（2017 已移除）。                 | `info:apple.com`             |
| `id:`              | 與 `info:` 相同。                                                                        | `id:apple.com`               |
| `phonebook:`       | 搜尋某人的電話號碼（2010 已移除）。                                      | `phonebook:tim cook`         |
| `#`                | 在 Google+ 上搜尋主題標籤（2019 已移除）。                                         | `#apple`                     |
