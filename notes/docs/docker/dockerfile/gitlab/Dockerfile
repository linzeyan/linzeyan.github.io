# syntax = docker/dockerfile:1.6
FROM debian

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y curl jq \
    && curl -L 'https://github.com/linzeyan/ops-cli/releases/download/v0.14.11/ops-cli_v0.14.11_linux_amd64.tar.gz' -o - | tar -xzf - -C /tmp \
    && mv /tmp/ops-cli_v0.14.11_linux_amd64/ops-cli /usr/bin/ \
    && rm -rf /tmp/ops-cli_v0.14.11_linux_amd64

COPY --chmod=755 telegram.bash /usr/bin/
