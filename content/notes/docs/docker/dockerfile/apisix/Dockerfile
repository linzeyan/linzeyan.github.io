# docker buildx build --push --platform linux/arm64,linux/amd64 -t zeyanlin/apisix:3.9.1 -t zeyanlin/apisix .
FROM --platform=$TARGETPLATFORM zeyanlin/nginx-http3:1.25.3 AS source

FROM --platform=$TARGETPLATFORM debian:bookworm

ARG APISIX_VERSION=3.9.1

RUN set -ex; \
    arch=$(dpkg --print-architecture); \
    apt update && \
    apt-get -y install --no-install-recommends \
    libgeoip1 \
    libgeoip-dev \
    libmaxminddb0 \
    libmaxminddb-dev \
    musl \
    wget \
    gnupg \
    ca-certificates \
    curl;\
    case "${arch}" in \
      amd64) \
        wget -O - https://repos.apiseven.com/pubkey.gpg | apt-key add - \
        && echo "deb https://repos.apiseven.com/packages/debian bullseye main" | tee /etc/apt/sources.list.d/apisix.list \
        ;; \
      arm64) \
        wget -O - https://repos.apiseven.com/pubkey.gpg | apt-key add - \
        && echo "deb https://repos.apiseven.com/packages/arm64/debian bullseye main" | tee /etc/apt/sources.list.d/apisix.list \
        ;; \
    esac; \
    apt update \
    && apt install -y apisix=${APISIX_VERSION}-0 \
    && apt-get purge -y --auto-remove \
    && rm /usr/local/openresty/bin/etcdctl \
    && openresty -V \
    && apisix version

COPY ./install-brotli.sh /install-brotli.sh
RUN chmod +x /install-brotli.sh \
    && cd / && ./install-brotli.sh && rm -rf /install-brotli.sh

RUN apt-get -y purge --auto-remove curl wget gnupg --allow-remove-essential

####
COPY --from=source /etc/nginx/modules/ngx_http_geoip2_module.so /usr/local/apisix/modules/ngx_http_geoip2_module.so
COPY GeoIP/GeoLite2-ASN.mmdb \
    GeoIP/GeoLite2-City.mmdb \
    GeoIP/GeoLite2-Country.mmdb \
    /usr/lib/GeoIP/

####

WORKDIR /usr/local/apisix

ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin

RUN groupadd --system --gid 636 apisix \
    && useradd --system --gid apisix --no-create-home --shell /usr/sbin/nologin --uid 636 apisix \
    && chown -R apisix:apisix /usr/local/apisix \
    && chmod -R 755 /usr/local/apisix/modules/*

USER apisix

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /usr/local/apisix/logs/access.log \
    && ln -sf /dev/stderr /usr/local/apisix/logs/error.log

EXPOSE 9080 9443

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["docker-start"]


STOPSIGNAL SIGQUIT
