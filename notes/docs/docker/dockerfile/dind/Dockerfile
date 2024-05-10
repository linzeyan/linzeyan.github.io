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
