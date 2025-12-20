---
title: "Faster Multi-Platform Builds: Dockerfile Cross-Compilation Guide"
date: 2023-09-04T10:31:54+08:00
menu:
  sidebar:
    name: "Faster Multi-Platform Builds: Dockerfile Cross-Compilation Guide"
    identifier: docker-multi-platform-builds
    weight: 10
tags: ["URL", "Docker"]
categories: ["URL", "Docker"]
hero: images/hero/docker.jpeg
---

- [Faster Multi-Platform Builds: Dockerfile Cross-Compilation Guide](https://www.docker.com/blog/faster-multi-platform-builds-dockerfile-cross-compilation-guide/)

### method

- `docker buildx create --use`
- `FROM --platform=linux/amd64 debian` / `FROM --platform=$BUILDPLATFORM debian`
- variables

```
BUILDPLATFORM — matches the current machine. (e.g. linux/amd64)

BUILDOS — os component of BUILDPLATFORM, e.g. linux

BUILDARCH — e.g. amd64, arm64, riscv64

BUILDVARIANT — used to set ARM variant, e.g. v7

TARGETPLATFORM — The value set with --platform flag on build

TARGETOS - OS component from --platform, e.g. linux

TARGETARCH - Architecture from --platform, e.g. arm64

TARGETVARIANT
```

### example

- before

```dockerfile
FROM golang:1.17-alpine AS build
WORKDIR /src
COPY . .
RUN go build -o /out/myapp .

FROM alpine
COPY --from=build /out/myapp /bin
```

- after

```dockerfile
FROM --platform=$BUILDPLATFORM golang:1.17-alpine AS build
WORKDIR /src
ARG TARGETOS TARGETARCH
RUN --mount=target=. \
    --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /out/myapp .

FROM alpine
COPY --from=build /out/myapp /bin
```
