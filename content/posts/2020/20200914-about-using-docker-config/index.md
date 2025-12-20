---
title: "Docker Tips: Using Docker Config"
date: 2020-09-14T11:13:23+08:00
menu:
  sidebar:
    name: "Docker Tips: Using Docker Config"
    identifier: docker-about-using-docker-config
    weight: 10
tags: ["URL", "Docker"]
categories: ["URL", "Docker"]
hero: images/hero/docker.jpeg
---

- [Docker Tips: Using Docker Config](https://medium.com/better-programming/about-using-docker-config-e967d4a74b83)

```dockerfile
FROM nginx:1.13.6
COPY nginx.conf /etc/nginx/nginx.conf
```

Using the Docker CLI, we can create a `config` from this configuration file, we name this config `proxy`.

```shell
$ docker config create proxy nginx.conf
mdcfnxud53ve6jgcgjkhflg0s

$ docker config inspect proxy
[
  {
    "ID": "x06uaozphg9kbnf8g4az4mucn",
    "Version": {
      "Index": 2723
    },
    "CreatedAt": "2017-11-21T07:49:09.553666064Z",
    "UpdatedAt": "2017-11-21T07:49:09.553666064Z",
    "Spec": {
      "Name": "proxy",
      "Labels": {},
      "Data": "dXNlciB3d3ctZGF0YTsKd29y...ogIgICAgIH0KICAgIH0KfQo="
    }
  }
]
```

##### Use a Config

```shell
$ docker network create --driver overlay front
$ docker service create --name api --network front lucj/api
$ docker service create --name proxy \
  --network front \
  --config src=proxy,target=/etc/nginx/nginx.conf \
  --port 8000:8000 \
  nginx:1.13.6
```

##### Service Update

When the content of a configuration needs to be modified, it's a common pattern to create a new config (using `docker config create`), and then to update the service order to remove the access to the previous config, and to add the access to the new one. The service commands are`--config-rm` and `--config-add`.

```shell
$ docker config create proxy-v2 nginx-v2.conf
xtd1s1g6b5zukjhvup5vi4jzd

$ docker service update --config-rm proxy --config-add src=proxy-v2,target=/etc/nginx/nginx.conf proxy
```

Note: by default, when a config is attached to a service, it is available in the /config_name file. We then need to explicitly define the location using the `target` option.
