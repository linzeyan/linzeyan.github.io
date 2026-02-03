---
title: "Selectively Disabling HTTP/1.0 and HTTP/1.1"
date: 2026-02-03T09:41:12+08:00
menu:
  sidebar:
    name: "Selectively Disabling HTTP/1.0 and HTTP/1.1"
    identifier: nginx-selectively-disabling-http-1
    weight: 10
tags: ["Links", "Nginx"]
categories: ["Links", "Nginx"]
hero: images/hero/nginx.jpeg
---

- [Selectively Disabling HTTP/1.0 and HTTP/1.1](https://markmcb.com/web/selectively_disabling_http_1/)

```nginx
http {

    ...

    # Check for text-based browsers
    map $http_user_agent $is_text_browser {
        default 0;

        # Text-Based Browsers (not exhaustive)
        "~*^w3m" 1;
        "~*^Links" 1;
        "~*^ELinks" 1;
        "~*^lynx" 1;

        # Bots (not exhaustive)
        "~*Googlebot" 1;
        "~*bingbot" 1;
        "~*Yahoo! Slurp" 1;
        "~*DuckDuckBot" 1;
        "~*YandexBot" 1;
        "~*Kagibot" 1;
    }

    # Check if request is HTTP/1.X
    map $server_protocol $is_http1 {
        default 0;
        "HTTP/1.0" 1;
        "HTTP/1.1" 1;
    }

    # If Request is not text-based browser,
    # and is HTTP/1.X, set the http1_and_unknown variable
    # to 1, which is equivalent to "true"
    map "$is_http1:$is_text_browser" $http1_and_unknown {
        default 0;
        "1:0" 1;
    }

    ...

}
```
