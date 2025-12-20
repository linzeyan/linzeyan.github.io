---
title: "Nginx if 避坑指南"
date: 2024-06-15T19:55:10+08:00
menu:
  sidebar:
    name: "Nginx if 避坑指南"
    identifier: nginx-taoshu-if-is-evil
    weight: 10
tags: ["URL", "Nginx"]
categories: ["URL", "Nginx"]
hero: images/hero/nginx.jpeg
---

- [Nginx if 避坑指南](https://taoshu.in/nginx/if-is-evil.html)
- [If is Evil... when used in location context](https://archive.ph/hyEoc)

if 指令由 rewrite 模块提供，显然它主要是用于 URL 重写领域。典型的 if 用法如下：

```nginx
http {
  server {
    listen 8080;

    if ($http_user_agent ~ MSIE) {
      rewrite ^(.*)$ /msie/$1 break;
    }

    if ($request_method = POST) {
      return 405;
    }
  }
}
```

上例中第一个 if 检查如果 user agent 字符串中包含 MSIE，就把 URL 重写为 /msie 开头的路径，这样就可以给微软的 IE 浏览器提供特供版本内容。

第二个 if 检查当前请求的 HTTP 方法，如果是 POST 请求则直接返回 405 状态码。

以上就是 if 最典型的用法，也是 Nginx 最初设想的用法～但很快就被用户玩坏了 😂

天下苦静态配置久矣，Nginx 终于支持动态配置了 👏 这个 if 不就是 c 语言里的条件判断吗？大家玩起来 🎢

咱们先来个条件限速吧。如果请求参数 id 的值为 124 就限速 1k ～

```nginx
location /api {
    if ($args ~ id=124) {
        limit_rate 1k;
    }
}
```

So far so good😄 能不能再来点复杂的呢？比如下面这个：

```nginx
location /only-one-if {
    set $true 1;

    if ($true) {
        add_header X-First 1;
    }

    if ($true) {
        add_header X-Second 2;
    }

    return 204;
}
```

从配置上看，先设置了变量 `$true` 然后是两个 `if` 判断，如果 `$true` 不为零就各添加一个头字段～逻辑很清晰嘛 ☺️

但是实际运行就会发现，请求 /only-one-if 时的响应中只包含 X-Second 这个头字段。这就开始出现问题了。这是为什么呢？

简单来说每一个 if 判断都可以看成是一个特殊的 location 块。在 Nginx 中，所有的模块都会为每个 location 分配单独的内存来保存该模块对于当前 location 的特定配置信息。 Nginx 在处理请求的时候，会根据实际的路径来动态确定使用哪个配置。

在上面的例子中，因为两个 if 条件都满足，所以后一个 if 的 location 配置会**覆盖**前一个，自然就只有 `add_header X-Second 2` 生效了。

基于同样的原理，就可以解释以下诡异的行为。

发给上游的请求路径不会被改写成 /

```nginx
location /proxy-pass-uri {
    proxy_pass http://127.0.0.1:8080/;

    set $true 1;

    if ($true) {
        # nothing
    }
}
```

try_files 失效

```nginx
location /if-try-files {
     try_files  /file  @fallback;

     set $true 1;

     if ($true) {
         # nothing
     }
}
```

nginx 工作进程报 SIGSEGV 退出

```nginx
location /crash {

    set $true 1;

    if ($true) {
        # fastcgi_pass here
        fastcgi_pass  127.0.0.1:9000;
    }

    if ($true) {
        # no handler here
    }
}
```

if 块中创建的 location 块无法读取上面捕获的 $file 变量

```nginx
location ~* ^/if-and-alias/(?<file>.*) {
    alias /tmp/$file;

    set $true 1;

    if ($true) {
        # nothing
    }
}
```

以上种种问题都源于 if 对应的 block 配置没有继承所有的上级 location 配置信息。但像是 proxy_pass/try_files 这种模块又依赖这些信息，所以就会出现各种诡异的行为，甚至进程还会崩溃 😂

那怎样才能避免这类问题呢？上面的几个问题虽然跟 if 有关，但行为却各不相同。归根结底是因为不同的模块依赖不同的 location 配置，有的被 if 继承了，有的没继承，所以最终会产生什么结果谁也不知道。但有一点很明确，就是跟 rewrite 相关的配置肯定是没有问题的。所以说，要想避免问题，我们只能在 if 块中使用 return 和 rewrite，而且 rewrite 还得加上 last 参数。其他配置都有可能出现问题。

再一个就是避免在 if 中定义新的 location。可以使用 return + error_page 来实现跳转：

```nginx
location / {
    error_page 418 = @other;
    recursive_error_pages on;

    if ($something) {
        return 418;
    }

    # some configuration
}

location @other {
    return 200 error;
}
```
