---
title: "openresty+redis拦截高频访问IP"
date: 2019-06-27T11:18:46+08:00
menu:
  sidebar:
    name: "openresty+redis拦截高频访问IP"
    identifier: nginx-openresty-redis-block-high-freq-ip
    weight: 10
tags: ["URL", "OpenResty", "Redis", "Lua"]
categories: ["URL", "OpenResty", "Redis", "Lua"]
hero: images/hero/nginx.jpeg
---

- [openresty+redis 拦截高频访问 IP](https://www.centos.bz/2018/11/openrestyredis%E6%8B%A6%E6%88%AA%E9%AB%98%E9%A2%91%E8%AE%BF%E9%97%AEip/)

```nginx
init_by_lua_block {
    redis = require "redis"
    client = redis.connect('127.0.0.1', 6379)
}
server {
    listen 8080;
    location  / {
        access_by_lua_file /usr/local/nginx/conf/lua/block.lua;
        proxy_pass http://192.168.1.102:8000;
    }
}
```

```lua
-- Redis-based IP rate limiting / blocking for OpenResty (ngx_lua)

-- NOTE:
-- This script assumes a global `client` variable is used/stored.
-- Make sure `redis` module is available and `client` is initialized somewhere.

local function isConnected()
    return client:ping()
end

local function createRedisConnection()
    return redis.connect("127.0.0.1", 6379)
end

-- 如果发生 redis 连接失败，将停止拦截（直接放行）
if pcall(isConnected) then
    -- already connected (or ping succeeded)
else
    -- not connected; try reconnect
    if pcall(createRedisConnection) then
        -- 断开重连：会导致每次访问都需要重连 redis
        -- 访问量大时建议：关闭重连逻辑（pcall 不执行），直接 ngx.exit 放行/终止
        client = createRedisConnection()
    else
        ngx.exit(ngx.OK)
    end
end

local ttl = 60         -- 监测周期（秒）
local bktimes = 30     -- 在监测周期内达到触发拦截的访问量
local block_ttl = 600  -- 触发拦截后拦截时间（秒）

local ip = ngx.var.remote_addr
local ipvtimes = client:get(ip)

if ipvtimes then
    if ipvtimes == "-1" then
        -- blocked
        return ngx.exit(403)
    else
        local last_ttl = client:ttl(ip)
        -- ngx.say("key exist.ttl is ", last_ttl)

        if last_ttl == -1 then
            client:set(ip, 0)
            client:expire(ip, ttl)
            -- ngx.say("ttl & vtimes recount")
            return ngx.exit(ngx.OK)
        end

        local vtimes = tonumber(client:get(ip)) + 1

        if vtimes < bktimes then
            client:set(ip, vtimes)
            client:expire(ip, last_ttl)
            -- ngx.say(ip, " view ", vtimes, " times")
            return ngx.exit(ngx.OK)
        else
            -- ngx.say(ip, " will be block next time.")
            client:set(ip, -1)
            client:expire(ip, block_ttl)
            return ngx.exit(ngx.OK)
        end
    end
else
    -- key does not exist
    client:set(ip, 1)
    -- ngx.say(ip, " view 1 times")
    client:expire(ip, ttl)
    return ngx.exit(ngx.OK)
end
```
