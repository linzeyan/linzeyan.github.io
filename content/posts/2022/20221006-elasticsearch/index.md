---
title: "Elasticsearch Study Notes"
date: 2022-10-06T11:30:59+08:00
menu:
  sidebar:
    name: "Elasticsearch Study Notes"
    identifier: docker-elasticsearch-kibana-analysis-ik
    weight: 10
tags: ["Links", "Docker", "ELK", "ElasticSearch", "Kibana"]
categories: ["Links", "Docker", "ELK", "ElasticSearch", "Kibana"]
hero: images/hero/docker.jpeg
---

- [Elasticsearch Study Notes](https://jiajunhuang.com/articles/2022_10_06-elasticsearch.md.html)

### Install the Chinese analyzer plugin

```bash
docker exec -it elasticsearch bash
$ elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v8.4.1/elasticsearch-analysis-ik-8.4.1.zip
```

- Dev Tools
  - The `content` field is `text`. Use `ik_max_word` for indexing and `ik_smart` for searching. The former generates as many tokens as possible, while the latter generates coarser-grained tokens.

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
