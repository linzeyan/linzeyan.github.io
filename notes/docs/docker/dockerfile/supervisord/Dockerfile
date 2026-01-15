FROM --platform=$TARGETPLATFORM golang:alpine AS builder
RUN apk add git --no-cache
WORKDIR /
RUN git clone https://github.com/ochinchina/supervisord.git
WORKDIR /supervisord
ARG TARGETOS TARGETARCH
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -a -ldflags "-extldflags -static" -o supervisord .


FROM --platform=$TARGETPLATFORM alpine:3.20.1
WORKDIR /supervisord
COPY supervisord.conf /supervisord/
COPY --from=builder /supervisord/supervisord /supervisord/supervisord
CMD ["/supervisord/supervisord", "-c", "supervisord.conf"]
# docker buildx create --use
# docker buildx build --push --platform linux/arm64,linux/amd64 -t zeyanlin/supervisord -t zeyanlin/supervisord:v1.0.0 .
