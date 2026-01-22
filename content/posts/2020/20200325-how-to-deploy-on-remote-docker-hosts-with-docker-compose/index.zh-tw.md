---
title: "使用 docker-compose 部署到遠端 Docker 主機"
date: 2020-03-25T19:30:54+08:00
menu:
  sidebar:
    name: "使用 docker-compose 部署到遠端 Docker 主機"
    identifier: docker-how-to-deploy-on-remote-docker-hosts-with-docker-compose
    weight: 10
tags: ["Links", "Docker"]
categories: ["Links", "Docker"]
hero: images/hero/docker.jpeg
---

- [使用 docker-compose 部署到遠端 Docker 主機](https://www.docker.com/blog/how-to-deploy-on-remote-docker-hosts-with-docker-compose/)

##### 手動部署：複製專案檔案、安裝 docker-compose 並執行

```shell
$ scp -r hello-docker user@remotehost:/path/to/src
$ ssh user@remotehost
$ pip install docker-compose
$ cd /path/to/src/hello-docker
$ docker-compose up -d
```

##### 使用 DOCKER_HOST 環境變數設定目標引擎

```shell
$ cd hello-docker
$ DOCKER_HOST="ssh://user@remotehost" docker-compose up -d
```

##### 使用 docker context

```shell
$ docker context create remote ‐‐docker "host=ssh://user@remotemachine"
remote
Successfully created context "remote"

$ docker context ls
NAME      DESCRIPTION            DOCKER ENDPOINT    KUBERNETES ENDPOINT     ORCHESTRATOR
default * Current DOCKER_HOST…   unix:///var/run/docker.sock                swarm
remote                           ssh://user@remotemachine

$ cd hello-docker
$ docker-compose ‐‐context remote up -d
```
