---
title: "On High Availability Systems"
date: 2023-04-18T10:24:00+08:00
menu:
  sidebar:
    name: "On High Availability Systems"
    identifier: high-availability-system
    weight: 10
tags: ["Links", "design", "system", "HA"]
categories: ["Links", "design", "system", "HA"]
---

- [On High Availability Systems](https://coolshell.cn/articles/17459.html)

| Item / Mechanism | Backups | M/S       | MM        | 2PC        | Paxos      |
| ------------ | ------- | --------- | --------- | ---------- | ---------- |
| Consistency  | Weak    | Eventual  | Eventual  | Strong     | Strong     |
| Transactions | No      | Full      | Local     | Full       | Full       |
| Latency      | Low     | Low       | Low       | High       | High       |
| Throughput   | High    | High      | High      | Low        | Medium     |
| Data loss    | Lots    | Some      | Some      | None       | None       |
| Failover     | Down    | Read only | Read only | Read/write | Read/write |

This table essentially covers the foundational solutions for high-availability systems today. M/S and MM are not hard to implement, but have many issues. 2PC suffers from poor performance, while Paxos is too complex and difficult to implement.

To summarize the problems of each HA approach:

- For eventual consistency, if a crash occurs, data may not have fully synchronized, leading to inconsistencies.
- For strong consistency, either use the slower XA-style two-phase commit approach, or use the faster but more complex Paxos protocol.
