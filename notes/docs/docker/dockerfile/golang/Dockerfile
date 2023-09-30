# syntax = docker/dockerfile:1.6
FROM golang:1.21.1-alpine3.18

ENV GITLAB_DOMAIN="gitlab.example.com"
ENV CGO_ENABLED=0
ENV GO111MODULE=on
ENV GONOPROXY="${GITLAB_DOMAIN}"
ENV GONOSUMDB="${GITLAB_DOMAIN}"
ENV GOPRIVATE="https://${GITLAB_DOMAIN}/*"

COPY <<-eof /root/.ssh/config
Host *
    StrictHostKeyChecking no
eof

COPY <<-eof /root/.gitconfig
[url "git@${GITLAB_DOMAIN}:"]
    insteadOf = https://${GITLAB_DOMAIN}/
eof

RUN apk add \
    git \
    make \
    openssh \
    --no-cache

COPY go.mod /go/src/
RUN --mount=type=secret,id=mysecret,target=/root/.ssh/id_rsa \
    chmod -R 0400 /root/.ssh &&\
    cd /go/src &&\
    go mod download -x &&\
    rm -f /go/src/*
