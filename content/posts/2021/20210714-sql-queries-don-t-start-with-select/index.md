---
title: "SQL queries don't start with SELECT"
date: 2021-07-14T18:11:46+08:00
menu:
  sidebar:
    name: "SQL queries don't start with SELECT"
    identifier: sql-queries-don-t-start-with-select
    weight: 10
tags: ["URL", "SQL"]
categories: ["URL", "SQL"]
---

- [SQL queries don't start with SELECT](https://jvns.ca/blog/2019/10/03/sql-queries-don-t-start-with-select/)

#### SQL queries happen in this order

- `FROM/JOIN` and all the `ON` conditions
- `WHERE`
- `GROUP BY`
- `HAVING`
- `SELECT` (including window functions)
- `ORDER BY`
- `LIMIT`
