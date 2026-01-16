# https://github.com/sameersbn/docker-bind
FROM ubuntu:focal-20200423 AS add-apt-repositories

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg wget \
  && apt-key adv --fetch-keys https://download.webmin.com/jcameron-key.asc \
  && echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Taipei \
    BIND_USER=bind \
    DATA_DIR=/data
    # ROOT_PASSWORD=12345
    # WEBMIN_ENABLED=false

COPY --from=add-apt-repositories /etc/apt/trusted.gpg /etc/apt/trusted.gpg
COPY --from=add-apt-repositories /etc/apt/sources.list /etc/apt/sources.list

RUN rm -f /etc/apt/apt.conf.f/docker-gzip-indexes \
  # && apt-get purge apt-show-versions \
  && rm -f /var/lib/apt/lists/*lz4 \
  && apt-get -o Acquire::GzipIndexes=false update \
  && apt-get install -y \
    bind9 \
    bind9-doc \
    bind9-host \
    dnsutils \
    inetutils-ping \
  && apt-get install -y webmin \
  && rm -rf /tmp/* /var/lib/apt/*

COPY --chown=root:root run.sh /usr/bin/run.sh

EXPOSE 53/udp 53/tcp 10000/tcp

CMD ["/bin/bash","/usr/bin/run.sh"]
# docker run -d -p 53:53/udp -p 53:53/tcp -p 10000:10000/tcp -v /data/bind:/data --name dns zeyanlin/bind
