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

{{< note title="Docker-Compose.yml cAdvisor" >}}

```yaml
version: "3.8"

networks:
  monitor_network:
    name: monitor_network
    driver: bridge
    ipam:
      driver: default
      config:
        - subnet: 10.10.10.0/24

services:
  cadvisor:
    image: gcr.io/cadvisor/cadvisor:v0.46.0
    container_name: cadvisor
    restart: always
    networks:
      - monitor_network
    ports:
      - 65080:8080
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    devices:
      - /dev/kmsg
    privileged: true
    deploy:
      resources:
        limits:
          cpus: "1"
          memory: 1G

  prometheus:
    image: prom/prometheus
    container_name: prometheus
    restart: always
    networks:
      - monitor_network
    ports:
      - 65090:9090
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    deploy:
      resources:
        limits:
          cpus: "1"
          memory: 1G

  node_exporter:
    image: prom/node-exporter
    container_name: node_exporter
    restart: always
    networks:
      - monitor_network
    expose:
      - 9100
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    deploy:
      resources:
        limits:
          cpus: "1"
          memory: 1G

  # Dashboard: gnetId: 179, 893, 11277, 11600
  grafana:
    image: grafana/grafana
    container_name: grafana
    restart: always
    networks:
      - monitor_network
    ports:
      - 65300:3000
    volumes:
      - ./grafana-storage:/var/lib/grafana
    deploy:
      resources:
        limits:
          cpus: "1"
          memory: 1G
```

###### prometheus.yml

```yaml
# global config
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"
# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node"
    static_configs:
      - targets: ["node_exporter:9100"]

  - job_name: "cadvisor"
    scrape_interval: 10s
    metrics_path: "/metrics"
    static_configs:
      - targets: ["cadvisor:8080"]
        labels:
          group: "cadvisor"
```

{{< /note >}}

{{< note title="Docker-Compose.yml Elasticsearch" >}}

```yaml
version: "3.8"

services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.15.0
    container_name: elasticsearch
    environment:
      - discovery.type=single-node
    ports:
      - 9200:9200
    networks:
      - local_net

  kibana:
    image: docker.elastic.co/kibana/kibana:7.15.0
    container_name: kibana
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    ports:
      - 5601:5601
    depends_on:
      - elasticsearch
    networks:
      - local_net

networks:
  local_net:
    external: true
```

{{< /note >}}

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

  kafka:
    image: bitnami/kafka
    container_name: kafka
    restart: always
    networks:
      - local_net
    ports:
      - 9092:9092
      - 9094:9094
    environment:
      - KAFKA_CFG_AUTO_CREATE_TOPICS_ENABLE=true
      - KAFKA_CFG_NODE_ID=0
      - KAFKA_CFG_PROCESS_ROLES=controller,broker
      - KAFKA_CFG_CONTROLLER_QUORUM_VOTERS=0@kafka:9093
      - KAFKA_CFG_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093,EXTERNAL://:9094
      - KAFKA_CFG_ADVERTISED_LISTENERS=PLAINTEXT://kafka:9092,EXTERNAL://localhost:9094
      - KAFKA_CFG_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,EXTERNAL:PLAINTEXT,PLAINTEXT:PLAINTEXT
      - KAFKA_CFG_CONTROLLER_LISTENER_NAMES=CONTROLLER
    volumes:
      - ./kafka:/bitnami/kafka

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

{{< note title="Dockerfile awscli" >}}

```dockerfile
FROM ubuntu
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update &&\
    apt-get install -y awscli --no-install-recommends
```

{{< /note >}}

{{< note title="Dockerfile buildx" >}}

```dockerfile
FROM --platform=$BUILDPLATFORM golang AS builder

WORKDIR /app
COPY . .
ARG TARGETOS TARGETARCH
RUN go mod download
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o main .


FROM gcr.io/distroless/base-debian11
WORKDIR /app
COPY --from=builder /app/main /app
CMD ["./main", "local:2379", "/namespace/host/dev"]
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
