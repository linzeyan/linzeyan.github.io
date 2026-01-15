# syntax = docker/dockerfile:1.6

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taipei

RUN apt-get update &&\
    apt-get install --no-install-recommends -y \
    certbot=2.9.0-1 \
    python3-certbot-dns-route53=2.9.0-1 &&\
    rm -rf /var/lib/apt/*

CMD [ "/bin/bash" ]

# docker buildx build --push --platform linux/arm64,linux/amd64 -t zeyanlin/certbot -t zeyanlin/certbot:v1.0.0 .
# /usr/bin/certbot certonly --dns-route53 -d *.newfuturetv.com --quiet --email ricky@newfuturetv.com --agree-tos
# /usr/bin/certbot certonly --dns-route53 -d *.777game-api.com --quiet --email ricky@newfuturetv.com --agree-tos