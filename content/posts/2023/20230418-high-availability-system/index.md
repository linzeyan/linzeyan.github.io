---
title: "关于高可用的系统"
date: 2023-04-18T10:24:00+08:00
menu:
  sidebar:
    name: "关于高可用的系统"
    identifier: high-availability-system
    weight: 10
tags: ["URL", "design", "system", "HA"]
categories: ["URL", "design", "system", "HA"]
---

- [关于高可用的系统](https://coolshell.cn/articles/17459.html)

| 項目 / 機制  | Backups | M/S       | MM        | 2PC        | Paxos      |
| ------------ | ------- | --------- | --------- | ---------- | ---------- |
| Consistency  | Weak    | Eventual  | Eventual  | Strong     | Strong     |
| Transactions | No      | Full      | Local     | Full       | Full       |
| Latency      | Low     | Low       | Low       | High       | High       |
| Throughput   | High    | High      | High      | Low        | Medium     |
| Data loss    | Lots    | Some      | Some      | None       | None       |
| Failover     | Down    | Read only | Read only | Read/write | Read/write |

这个图基本上来说是目前高可用系统中能看得到的所有的解决方案的基础了。M/S、MM 实现起来不难，但是会有很多问题，2PC 的问题就是性能不行，而 Paxos 的问题就是太复杂，实现难度太大。

总结一下各个高可用方案的的问题：

- 对于最终一致性来说，在宕机的情况下，会出现数据没有完全同步完成，会出现数据差异性。
- 对于强一致性来说，要么使用性能比较慢的 XA 系的两阶段提交的方案，要么使用性能比较好，但是实现比较复杂的 Paxos 协议。
