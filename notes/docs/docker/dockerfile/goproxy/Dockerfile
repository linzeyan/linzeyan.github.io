FROM --platform=$BUILDPLATFORM alpine:latest

ARG TARGETARCH
ARG URL="https://github.com/snail007/goproxy/releases/download/v14.1/proxy-linux-$TARGETARCH.tar.gz"
RUN if [ $TARGETARCH = "arm64" ]; then URL="https://github.com/snail007/goproxy/releases/download/v14.1/proxy-linux-arm64-v8.tar.gz"; fi \
    && wget $URL -O - | tar -zxf - -C /tmp \
    && mv /tmp/proxy /usr/bin/ \
    && rm -rf /tmp/*

CMD [ "/usr/bin/proxy", "http" ]
