---
title: "ElasticSearch 学习笔记"
date: 2022-10-06T11:30:59+08:00
menu:
  sidebar:
    name: "ElasticSearch 学习笔记"
    identifier: docker-elasticsearch-kibana-analysis-ik
    weight: 10
tags: ["URL", "Docker", "ELK", "ElasticSearch", "Kibana"]
categories: ["URL", "Docker", "ELK", "ElasticSearch", "Kibana"]
hero: images/hero/docker.jpeg
---

- [ElasticSearch 学习笔记](https://jiajunhuang.com/articles/2022_10_06-elasticsearch.md.html)

### 安装中文分词插件

```bash
docker exec -it elasticsearch bash
$ elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v8.4.1/elasticsearch-analysis-ik-8.4.1.zip
```

- Dev Tools
  - `content` 类型为 `text`，写入时使用 `ik_max_word` 做分词，搜索时使用 `ik_smart` 分词。这两个的区别在于，前者产生尽可能多的分词，后者产生粗粒度的分词。

```json
PUT /words
{
  "mappings": {
    "properties": {
      "content": {
        "type": "text",
        "analyzer": "ik_max_word",
        "search_analyzer": "ik_smart"
      },
      "age": {
        "type": "integer",
        "index": false
     }
    }
  }
}
```

```json
{
	"acknowledged": true,
	"shards_acknowledged": true,
	"index": "words"
}
```
