---
title: "OpenResty + Redis: Block High-Frequency IPs"
date: 2019-06-27T11:18:46+08:00
menu:
  sidebar:
    name: "OpenResty + Redis: Block High-Frequency IPs"
    identifier: nginx-openresty-redis-block-high-freq-ip
    weight: 10
tags: ["Links", "OpenResty", "Redis", "Lua"]
categories: ["Links", "OpenResty", "Redis", "Lua"]
hero: images/hero/nginx.jpeg
---

- [OpenResty + Redis: Block High-Frequency IPs](https://www.centos.bz/2018/11/openrestyredis%E6%8B%A6%E6%88%AA%E9%AB%98%E9%A2%91%E8%AE%BF%E9%97%AEip/)

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

-- If the Redis connection fails, stop blocking (allow traffic)
if pcall(isConnected) then
    -- already connected (or ping succeeded)
else
    -- not connected; try reconnect
    if pcall(createRedisConnection) then
        -- Reconnect: this will reconnect Redis on every request
        -- For high traffic, consider disabling reconnect (skip pcall), and allow/terminate directly via ngx.exit
        client = createRedisConnection()
    else
        ngx.exit(ngx.OK)
    end
end

local ttl = 60         -- sampling window (seconds)
local bktimes = 30     -- requests within window to trigger block
local block_ttl = 600  -- block duration after trigger (seconds)

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
