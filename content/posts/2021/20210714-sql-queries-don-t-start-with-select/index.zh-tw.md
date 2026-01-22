---
title: "SQL 查詢不是從 SELECT 開始"
date: 2021-07-14T18:11:46+08:00
menu:
  sidebar:
    name: "SQL 查詢不是從 SELECT 開始"
    identifier: sql-queries-don-t-start-with-select
    weight: 10
tags: ["Links", "SQL"]
categories: ["Links", "SQL"]
---

- [SQL 查詢不是從 SELECT 開始](https://jvns.ca/blog/2019/10/03/sql-queries-don-t-start-with-select/)

#### SQL 查詢實際執行順序

- `FROM/JOIN` 以及所有 `ON` 條件
- `WHERE`
- `GROUP BY`
- `HAVING`
- `SELECT`（包含視窗函式）
- `ORDER BY`
- `LIMIT`
