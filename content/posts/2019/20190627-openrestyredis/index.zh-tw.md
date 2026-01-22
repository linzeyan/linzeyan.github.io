---
title: "openresty+redis 攔截高頻訪問 IP"
date: 2019-06-27T11:18:46+08:00
menu:
  sidebar:
    name: "openresty+redis 攔截高頻訪問 IP"
    identifier: nginx-openresty-redis-block-high-freq-ip
    weight: 10
tags: ["Links", "OpenResty", "Redis", "Lua"]
categories: ["Links", "OpenResty", "Redis", "Lua"]
hero: images/hero/nginx.jpeg
---

- [openresty+redis 攔截高頻訪問 IP](https://www.centos.bz/2018/11/openrestyredis%E6%8B%A6%E6%88%AA%E9%AB%98%E9%A2%91%E8%AE%BF%E9%97%AEip/)

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

-- 如果發生 redis 連線失敗，將停止攔截（直接放行）
if pcall(isConnected) then
    -- already connected (or ping succeeded)
else
    -- not connected; try reconnect
    if pcall(createRedisConnection) then
        -- 斷開重連：會導致每次訪問都需要重連 redis
        -- 訪問量大時建議：關閉重連邏輯（pcall 不執行），直接 ngx.exit 放行/終止
        client = createRedisConnection()
    else
        ngx.exit(ngx.OK)
    end
end

local ttl = 60         -- 監測週期（秒）
local bktimes = 30     -- 在監測週期內達到觸發攔截的訪問量
local block_ttl = 600  -- 觸發攔截後攔截時間（秒）

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
