---
title: "How to deploy on remote Docker hosts with docker-compose"
date: 2020-03-25T19:30:54+08:00
menu:
  sidebar:
    name: "How to deploy on remote Docker hosts with docker-compose"
    identifier: docker-how-to-deploy-on-remote-docker-hosts-with-docker-compose
    weight: 10
tags: ["URL", "Docker"]
categories: ["URL", "Docker"]
hero: images/hero/docker.jpeg
---

- [How to deploy on remote Docker hosts with docker-compose](https://www.docker.com/blog/how-to-deploy-on-remote-docker-hosts-with-docker-compose/)

##### Manual deployment by copying project files, install docker-compose and running it

```shell
$ scp -r hello-docker user@remotehost:/path/to/src
$ ssh user@remotehost
$ pip install docker-compose
$ cd /path/to/src/hello-docker
$ docker-compose up -d
```

##### Using DOCKER_HOST environment variable to set up the target engine

```shell
$ cd hello-docker
$ DOCKER_HOST="ssh://user@remotehost" docker-compose up -d
```

##### Using docker contexts

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
