---
title: Docker Command
weight: 100
menu:
  notes:
    name: docker
    identifier: notes-docker-build
    parent: notes-bash
    weight: 10
---

{{< note title="Compose" >}}

```bash
# Force pull image
docker-compose up -d --pull always
```

{{< /note >}}

{{< note title="Create buildx instance" >}}

```bash
# create buildx instance
docker buildx create --name builder --bootstrap --driver docker-container
# install emulators
docker run --privileged --rm tonistiigi/binfmt --install all
```

{{< /note >}}

{{< note title="Create Network" >}}

```bash
docker network create -d bridge --subnet 172.100.0.0/24 --gateway 172.100.0.1 backend_dev
```

{{< /note >}}

{{< note title="Multiple build-arg" >}}

```bash
docker build . -f ./scripts/Dockerfile \
  --build-arg Date=$(date) \
  --build-arg Tag=$(git rev-list -n 1 --tags) \
  --build-arg Commit=$(git describe --tags --abbrev=0)  \
  -t ops-cli
```

{{< /note >}}

{{< note title="Multiple platform" >}}

```bash
# create and use buildx instance
docker buildx create --use --name builder
# build multiple platform
docker buildx build --push --platform linux/arm64,linux/amd64 -t zeyanlin/ops-cli .
```

{{< /note >}}

{{< note title="Run container in different platform" >}}

```bash
finch run -it --rm --platform=linux/arm64 zeyanlin/ops-cli /bin/sh
```

{{< /note >}}
