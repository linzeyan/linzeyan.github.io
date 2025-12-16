FROM --platform=$BUILDPLATFORM golang:alpine AS builder
RUN apk add git
WORKDIR /
RUN git clone https://github.com/ochinchina/supervisord.git
WORKDIR /supervisord
ARG TARGETOS TARGETARCH
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -a -ldflags "-extldflags -static" -o supervisord .


FROM alpine
WORKDIR /supervisord
COPY supervisord.conf /supervisord/
COPY --from=builder /supervisord/supervisord /supervisord/supervisord
CMD ["/supervisord/supervisord", "-c", "supervisord.conf"]
# docker buildx build --push --platform linux/arm64,linux/amd64 -t zeyanlin/supervisord .
