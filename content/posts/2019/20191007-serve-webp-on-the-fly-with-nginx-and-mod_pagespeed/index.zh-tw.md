---
title: "使用 Nginx 和 mod_pagespeed 自動將圖片轉換為 WebP 並輸出"
date: 2019-10-07T10:35:22+08:00
menu:
  sidebar:
    name: "使用 Nginx 和 mod_pagespeed 自動將圖片轉換為 WebP 並輸出"
    identifier: nginx-serve-webp-on-the-fly-with-nginx-and-mod-pagespeed
    weight: 10
tags: ["Links", "Nginx", "Webp"]
categories: ["Links", "Nginx", "Webp"]
hero: images/hero/nginx.jpeg
---

- [使用 Nginx 和 mod_pagespeed 自動將圖片轉換為 WebP 並輸出](https://nova.moe/serve-webp-on-the-fly-with-nginx-and-mod_pagespeed/)

#### 編譯 ngx_pagespeed

> 首先確保 Nginx 有 `--with-compat` 編譯參數，這樣就不需要按照一些奇怪的教學讓大家從頭開始編譯 Nginx
>
> incubator: https://github.com/apache/incubator-pagespeed-ngx.git

```shell
# 切換到 nginx 原始碼目錄下開始設定編譯環境
./configure --with-compat --add-dynamic-module=../incubator-pagespeed-ngx

# 編譯 modules
make modules

# 將編譯好的 module 放到 nginx 目錄下
sudo cp objs/ngx_pagespeed.so /etc/nginx/modules/

# 建立快取資料夾以存放自動轉換的圖片
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

其中最後一段（`pagespeed RewriteLevel CoreFilters;`）表示啟用的最佳化方式，包含一些基礎的最佳化，例如：

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

如果需要加入其他 Filter，可以這樣寫：

`pagespeed EnableFilters combine_css,extend_cache,rewrite_images;`

所有 Filter 的列表可參考：[Configuring PageSpeed Filters](https://www.modpagespeed.com/doc/config_filters)。針對圖片轉換，PageSpeed 會自動判斷是否需要轉換；若需要徹底轉成 WebP，還需要加上幾個 filter：

`pagespeed EnableFilters convert_png_to_jpeg,convert_jpeg_to_webp;`

#### 一些小問題

如果發現圖片沒有自動被轉成 WebP 格式，可以在 URL 後面加上 `?PageSpeedFilters=+debug`，然後查看原始碼，並注意圖片後面的內容。在配置過程中遇到的問題如下：

##### 1

`<!--4xx status code, preventing rewriting of xxx` 由於手上的 Wordpress 機器都放在 Docker 中，前置了 Cloudflare，所以預設的回源方式會出錯。這時需要這樣設定，其中 `localhost:2404` 是本地 Docker 監聽位址：

```nginx
pagespeed MapOriginDomain "http://localhost:2404/" "https://nova.moe/";
```

##### 2

`<!--deadline_exceeded for filter CacheExtender--><!--deadline_exceeded for filter ImageRewrite-->`

這表示 PageSpeed 正在生成對應的快取圖片。

##### 3

`<!--The preceding resource was not rewritten because its domain (nova.moe) is not authorized-->`

由於有反向代理，SSL 在 Nginx 上就已經結束，需要在代理設定中加入：

```nginx
proxy_set_header X-Forwarded-Proto $scheme;
```

並加上：

```nginx
pagespeed RespectXForwardedProto on;
```
