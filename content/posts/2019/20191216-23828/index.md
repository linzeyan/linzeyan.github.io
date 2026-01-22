---
title: "Golang Service Exceeded File Handle Limit (too many open files)"
date: 2019-12-16T10:14:33+08:00
menu:
  sidebar:
    name: "Golang Service Exceeded File Handle Limit (too many open files)"
    identifier: golang-service-has-exceeded-the-system-limit-for-file-handles-too-many-open-files
    weight: 10
tags: ["Links", "Go"]
categories: ["Links", "Go"]
hero: images/hero/go.svg
---

- [Golang Service Exceeded File Handle Limit (too many open files)](https://studygolang.com/articles/23828)

1. Check system config: `ulimit -a | grep open`. The system config is normal.

2. Check the service file limit: `cat /proc/40636/limits`. The service did not inherit the system settings and is still limited to 1024.

3. Check open file count: `lsof -p 40636 | wc -l`. It exceeds the limit, so the error occurs.

4. Check which connections are open: `lsof -p 40636 > openfiles.log`. Many HTTP connections were left open to the alerting service. The root cause is that the app failed to parse config, sent errors to the alerting service, and did not close connections, leading to too many open files. Why it did not inherit system limits needed more investigation.

5. Final cause: the service is managed by supervisor. The default minfds is 1024. Add `minfds=81920` to supervisor config and run `supervisorctl reload`.
