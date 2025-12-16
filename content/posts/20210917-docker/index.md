---
title: "Docker Introduction"
date: 2021-09-17T14:11:03+08:00
description: Share the concept of Docker.
menu:
  sidebar:
    name: Docker Introduction
    identifier: docker-introduction
    weight: 10
tags: ["Docker", "introduction", "slides"]
categories: ["Docker"]
hero: docker.jpeg
---

# Docker

## Concept

### VM vs Container

- VM - Base on OS
- Container - Base on Application (Linux Kernel: Namespace and Cgroup)

### Client to Server

- Docker daemon - containerd, docker-containerd-shim, docker-runc
- Docker client - cli command

```
docker cli -> docker daemon -> containerd -> runc -> namespace & cgroup
```

### Image

- Snapshots

### Container

- Read-Only processes on image

### Hub / Registry

- Store images

### References

- [Docker —— 從入門到實踐][1]
- [docker docs][2]

---

## Docker commands

### Dockerfile

```dockerfile
ARG dist="/tmp/password"
ARG projectDir="/password"

FROM golang:1.16-alpine3.14 AS builder
RUN apk add build-base upx
ARG dist
ARG projectDir
WORKDIR ${projectDir}
COPY . .
RUN go build -trimpath -o main cmd/main.go
RUN upx -9 -o ${dist} main

FROM scratch
ARG dist
ENV TZ=Asia/Taipei
COPY --from=builder ${dist} /usr/local/bin/password
```

### Dockerfile1

```dockerfile
FROM alpine
CMD ["nc","-l","12345"]
```

### Dockerfile2

```dockerfile
FROM alpine
CMD ["echo","DOCKER"]
```

### docker build command

```shell
docker build . -t program

docker build . -f Dockerfile -t test_mysql

docker build . -t hello:v1.1 --build-arg dist=/tmp/hello --build-arg projectDir=/hello
```

---

### docker build

```bash
. docker/status
echo -e "${GREEN}Before build${RESET}"
docker image ls
docker build . -f docker/Dockerfile1 -t test1
docker build . -f docker/Dockerfile2 -t test2
```

### docker image

```bash
. docker/status
echo -e "${GREEN}After build${RESET}"
docker image ls
```

---

### docker run AND rm

```bash
. docker/status
echo -e "${GREEN}Run container1${RESET}"
docker run -d --name container1 test1
echo -e "${GREEN}Run container2${RESET}"
docker run -d --name container2 test2
echo -e "${GREEN}List alive containers${RESET}"
docker ps
echo -e "${GREEN}List all containers${RESET}"
docker ps -a
echo -e "${GREEN}Remove alive container${RESET}"
docker rm -f container1
echo -e "${GREEN}List all containers${RESET}"
docker ps -a
echo -e "${GREEN}Remove exit container${RESET}"
docker rm container2
echo -e "${GREEN}List all containers${RESET}"
docker ps -a
```

---

### docker pull AND rmi

```bash
. docker/status
echo -e "${GREEN}List all image${RESET}"
docker image ls
echo -e "${GREEN}Pull alpine image${RESET}"
docker pull alpine
echo -e "${GREEN}List all image${RESET}"
docker image ls
```

---

### docker rmi

```bash
. docker/status
echo -e "${GREEN}Remove alpine image${RESET}"
docker rmi alpine
echo -e "${GREEN}List all image${RESET}"
docker image ls
```

---

### prune

```bash
docker system prune -f --volumes
```

---

### docker history

```bash
. docker/status
echo -e "${GREEN}History of test1${RESET}"
docker history test1
echo -e "${GREEN}History of mysql:8${RESET}"
docker history mysql:8
```

---

## Docker remote

### Edit service file

```
# /lib/systemd/system/docker.service
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock -H tcp://0.0.0.0:2375
```

### Restart service

```
systemctl daemon-reload
systemctl restart docker
```

### Specify DOCKER_HOST

```bash
. docker/status
echo -e "${GREEN}List images on 192.168.185.9${RESET}"
DOCKER_HOST=192.168.185.9:2375 docker images
```

---

## Docker-compose

```yaml
version: "3"

services:
  svn:
    image: zeyanlin/svn
    environment:
      - LDAP_HOSTS=${LDAP_HOSTS}
      - LDAP_BASE_DN=${LDAP_BASE_DN}
      - LDAP_BIND_DN=${LDAP_BIND_DN}
      - LDAP_ADMIN_PASS=${LDAP_ADMIN_PASS}
    ports:
      - 8000:80
      - 3690:3690
    depends_on:
      - ldap
  ldap:
    image: zeyanlin/openldap
    environment:
      - LDAP_DOMAIN=${LDAP_DOMAIN}
      - LDAP_ADMIN_PASS=${LDAP_ADMIN_PASS}
    ports:
      - 389:389
      - 636:636
  php:
    image: zeyanlin/phpldapadmin
    environment:
      - LDAP_HOSTS=${LDAP_HOSTS}
    ports:
      - 80:80
    depends_on:
      - ldap
```

---

### Env

```ini
LDAP_HOSTS=ldap
LDAP_DOMAIN="knowhow.fun"
LDAP_BASE_DN="dc=knowhow,dc=fun"
LDAP_BIND_DN="cn=admin"
LDAP_ADMIN_PASS="123qwe"
```

[1]: https://philipzheng.gitbook.io/docker_practice/
[2]: https://docs.docker.com/
