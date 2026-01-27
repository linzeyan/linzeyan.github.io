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

### Before the change, Redis handled three things:

1. Caching (70% of usage)
2. Pub/Sub (20% of usage)
3. Background Job Queue (10% of usage)

**_The pain points:_**

- Two databases to backup
- Redis uses RAM (expensive at scale)
- Redis persistence is... complicated
- Network hop between Postgres and Redis

### PostgreSQL Feature

##### 1: Caching with UNLOGGED Tables

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

##### 2: Pub/Sub with LISTEN/NOTIFY

**_Redis Pub/Sub_**

```javascript
// Publisher
redis.publish("notifications", JSON.stringify({ userId: 123, msg: "Hello" }));

// Subscriber
redis.subscribe("notifications");
redis.on("message", (channel, message) => {
	console.log(message);
});
```

**_PostgreSQL Pub/Sub_**

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

##### 3: Job Queues with SKIP LOCKED

**_Redis (using Bull/BullMQ)_**

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

**Enqueue:**

```sql
INSERT INTO jobs (queue, payload)
VALUES ('send-email', '{"to": "user@example.com", "subject": "Hi"}');
```

**Worker (dequeue):**

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

##### 4: Rate Limiting

**_Redis (classic rate limiter):_**

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

**Or simpler with a window function**

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

##### 5: Sessions with JSONB

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
