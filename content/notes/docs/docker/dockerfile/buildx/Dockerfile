FROM --platform=$BUILDPLATFORM golang AS builder

WORKDIR /app
COPY . .
ARG TARGETOS TARGETARCH
RUN go mod download
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o main .


FROM gcr.io/distroless/base-debian11
WORKDIR /app
COPY --from=builder /app/main /app
CMD ["./main", "local:2379", "/namespace/host/dev"]
