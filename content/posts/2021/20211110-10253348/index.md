---
title: "Uncle Joe teaches Elastic - 30 - Elasticsearch optimization tips (4/4) - Shard optimization management"
date: 2021-11-10T13:12:35+08:00
menu:
  sidebar:
    name: "Uncle Joe teaches Elastic - 30 - Elasticsearch optimization tips (4/4) - Shard optimization management"
    identifier: elk-elasticsearch-optimization-techniques-shard-optimization-management
    weight: 10
tags: ["Links", "ELK", "Elasticsearch"]
categories: ["Links", "ELK", "Elasticsearch"]
---

- [Uncle Joe teaches Elastic - 30 - Elasticsearch optimization tips (4/4) - Shard optimization management](https://ithelp.ithome.com.tw/articles/10253348)

#### Planning considerations

##### During search, each shard uses one thread. Too many shards can slow things down.

> A node has multiple thread pools by function. The search (count/search/suggest) pool size is `int((# of allocated processors * 3) / 2) + 1` and the default queue_size is `1000`. The write (index/delete/update/bulk) pool size is `# of allocated processors` and the default queue_size is also `1000`. (Official docs - Thread pools)

Most searches span multiple shards. Each shard uses one CPU thread to execute the search, so:

- More shards allow queries to run in parallel across shards, improving throughput.
- More shards also consume more node thread pool resources. If threads are insufficient, query performance suffers.

##### Each shard has a baseline cost; more shards means higher overhead

##### Specify shard allocation in the cluster to optimize storage resources

##### When deleting large batches, delete by index rather than by documents

Document deletion in Elasticsearch creates a "tombstone" record in segment files, so it continues to consume resources until segment merge completes and it is actually removed.

If you delete old data periodically, delete by index rather than using batch mechanisms like delete_by_query.

##### Use Data Stream or Index Lifecycle Management (ILM) for time series data

ILM can define automatic rollover rules. When data reaches a certain size, time, or document count, it creates a new index for new data, and old data can be auto-deleted.

ILM is a good tool for shard strategy because it makes adjustments easy:

- ILM manages indices via index templates, so changing the number of primary shards is as simple as updating the template.
- To slow shard growth or increase shard size, adjust the rollover config.
- To delete old data when there are too many shards, adjust the delete phase rules.

##### Recommended shard size is usually 10-50 GB

##### 1 GB heap memory can handle about 20 shards

The number of shards a node can handle is roughly proportional to JVM heap size. Based on official numbers, 1 GB heap can handle about 20 shards. For example, 30 GB heap can handle about 600 shards, but this still depends on cluster hardware and workload.

To check shard counts, use the `_cat API`:
`GET _cat/shards`

##### When an index has multiple shards, avoid assigning most shards to the same node

When you set multiple primary shards, the goal is to spread indexing across more nodes. In a cluster with many indices, shard allocation may place most shards for a given index on the same node, which defeats the purpose.

You can use `index.routing.allocation.total_shards_per_node` to limit how many shards of an index can be assigned to a node:

```
PUT /my-index-000001/_settings
{
  "index" : {
    "routing.allocation.total_shards_per_node" : 5
  }
}
```

#### Fixing oversharded clusters

When a cluster becomes unstable due to too many shards, you can adjust or fix it as follows.

##### Use longer time intervals for time-based indices

For time-based data, increase the index interval. For example, change from daily indices to monthly or yearly indices.

If using ILM, you can achieve the same by increasing `max_age`, `max_docs`, and `max_size`.

##### Delete empty or unnecessary indices

##### Run Force Merge during off-peak hours to merge segment files

##### Use the Shrink API to reduce shard count on existing indices

##### Use the Reindex API to merge smaller indices

For example, if you currently use daily indices and have too many shards, use reindex to merge them into monthly indices.

```
POST /_reindex
{
  "source": {
    "index": "my-index-2099.10.*"
  },
  "dest": {
    "index": "my-index-2099.10"
  }
}
```
