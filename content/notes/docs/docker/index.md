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

##### rstudio

- [docker-compose.yaml](/notes/docs/docker/dockerfile/rstudio/docker-compose.yaml)

##### rsyncd

- [docker-compose.yaml](/notes/docs/docker/docker-compose/rsyncd/docker-compose.yaml)
- [rsyncd.conf](/notes/docs/docker/docker-compose/rsyncd/rsyncd.conf)
- [rsyncd.secrets](/notes/docs/docker/docker-compose/rsyncd/rsyncd.secrets)
- `rsync -auz --password-file=/tmp/pass dist user@hostip::myshare`

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

##### [nginx](https://github.com/macbre/docker-nginx-http3)

- [Dockerfile](/notes/docs/docker/dockerfile/nginx/Dockerfile)
- [docker-compose.yml](/notes/docs/docker/dockerfile/nginx/docker-compose.yml)
- [nginx.conf](/notes/docs/docker/dockerfile/nginx/nginx.conf)

##### rstudio

- [Dockerfile](/notes/docs/docker/dockerfile/rstudio/Dockerfile)
- [pkg.txt](/notes/docs/docker/dockerfile/rstudio/pkg.txt)

##### supervisord

- [Dockerfile](/notes/docs/docker/dockerfile/supervisord/Dockerfile)
- [supervisord.conf](/notes/docs/docker/dockerfile/supervisord/supervisord.conf)
  - service with supervisord
    - [Dockerfile](/notes/docs/docker/dockerfile/supervisord/service_with_supervisord/Dockerfile)

{{< /note >}}
