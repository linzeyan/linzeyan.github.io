---
title: "nginx 添加第三方nginx_upstream_check_module 模块实现健康状态检测"
date: 2020-04-26T20:05:37+08:00
menu:
  sidebar:
    name: "nginx 添加第三方nginx_upstream_check_module 模块实现健康状态检测"
    identifier: nginx-add-third-party-module-nginx_upstream_check_module
    weight: 10
tags: ["URL", "Nginx"]
categories: ["URL", "Nginx"]
hero: images/hero/nginx.jpeg
---

- [nginx 添加第三方 nginx_upstream_check_module 模块实现健康状态检测](https://www.cnblogs.com/dance-walter/p/12212607.html)
- [nginx_upstream_check_module Health check HTTP servers inside an upstream](https://github.com/yaoweibin/nginx_upstream_check_modue)

**nginx.conf**

```nginx
    http {
        upstream cluster {
            # simple round-robin
            server 192.168.0.1:80;
            server 192.168.0.2:80;

            check interval=5000 rise=1 fall=3 timeout=4000;
            #check interval=3000 rise=2 fall=5 timeout=1000 type=ssl_hello;
            #check interval=3000 rise=2 fall=5 timeout=1000 type=http;
            #check_http_send "HEAD / HTTP/1.0\r\n\r\n";
            #check_http_expect_alive http_2xx http_3xx;
        }
...

```

```nginx
  check
    syntax: *check interval=milliseconds [fall=count] [rise=count]
    [timeout=milliseconds] [default_down=true|false]
    [type=tcp|http|ssl_hello|mysql|ajp|fastcgi]*

   默认配置：interval=3000 fall=5 rise=2 timeout=1000 default_down=true type=tcp*
...
```

- interval： 检测间隔 3 秒
- fall: 连续检测失败次数 5 次时，认定 relaserver is down
- rise: 连续检测成功 2 次时，认定 relaserver is up
- timeout: 超时 1 秒
- default_down: 初始状态为 down,只有检测通过后才为 up
- type: 检测类型方式 tcp
  1. tcp :tcp 套接字,不建议使用，后端业务未 100%启动完成,前端已经放开访问的情况
  2. ssl_hello： 发送 hello 报文并接收 relaserver 返回的 hello 报文
  3. http: 自定义发送一个请求，判断上游 relaserver 接收并处理
  4. mysql: 连接到 mysql 服务器，判断上游 relaserver 是否还存在
  5. ajp: 发送 AJP Cping 数据包，接收并解析 AJP Cpong 响应以诊断上游 relaserver 是否还存活(AJP tomcat 内置的一种协议)
  6. fastcgi: php 程序是否存活

**example**

```nginx
upstream cluster {
  server 192.168.20.12:80;
  server 192.168.20.3:80;     #未启动web服务，默认为down

  check interval=3000 rise=2 fall=3 timeout=1000 type=http;
  check_http_send "GET /index.html HTTP/1.0\r\n\r\n";   #获取后端资源，资源变动后，经历三次检查周期后立即将状态改为down
  check_http_expect_alive  http_2xx http_3xx ; #check_http_send 返回状态码，2xx和3xx为默认值。
}

server {
        listen 80;
        location / {
            proxy_pass http://cluster;
        }
        location = /status {
            check_status;
            #allow xxx;
            #deny all;
       }
}
```
