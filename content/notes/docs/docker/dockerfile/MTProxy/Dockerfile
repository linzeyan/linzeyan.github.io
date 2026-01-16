FROM alpine AS builder
RUN apk add --no-cache --update \
      alpine-sdk \
      autoconf \
      gcc \
      git \
      libc-dev \
      linux-headers \
      make \
      musl-dev \
      openssl-dev \
      zlib \
      zlib-dev \
      zlib-static \
  && rm -rf /etc/apk/cache
COPY randr_compat.patch /randr_compat.patch
RUN git clone https://github.com/TelegramMessenger/MTProxy
WORKDIR /MTProxy
RUN patch -p0 -i /randr_compat.patch
RUN make -j$(getconf _NPROCESSORS_ONLN)

FROM alpine
RUN apk add --no-cache \
      curl \
      openssl \
  && rm -rf /etc/apk/cache
COPY --from=builder /MTProxy/objs/bin /usr/bin
COPY run.sh /usr/bin/run.sh
EXPOSE 443
CMD ["/bin/sh","/usr/bin/run.sh"]
