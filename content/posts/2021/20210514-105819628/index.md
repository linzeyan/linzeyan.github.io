---
title: "Nginx request_time and upstream_response_time explained"
date: 2021-05-14T16:04:04+08:00
menu:
  sidebar:
    name: "Nginx request_time and upstream_response_time explained"
    identifier: nginx-time-definition-and-detail
    weight: 10
tags: ["Links", "Nginx"]
categories: ["Links", "Nginx"]
hero: images/hero/nginx.jpeg
---

- [Nginx request_time and upstream_response_time explained](https://blog.csdn.net/zzhongcy/article/details/105819628)

### Time definitions

**request_time**

Time from the first byte of the client request to the completion of response data being sent. `$request_time` includes time to receive the request, time for the upstream to respond, and time to send the response (excluding log write time).

**upstream_response_time**

Time from Nginx establishing a connection to the upstream until all data is received and the connection is closed.

**upstream_connect_time**

Time to connect to the upstream server. If using an encrypted protocol, this includes handshake time.

**upstream_header_time**

Time to receive the upstream response headers.

If we break the flow down:

`[1 client request] [2 connect to Nginx] [3 send response] [4 receive response] [5 close Nginx connection]`

- `upstream_response_time` is `2+3+4+5`
- In practice, `[5 close Nginx connection]` is close to 0
- So `upstream_response_time` is effectively `2+3+4`
- `request_time` is `1+2+3+4`
- The difference is the `[1 client request]` time

#### upstream_response_time greater than request_time

> https://forum.nginx.org/read.php?21,284448,284450#msg-284450

`$upstream_response_time` is calculated with `clock_gettime(CLOCK_MONOTONIC_COARSE)` and can be 4 ms behind by default. In contrast, `$request_time` is calculated with `gettimeofday()`. So upstream_response_time can end up larger than response_time.
