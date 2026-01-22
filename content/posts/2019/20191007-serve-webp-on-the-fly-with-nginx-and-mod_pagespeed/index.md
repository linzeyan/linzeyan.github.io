---
title: "Use Nginx and mod_pagespeed to Convert Images to WebP on the Fly"
date: 2019-10-07T10:35:22+08:00
menu:
  sidebar:
    name: "Use Nginx and mod_pagespeed to Convert Images to WebP on the Fly"
    identifier: nginx-serve-webp-on-the-fly-with-nginx-and-mod-pagespeed
    weight: 10
tags: ["Links", "Nginx", "Webp"]
categories: ["Links", "Nginx", "Webp"]
hero: images/hero/nginx.jpeg
---

- [Use Nginx and mod_pagespeed to Convert Images to WebP on the Fly](https://nova.moe/serve-webp-on-the-fly-with-nginx-and-mod_pagespeed/)

#### Compile ngx_pagespeed

> First make sure Nginx is built with `--with-compat`, so we do not need to rebuild Nginx from scratch.
>
> incubator: https://github.com/apache/incubator-pagespeed-ngx.git

```shell
# Switch to the nginx source directory and configure the build
./configure --with-compat --add-dynamic-module=../incubator-pagespeed-ngx

# Build modules
make modules

# Copy the built module into the nginx modules directory
sudo cp objs/ngx_pagespeed.so /etc/nginx/modules/

# Create the cache directory for converted images
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

The last line (`pagespeed RewriteLevel CoreFilters;`) specifies the enabled optimizations. It includes basic filters such as:

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

To enable additional filters, do something like this:

`pagespeed EnableFilters combine_css,extend_cache,rewrite_images;`

A full list is in [Configuring PageSpeed Filters](https://www.modpagespeed.com/doc/config_filters). For image conversion, PageSpeed decides whether to convert. If you need full WebP conversion, add these filters:

`pagespeed EnableFilters convert_png_to_jpeg,convert_jpeg_to_webp;`

#### Common issues

If images are not converted to WebP, append `?PageSpeedFilters=+debug` to your URL, check the page source, and look for the text after the image. I ran into the following issues:

##### 1

`<!--4xx status code, preventing rewriting of xxx` Because the Wordpress machines are running in Docker behind Cloudflare, the default origin mapping fails. Configure it like this, where `localhost:2404` is the local Docker endpoint:

```nginx
pagespeed MapOriginDomain "http://localhost:2404/" "https://nova.moe/";
```

##### 2

`<!--deadline_exceeded for filter CacheExtender--><!--deadline_exceeded for filter ImageRewrite-->`

This means PageSpeed is generating cache images.

##### 3

`<!--The preceding resource was not rewritten because its domain (nova.moe) is not authorized-->`

Because SSL terminates at Nginx with a reverse proxy, set this in the proxy config:

```nginx
proxy_set_header X-Forwarded-Proto $scheme;
```

And add:

```nginx
pagespeed RespectXForwardedProto on;
```
