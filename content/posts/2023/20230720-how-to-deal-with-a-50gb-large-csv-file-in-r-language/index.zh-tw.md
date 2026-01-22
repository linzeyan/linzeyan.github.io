---
title: "如何處理 50GB 的大型 CSV 檔案（R 語言）？"
date: 2023-07-20T15:44:11+08:00
menu:
  sidebar:
    name: "如何處理 50GB 的大型 CSV 檔案（R 語言）？"
    identifier: r-large-csv-file
    weight: 10
tags: ["Links", "R"]
categories: ["Links", "R"]
---

- [如何處理 50GB 的大型 CSV 檔案（R 語言）？](https://stackoverflow.com/questions/39678940/how-to-deal-with-a-50gb-large-csv-file-in-r-language)

### 問題

```r
all <- read.csv.ffdf(
  file="<path of large file>",
  sep = ",",
  header=TRUE,
  VERBOSE=TRUE,
  first.rows=10000,
  next.rows=50000,
  )
```

### 回答

```r
library(sqldf)

iris2 <- read.csv.sql("iris.csv",
    sql = "select * from file where Species = 'setosa' ")

```
