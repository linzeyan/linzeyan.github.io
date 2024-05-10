FROM golang:alpine AS builder

# ARG SERVICE_NAME

WORKDIR /app
COPY . .
RUN make build
# RUN go build -o ${SERVICE_NAME} .

FROM alpine AS modifier

ARG SERVICE_NAME
ARG SERVICE_CONF
ARG SERVICE_ETCD

WORKDIR /app
COPY --from=zeyanlin/supervisord /supervisord/supervisord /app
COPY --from=zeyanlin/supervisord /supervisord/supervisord.conf /app
COPY --from=builder /app/bin/* /app/
# COPY --from=builder /app/${SERVICE_NAME} /app/
RUN sed -i \
    -e "s|SERVICE_NAME|${SERVICE_NAME}|g" \
    -e "s|SERVICE_CONF|${SERVICE_CONF}|g" \
    -e "s|SERVICE_ETCD|${SERVICE_ETCD}|g" \
    supervisord.conf
# RUN sed -i \
#     -e "s|SERVICE_NAME|${SERVICE_NAME}|g" \
#     -e "s|-conf=SERVICE_CONF|${SERVICE_CONF}|g" \
#     -e "s|-etcd=SERVICE_ETCD|${SERVICE_ETCD}|g" \
#     supervisord.conf


FROM alpine
COPY --from=modifier /app /app
WORKDIR /app
RUN apk add openrc --no-cache && mkdir -p /app/log
