# syntax = docker/dockerfile:1.6
FROM golang:1.21.1-alpine3.18

ENV GITLAB_DOMAIN="gitlab.example.com"
ENV CGO_ENABLED=0
ENV GO111MODULE=on
ENV GONOPROXY="${GITLAB_DOMAIN}"
ENV GONOSUMDB="${GITLAB_DOMAIN}"
ENV GOPRIVATE="${GITLAB_DOMAIN}/*"

COPY <<-eof /root/.ssh/config
Host *
    StrictHostKeyChecking no
eof
# COPY config /root/.ssh/config

COPY <<-eof /root/.gitconfig
[url "git@${GITLAB_DOMAIN}:"]
    insteadOf = https://${GITLAB_DOMAIN}/
eof
# RUN git config --global url."git@${GITLAB_DOMAIN}:".insteadOf "https://${GITLAB_DOMAIN}/"
RUN apk add \
    git \
    make \
    openssh \
    --no-cache

RUN --mount=type=secret,id=mysecret,target=/root/.ssh/id_rsa \
    chmod -R 0400 /root/.ssh
COPY pkg_list /pkglist
RUN for i in $(cat /pkglist); do go install ${i}@latest || true ; done
