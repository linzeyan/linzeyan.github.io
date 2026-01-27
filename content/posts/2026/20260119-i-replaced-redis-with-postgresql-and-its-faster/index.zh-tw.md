---
title: "I Replaced Redis with PostgreSQL (And It's Faster)"
date: 2026-01-19T15:45:23+08:00
menu:
  sidebar:
    name: "I Replaced Redis with PostgreSQL (And It's Faster)"
    identifier: database-postgresql-i-replaced-redis-with-postgresql-and-its-faster
    weight: 10
tags: ["Links", "Database", "PostgreSQL"]
categories: ["Links", "Database", "PostgreSQL"]
---

- [I Replaced Redis with PostgreSQL (And It's Faster)](https://dev.to/polliog/i-replaced-redis-with-postgresql-and-its-faster-4942)

### 在更改之前，Redis 主要處理三件事：

1. 快取（佔使用量的 70%）
2. 發布/訂閱（佔使用量的 20%）
3. 後台作業佇列（使用率 10%）

**_痛點:_**

- 需要備份兩個資料庫
- Redis 使用記憶體（規模化時成本很高）
- Redis 持久化機制…很複雜。
- Postgres 和 Redis 之間的網路跳躍

### PostgreSQL 功能

##### 1: 使用未記錄表進行快取

**_Redis_**

```javascript
await redis.set("session:abc123", JSON.stringify(sessionData), "EX", 3600);
```

**_PostgreSQL_**

```sql
CREATE UNLOGGED TABLE cache (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_cache_expires ON cache(expires_at);
```

**Insert**

```sql
INSERT INTO cache (key, value, expires_at)
VALUES ($1, $2, NOW() + INTERVAL '1 hour')
ON CONFLICT (key) DO UPDATE
  SET value = EXCLUDED.value,
      expires_at = EXCLUDED.expires_at;
```

**Read**

```sql
SELECT value FROM cache
WHERE key = $1 AND expires_at > NOW();
```

**Cleanup (run periodically)**

```sql
DELETE FROM cache WHERE expires_at < NOW();
```

##### 2: 附有 LISTEN/NOTIFY 的發布/訂閱

**_Redis 發佈/訂閱_**

```javascript
// Publisher
redis.publish("notifications", JSON.stringify({ userId: 123, msg: "Hello" }));

// Subscriber
redis.subscribe("notifications");
redis.on("message", (channel, message) => {
	console.log(message);
});
```

**_PostgreSQL 發佈/訂閱_**

```sql
-- Publisher
NOTIFY notifications, '{"userId": 123, "msg": "Hello"}';
```

```javascript
// Subscriber (Node.js with pg)
const client = new Client({ connectionString: process.env.DATABASE_URL });
await client.connect();

await client.query("LISTEN notifications");

client.on("notification", (msg) => {
	const payload = JSON.parse(msg.payload);
	console.log(payload);
});
```

##### 3：帶有 SKIP LOCKED 的作業佇列

**_Redis（使用 Bull/BullMQ）_**

```javascript
queue.add("send-email", { to, subject, body });

queue.process("send-email", async (job) => {
	await sendEmail(job.data);
});
```

**_PostgreSQL_**

```sql
CREATE TABLE jobs (
  id BIGSERIAL PRIMARY KEY,
  queue TEXT NOT NULL,
  payload JSONB NOT NULL,
  attempts INT DEFAULT 0,
  max_attempts INT DEFAULT 3,
  scheduled_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_jobs_queue ON jobs(queue, scheduled_at)
WHERE attempts < max_attempts;
```

**隊列：**

```sql
INSERT INTO jobs (queue, payload)
VALUES ('send-email', '{"to": "user@example.com", "subject": "Hi"}');
```

**工作進程（出隊）：**

```sql
WITH next_job AS (
  SELECT id FROM jobs
  WHERE queue = $1
    AND attempts < max_attempts
    AND scheduled_at <= NOW()
  ORDER BY scheduled_at
  LIMIT 1
  FOR UPDATE SKIP LOCKED
)
UPDATE jobs
SET attempts = attempts + 1
FROM next_job
WHERE jobs.id = next_job.id
RETURNING *;
```

##### 4：速率限制

**_Redis（經典速率限制器）_**

```javascript
const key = `ratelimit:${userId}`;
const count = await redis.incr(key);
if (count === 1) {
	await redis.expire(key, 60); // 60 seconds
}

if (count > 100) {
	throw new Error("Rate limit exceeded");
}
```

**_PostgreSQL_**

```sql
CREATE TABLE rate_limits (
  user_id INT PRIMARY KEY,
  request_count INT DEFAULT 0,
  window_start TIMESTAMPTZ DEFAULT NOW()
);

-- Check and increment
WITH current AS (
  SELECT
    request_count,
    CASE
      WHEN window_start < NOW() - INTERVAL '1 minute'
      THEN 1  -- Reset counter
      ELSE request_count + 1
    END AS new_count
  FROM rate_limits
  WHERE user_id = $1
  FOR UPDATE
)
UPDATE rate_limits
SET
  request_count = (SELECT new_count FROM current),
  window_start = CASE
    WHEN window_start < NOW() - INTERVAL '1 minute'
    THEN NOW()
    ELSE window_start
  END
WHERE user_id = $1
RETURNING request_count;
```

**或者用視窗函數更簡單**

```sql
CREATE TABLE api_requests (
  user_id INT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Check rate limit
SELECT COUNT(*) FROM api_requests
WHERE user_id = $1
  AND created_at > NOW() - INTERVAL '1 minute';

-- If under limit, insert
INSERT INTO api_requests (user_id) VALUES ($1);

-- Cleanup old requests periodically
DELETE FROM api_requests WHERE created_at < NOW() - INTERVAL '5 minutes';
```

##### 5：使用 JSONB 的會話

**_Redis_**

```javascript
await redis.set(
	`session:${sessionId}`,
	JSON.stringify(sessionData),
	"EX",
	86400,
);
```

**_PostgreSQL_**

```sql
CREATE TABLE sessions (
  id TEXT PRIMARY KEY,
  data JSONB NOT NULL,
  expires_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX idx_sessions_expires ON sessions(expires_at);

-- Insert/Update
INSERT INTO sessions (id, data, expires_at)
VALUES ($1, $2, NOW() + INTERVAL '24 hours')
ON CONFLICT (id) DO UPDATE
  SET data = EXCLUDED.data,
      expires_at = EXCLUDED.expires_at;

-- Read
SELECT data FROM sessions
WHERE id = $1 AND expires_at > NOW();
```
