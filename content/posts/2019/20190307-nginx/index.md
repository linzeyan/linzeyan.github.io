---
title: "Do you understand the Nginx request processing flow?"
date: 2019-03-07T14:05:55+08:00
menu:
  sidebar:
    name: "Do you understand the Nginx request processing flow?"
    identifier: nginx-request-processing-flow
    weight: 10
tags: ["Links", "Nginx"]
categories: ["Links", "Nginx"]
hero: images/hero/nginx.jpeg
---

- [Do you understand the Nginx request processing flow?](https://mp.weixin.qq.com/s/otQIhuLABU3omOLtRfJnZQ)

### 11 processing phases

1) NGX_HTTP_POST_READ_PHASE:

A phase after receiving the full HTTP headers. It is before URI rewrite. Very few modules register in this phase, and it is skipped by default.

2) NGX_HTTP_SERVER_REWRITE_PHASE:

The phase that modifies the URI before matching the location, used for redirects. This is where rewrite directives in the server block but outside location are executed. While reading request headers, nginx selects the virtual host by host and port.

3) NGX_HTTP_FIND_CONFIG_PHASE:

Find the matching location configuration based on the URI. This phase uses the rewritten URI to find the location. Note that it can run multiple times because there may be location-level rewrite directives.

4) NGX_HTTP_REWRITE_PHASE:

Rewrite the URI after the location is found. This is the location-level rewrite phase, and it can run multiple times.

5) NGX_HTTP_POST_REWRITE_PHASE:

Prevents rewrite loops after URL rewriting. It checks whether the URI was rewritten in the previous phase and jumps to the right phase.

6) NGX_HTTP_PREACCESS_PHASE:

Preparation before the next phase, the pre-access control phase. It is often used for access control such as rate limiting or connection limits.

7) NGX_HTTP_ACCESS_PHASE:

Access control phase. HTTP modules decide whether the request is allowed, such as IP allow/deny lists or username/password authentication.

8) NGX_HTTP_POST_ACCESS_PHASE:

Post-access control phase. It handles the result of access control and sends rejection error codes when access is denied.

9) NGX_HTTP_TRY_FILES_PHASE:

Phase for serving static resources. It handles try_files directives. If try_files is not configured, this phase is skipped.

10) NGX_HTTP_CONTENT_PHASE:

Content phase. Most HTTP modules run here, generating content and sending responses to clients.

11) NGX_HTTP_LOG_PHASE:

Logging phase after the request is processed. This phase records access logs.

Among these 11 phases, HTTP modules cannot hook into 4 phases:

3) NGX_HTTP_FIND_CONFIG_PHASE

5) NGX_HTTP_POST_REWRITE_PHASE

8) NGX_HTTP_POST_ACCESS_PHASE

9) NGX_HTTP_TRY_FILES_PHASE

The remaining 7 phases can be hooked by HTTP modules, with no limit on the number of modules per phase. Multiple HTTP modules can hook into the same phase and act on the same request.

### Lua 8 phases

init_by_lua http
set_by_lua server, server if, location, location if
rewrite_by_lua http, server, location, location if
access_by_lua http, server, location, location if
content_by_lua location, location if
header_filter_by_lua http, server, location, location if
body_filter_by_lua http, server, location, location if
log_by_lua http, server, location, location if

1) init_by_lua:

Runs Lua scripts when nginx reloads configuration. It is commonly used to allocate global variables (for example, lua_shared_dict shared memory). Shared memory data is cleared only after nginx restarts, which is useful for statistics.

2) set_by_lua:

Used for control flow and variable initialization (set a variable, compute a value, and return). This phase cannot run Output API, Control API, Subrequest API, or Cosocket API.

3) rewrite_by_lua:

Forwarding, redirects, caching, etc. (for example, proxying specific requests to external networks). It runs before the access phase and is mainly for rewrite.

4) access_by_lua:

Central handling for IP admission and API authorization (for example, simple firewall with iptables). It is mainly for access control and can collect most variables; some fields like status are only available in the log phase. This directive runs at the end of the nginx access phase, so it always runs after allow/deny directives.

5) content_by_lua:

Content generation. This is the most important phase among all request phases. Directives in this phase are responsible for generating content and sending HTTP responses.

6) header_filter_by_lua:

Response header filtering, usually used for setting cookies and headers. This phase cannot run Output API, Control API, Subrequest API, or Cosocket API (for example, adding header info).

7) body_filter_by_lua:

Response body filtering (for example, converting response content to uppercase). It is often called multiple times in a single request due to HTTP/1.1 chunked streaming output. This phase cannot run Output API, Control API, Subrequest API, or Cosocket API.

8) log_by_lua:

Asynchronous logging after the session completes (logs can be written locally or synced to other machines). It runs at request end and is used for post-request actions such as collecting stats in shared memory. For high-precision stats, body_filter_by_lua is preferred. This phase cannot run Output API, Control API, Subrequest API, or Cosocket API.

### Mapping between nginx and Lua phases

1) init_by_lua runs in the initialization phase.

2) set_by_lua runs in the rewrite phase.

     The set directive comes from ngx_rewrite and runs in the rewrite phase.

3) rewrite_by_lua comes from ngx_lua and runs at the end of the rewrite phase.

4) access_by_lua also comes from ngx_lua and runs at the end of the access phase.

     The deny directive comes from ngx_access and runs in the access phase.

5) content_by_lua comes from ngx_lua and runs in the content phase. Do not use it with other content handlers in the same location, such as proxy_pass.

      The echo directive comes from ngx_echo and runs in the content phase.

6) header_filter_by_lua runs in the content phase. output-header-filter is usually used to set cookies and headers.

7) body_filter_by_lua runs in the content phase.

8) log_by_lua runs in the log phase.

![](./nginx_phase.webp)
