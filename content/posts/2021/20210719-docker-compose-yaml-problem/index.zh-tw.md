---
title: "docker-compose yaml problem"
date: 2021-07-19T15:40:36+08:00
menu:
  sidebar:
    name: "docker-compose yaml problem"
    identifier: docker-compose-yaml-problem-port-mapping
    weight: 10
tags: ["Docker"]
categories: ["Docker"]
hero: images/hero/docker.jpeg
---

#### issue

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

YAML supports so-called "base-60 floating-point numbers," which is useful for time calculations.

Therefore, `2222:22` is interpreted as `2222 * 60 + 22`, which is 133342.

If the port contains numbers greater than 60, such as 3306:3306 or 8080:80, there is no problem, so this issue doesn't always occur, making it somewhat obscure.

#### solve

```yaml
services:
  gogs:
    ports:
      - "2222:22"
```
