---
title: "docker-compose yaml 問題"
date: 2021-07-19T15:40:36+08:00
menu:
  sidebar:
    name: "docker-compose yaml 問題"
    identifier: docker-compose-yaml-problem-port-mapping
    weight: 10
tags: ["Docker"]
categories: ["Docker"]
hero: images/hero/docker.jpeg
---

#### 問題

```shell
# ./docker-compose up -d
Creating network "gogs_default" with the default driver
Creating gogs_mysql_1 ... done
Creating gogs_gogs_1  ... error

ERROR: for gogs_gogs_1  Cannot create container for service gogs: invalid port specification: "133342"

ERROR: for gogs  Cannot create container for service gogs: invalid port specification: "133342"
ERROR: Encountered errors while bringing up the project.
```

```yaml
services:
  gogs:
    ports:
      - 2222:22
```

YAML 支援所謂的「六十進位浮點數」，這對時間計算很有用。

因此，`2222:22` 會被解讀為 `2222 * 60 + 22`，也就是 133342。

如果連接埠包含大於 60 的數字，例如 3306:3306 或 8080:80，就不會有問題，所以這個問題不一定會出現，因而比較不容易察覺。

#### 解法

```yaml
services:
  gogs:
    ports:
      - "2222:22"
```
