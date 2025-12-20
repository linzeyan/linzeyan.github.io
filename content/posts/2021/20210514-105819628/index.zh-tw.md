---
title: "Nginx - request_time和upstream_response_time详解"
date: 2021-05-14T16:04:04+08:00
menu:
  sidebar:
    name: "Nginx - request_time和upstream_response_time详解"
    identifier: nginx-time-definition-and-detail
    weight: 10
tags: ["URL", "Nginx"]
categories: ["URL", "Nginx"]
hero: images/hero/nginx.jpeg
---

- [Nginx - request_time 和 upstream_response_time 详解](https://blog.csdn.net/zzhongcy/article/details/105819628)

### time definition

**request_time**

从接受用户请求的第一个字节到发送完响应数据的时间，即`$request_time` 包括接收客户端请求数据的时间、后端程序响应的时间、发送响应数据给客户端的时间(不包含写日志的时间)。

**upstream_response_time**

从 Nginx 向后端建立连接开始到接受完数据然后关闭连接为止的时间

**upstream_connect_time**

跟后端 server 建立连接的时间，如果是到后端使用了加密的协议，该时间将包括握手的时间。

**upstream_header_time**

接收后端 server 响应头的时间

如果把整个过程补充起来的话 应该是：

`［1用户请求］［2建立 Nginx 连接］［3发送响应］［4接收响应］［5关闭  Nginx 连接］`

- 那么 `upstream_response_time` 就是 `2+3+4+5`
- 但是 一般这里面可以认为 `［5关闭 Nginx 连接］` 的耗时接近 0
- 所以 `upstream_response_time` 实际上就是 `2+3+4`
- 而 `request_time` 是 `1+2+3+4`
- 二者之间相差的就是 `［1用户请求］`的时间。

#### upstream_response_time 比 request_time 大

> https://forum.nginx.org/read.php?21,284448,284450#msg-284450

`$upstream_response_time` 由 `clock_gettime(CLOCK_MONOTONIC_COARSE)`计算，默认情况下，它可以过去 4 毫秒，相反，`$request_time` 由 `gettimeofday()`计算。 所以最终 upstream_response_time 可能比 response_time 更大。
