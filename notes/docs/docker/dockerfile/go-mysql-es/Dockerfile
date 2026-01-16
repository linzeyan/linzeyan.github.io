ARG user=go
ARG dir='/go-mysql-elasticsearch'
## Build go-mysql-elasticsearch from source
FROM golang:latest AS go-builder
RUN git clone https://github.com/siddontang/go-mysql-elasticsearch.git ${dir} \
  && cd ${dir} \
  && make

FROM centos:7 AS base
## Copy go-mysql-elasticsearch
ARG dir
COPY --from=go-builder ${dir}/bin${dir} /usr/bin/
## Copy mysqldump(5.7) and mysqldump8(8.0)
ADD mysqldump_centos.tar.xz /usr/bin/
ARG user
RUN useradd -m -d /home/${user} -s /bin/bash ${user}

FROM scratch
ENV TZ=Asia/Taipei
COPY --from=base / /
ARG user
USER ${user}
WORKDIR /opt
CMD ["go-mysql-elasticsearch", "-config=/opt/river.toml", "-data_dir=/opt/"]
# docker run -d --name site --restart=always -v /data/site:/opt go-mysql-elasticsearch
