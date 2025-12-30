---
title: "How to deal with a 50GB large csv file in r language?"
date: 2023-07-20T15:44:11+08:00
menu:
  sidebar:
    name: "How to deal with a 50GB large csv file in r language?"
    identifier: r-large-csv-file
    weight: 10
tags: ["URL", "R"]
categories: ["URL", "R"]
---

- [How to deal with a 50GB large csv file in r language?](https://stackoverflow.com/questions/39678940/how-to-deal-with-a-50gb-large-csv-file-in-r-language)

### question

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

### answer

```r
library(sqldf)

iris2 <- read.csv.sql("iris.csv",
    sql = "select * from file where Species = 'setosa' ")

```
