---
title: Docker docs
weight: 100
menu:
  notes:
    name: docker
    identifier: notes-docs-docker
    parent: notes-docs
    weight: 10
---

{{< note title="docker-compose" >}}

##### cAdvisor

- [docker-compose.yaml](/notes/docs/docker/docker-compose/cadvisor/docker-compose.yaml)
- [prometheus.yaml](/notes/docs/docker/docker-compose/cadvisor/prometheus.yaml)

##### Elasticsearch

- [docker-compose.yaml](/notes/docs/docker/docker-compose/elasticsearch/docker-compose.yaml)

##### local dev

- [docker-compose.yaml](/notes/docs/docker/docker-compose/local/docker-compose.yaml)

##### NodeJS

- [docker-compose.yaml](/notes/docs/docker/docker-compose/nodejs/docker-compose.yaml)

{{< /note >}}

{{< note title="Dockerfile" >}}

##### awscli

- [Dockerfile](/notes/docs/docker/dockerfile/awscli/Dockerfile)

##### buildx

- [Dockerfile](/notes/docs/docker/dockerfile/buildx/Dockerfile)
- `docker buildx build --push --platform linux/arm64,linux/amd64 -t zeyanlin/app .`

##### dind

- [Dockerfile](/notes/docs/docker/dockerfile/dind/Dockerfile)

##### golang

- [Dockerfile](/notes/docs/docker/dockerfile/golang/Dockerfile)
- `docker build --secret id=mysecret,src=id_rsa -t app .`

##### supervisord

- [Dockerfile](/notes/docs/docker/dockerfile/supervisord/Dockerfile)
- [supervisord.conf](/notes/docs/docker/dockerfile/supervisord/supervisord.conf)

{{< /note >}}
