---
title: "使用 Nginx 和 mod_pagespeed 自动将图片转换为 WebP 并输出"
date: 2019-10-07T10:35:22+08:00
menu:
  sidebar:
    name: "使用 Nginx 和 mod_pagespeed 自动将图片转换为 WebP 并输出"
    identifier: nginx-serve-webp-on-the-fly-with-nginx-and-mod-pagespeed
    weight: 10
tags: ["URL", "Nginx", "Webp"]
categories: ["URL", "Nginx", "Webp"]
hero: images/hero/nginx.jpeg
---

- [使用 Nginx 和 mod_pagespeed 自动将图片转换为 WebP 并输出](https://nova.moe/serve-webp-on-the-fly-with-nginx-and-mod_pagespeed/)

#### 编译 ngx_pagespeed

> 首先确保 Nginx 有 `--with-compat` 编译参数，这样我们就不需要按照一些奇怪的教程让大家从头开始编译 Nginx
>
> incubator: https://github.com/apache/incubator-pagespeed-ngx.git

```shell
# 切换到 nginx 源代码目录下开始配置编译环境
./configure --with-compat --add-dynamic-module=../incubator-pagespeed-ngx

# 编译 modules
make modules

# 将对应编译好的 module 放到 nginx 目录下：
sudo cp objs/ngx_pagespeed.so /etc/nginx/modules/

# 创建好缓存文件夹以便存放自动转换的图片
sudo mkdir -p /var/ngx_pagespeed_cache
sudo chown -R www-data:www-data /var/ngx_pagespeed_cache
```

```nginx
load_module modules/ngx_pagespeed.so;


# enable pagespeed module on this server block
pagespeed on;

# Needs to exist and be writable by nginx. Use tmpfs for best performance.
pagespeed FileCachePath /var/ngx_pagespeed_cache;

# Ensure requests for pagespeed optimized resources go to the pagespeed handler
# and no extraneous headers get set.
location ~ "\.pagespeed\.([a-z]\.)?[a-z]{2}\.[^.]{10}\.[^.]+" {
  add_header "" "";
}
location ~ "^/pagespeed_static/" { }
location ~ "^/ngx_pagespeed_beacon$" { }

pagespeed RewriteLevel CoreFilters;
```

其中最后一个部分（`pagespeed RewriteLevel CoreFilters;`）表示启用的优化方式，其中包括了一些基础的优化，比如

```
add_head
combine_css
combine_javascript
convert_meta_tags
extend_cache
fallback_rewrite_css_urls
flatten_css_imports
inline_css
inline_import_to_link
inline_javascript
rewrite_css
rewrite_images
rewrite_javascript
rewrite_style_attributes_with_url
```

如果需要加入别的 Filter ，可以类似这样写：

`pagespeed EnableFilters combine_css,extend_cache,rewrite_images;`

所有的 Filters 列表可以参考：[Configuring PageSpeed Filters](https://www.modpagespeed.com/doc/config_filters)，对于我们图片的转换的话，由于 PageSpeed 会自动判断是否需要转换，对于我们需要彻底转换 WebP 的需求，还需要加上几个 filter：

`pagespeed EnableFilters convert_png_to_jpeg,convert_jpeg_to_webp;`

#### 一些小问题

如果发现你的图片并没有自动被转换成 WebP 格式的话，可以在你的 URL 后面加上 `?PageSpeedFilters=+debug`，然后查看源代码，并注意源代码中图片后面的部分，在我配置的过程中遇到过以下问题：

##### 1

`<!--4xx status code, preventing rewriting of xxx` 由于手上 Wordpress 的机器都是放在 Docker 中，前置了 Cloudflare，所以默认的回源方式会出错，这个时候需要这样配置一下，其中 `localhost:2404` 是本地 Docker 监听地址：

```nginx
pagespeed MapOriginDomain "http://localhost:2404/" "https://nova.moe/";
```

##### 2

`<!--deadline_exceeded for filter CacheExtender--><!--deadline_exceeded for filter ImageRewrite-->`

这个表示 PageSpeed 正在生成对应的缓存图片

##### 3

`<!--The preceding resource was not rewritten because its domain (nova.moe) is not authorized-->`

由于有反向代理，SSL 在 Nginx 上就已经结束，需要配置一下代理中的：

```nginx
proxy_set_header X-Forwarded-Proto $scheme;
```

并加上：

```nginx
pagespeed RespectXForwardedProto on;
```
