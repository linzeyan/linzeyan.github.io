---
title: "Docker 小技巧：使用 Docker Config"
date: 2020-09-14T11:13:23+08:00
menu:
  sidebar:
    name: "Docker 小技巧：使用 Docker Config"
    identifier: docker-about-using-docker-config
    weight: 10
tags: ["Links", "Docker"]
categories: ["Links", "Docker"]
hero: images/hero/docker.jpeg
---

- [Docker 小技巧：使用 Docker Config](https://medium.com/better-programming/about-using-docker-config-e967d4a74b83)

```dockerfile
FROM nginx:1.13.6
COPY nginx.conf /etc/nginx/nginx.conf
```

使用 Docker CLI，可以從這個設定檔建立一個 `config`，並將它命名為 `proxy`。

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

##### 使用 Config

```shell
$ docker network create --driver overlay front
$ docker service create --name api --network front lucj/api
$ docker service create --name proxy \
  --network front \
  --config src=proxy,target=/etc/nginx/nginx.conf \
  --port 8000:8000 \
  nginx:1.13.6
```

##### 服務更新

當設定內容需要修改時，常見做法是建立新的 config（使用 `docker config create`），然後更新服務以移除舊的 config 並加上新的 config。對應的服務指令是 `--config-rm` 與 `--config-add`。

```shell
$ docker config create proxy-v2 nginx-v2.conf
xtd1s1g6b5zukjhvup5vi4jzd

$ docker service update --config-rm proxy --config-add src=proxy-v2,target=/etc/nginx/nginx.conf proxy
```

Note: 預設情況下，當 config 附加到服務時，它會出現在 `/config_name` 檔案中。需要使用 `target` 選項明確指定位置。
