---
title: Docker docs
weight: 100
menu:
  notes:
    name: docker
    identifier: notes-docker-docs
    parent: notes-docs
    weight: 10
---

{{< note title="Docker-Compose.yml Local" >}}

```yaml
version: "3.8"

networks:
  local_net:
    name: local_net
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 100.100.100.0/24

services:
  etcd1:
    image: bitnami/etcd:latest
    container_name: etcd1
    restart: always
    networks:
      - local_net
    ports:
      - 2379:2379
      - 2380:2380
    expose:
      - "2379"
    environment:
      - ALLOW_NONE_AUTHENTICATION=yes
      - ETCD_NAME=etcd1
      - ETCD_INITIAL_ADVERTISE_PEER_URLS=http://etcd1:2380
      - ETCD_LISTEN_PEER_URLS=http://0.0.0.0:2380
      - ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379
      - ETCD_ADVERTISE_CLIENT_URLS=http://etcd1:2379
      - ETCD_INITIAL_CLUSTER_TOKEN=etcd-cluster
      - ETCD_INITIAL_CLUSTER=etcd1=http://etcd1:2380,etcd2=http://etcd2:2380,etcd3=http://etcd3:2380
      - ETCD_INITIAL_CLUSTER_STATE=new
    volumes:
      - ./etcd/etcd1_data:/bitnami/etcd

  etcd2:
    image: bitnami/etcd:latest
    container_name: etcd2
    restart: always
    networks:
      - local_net
    ports:
      - 12379:2379
      - 12380:2380
    environment:
      - ALLOW_NONE_AUTHENTICATION=yes
      - ETCD_NAME=etcd2
      - ETCD_INITIAL_ADVERTISE_PEER_URLS=http://etcd2:2380
      - ETCD_LISTEN_PEER_URLS=http://0.0.0.0:2380
      - ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379
      - ETCD_ADVERTISE_CLIENT_URLS=http://etcd2:2379
      - ETCD_INITIAL_CLUSTER_TOKEN=etcd-cluster
      - ETCD_INITIAL_CLUSTER=etcd1=http://etcd1:2380,etcd2=http://etcd2:2380,etcd3=http://etcd3:2380
      - ETCD_INITIAL_CLUSTER_STATE=new
    volumes:
      - ./etcd/etcd2_data:/bitnami/etcd

  etcd3:
    image: bitnami/etcd:latest
    container_name: etcd3
    restart: always
    networks:
      - local_net
    ports:
      - 22379:2379
      - 22380:2380
    environment:
      - ALLOW_NONE_AUTHENTICATION=yes
      - ETCD_NAME=etcd3
      - ETCD_INITIAL_ADVERTISE_PEER_URLS=http://etcd3:2380
      - ETCD_LISTEN_PEER_URLS=http://0.0.0.0:2380
      - ETCD_LISTEN_CLIENT_URLS=http://0.0.0.0:2379
      - ETCD_ADVERTISE_CLIENT_URLS=http://etcd3:2379
      - ETCD_INITIAL_CLUSTER_TOKEN=etcd-cluster
      - ETCD_INITIAL_CLUSTER=etcd1=http://etcd1:2380,etcd2=http://etcd2:2380,etcd3=http://etcd3:2380
      - ETCD_INITIAL_CLUSTER_STATE=new
    volumes:
      - ./etcd/etcd3_data:/bitnami/etcd

  rabbitmq:
    image: rabbitmq:3.9.29
    container_name: rabbitmq
    restart: always
    networks:
      - local_net
    ports:
      - 5671:5671
    environment:
      - RABBITMQ_DEFAULT_USER=localuser
      - RABBITMQ_DEFAULT_PASS=localpassword

  redis:
    image: redis
    container_name: redis
    restart: always
    networks:
      - local_net
    ports:
      - 6379:6379

  mongo:
    image: mongo
    container_name: mongo
    restart: always
    networks:
      - local_net
    ports:
      - 27017:27017
    environment:
      - MONGO_INITDB_ROOT_USERNAME=localuser
      - MONGO_INITDB_ROOT_PASSWORD=localpassword
      - MONGO_INITDB_DATABASE=my-database

  mysql:
    image: mysql
    container_name: mysql
    restart: always
    networks:
      - local_net
    ports:
      - 3306:3306
    environment:
      - MYSQL_ROOT_PASSWORD=my-secret-pw
      - MYSQL_DATABASE=my-database
      - MYSQL_USER=localuser
      - MYSQL_PASSWORD=localpassword

  mqtt:
    image: emqx/emqx
    container_name: mqtt
    restart: always
    networks:
      - local_net
    volumes:
      - ./mqtt/config:/mosquitto/config
      - ./mqtt/data:/mosquitto/data
      - ./mqtt/log:/mosquitto/log
    ports:
      - 1883:1883
      - 8083:8083
      - 8084:8084
      - 8883:8883
      - 18083:18083

  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    restart: always
    networks:
      - local_net
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./portainer:/data
    ports:
      - 8000:8000
      - 9443:9443
```

{{< /note >}}

{{< note title="Docker-Compose.yml NodeJS" >}}

```yaml
version: "3.8"
services:
  app:
    image: app
    pull_policy: always
    container_name: app
    restart: always
    build:
      platforms:
        - "linux/amd64"
      dockerfile_inline: |
        FROM node:20

        WORKDIR /app
        COPY . .

        RUN npm install
        RUN npm run build
        CMD ["npm", "run", "start"]
    ports:
      # out:in
      - 3000:3000
    networks:
      - app_network
    working_dir: /app
    volumes:
      # log folder or volume
      - log_volume:/app/log

networks:
  app_network:
    name: app_network
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 100.100.100.0/24

volumes:
  log_volume:
```

{{< /note >}}

{{< note title="Dockerfile dind" >}}

```dockerfile
ARG DOCKER_BUILDX_VERSION=0.11.2

FROM docker/buildx-bin:${DOCKER_BUILDX_VERSION} AS buildx

FROM ubuntu:22.04

ARG DOCKER_BUILDX_VERSION
ENV DOCKER_COMPOSE_VERSION=2.20.3
ENV DOCKER_VERSION=20.10.25-0ubuntu1~22.04.1

COPY --from=buildx /buildx /usr/libexec/docker/cli-plugins/docker-buildx

RUN apt-get update &&\
    apt-get install -y ca-certificates docker.io=${DOCKER_VERSION} git openssh-client openssl wget --no-install-recommends &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* &&\
    wget https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-linux-x86_64 -O /usr/bin/docker-compose &&\
    chmod +x /usr/bin/docker-compose &&\
    mkdir -p /certs/client/ &&\
    chmod 777 -R /certs

ENV DOCKER_BUILDKIT=1
ENV DOCKER_BUILDX_VERSION=${DOCKER_BUILDX_VERSION}
ENV DOCKER_CLI_EXPERIMENTAL=enabled
ENV DOCKER_HOST=""
ENV DOCKER_TLS_CERTDIR=/certs
```

{{< /note >}}

{{< note title="Dockerfile awscli" >}}

```dockerfile
FROM ubuntu
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update &&\
    apt-get install -y awscli --no-install-recommends
```

{{< /note >}}
