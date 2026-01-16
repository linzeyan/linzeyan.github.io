#!/bin/bash

docker run \
    -d \
    --restart=always  \
    --name rancher \
    --network=host \
    -v /etc/ssl/server.crt:/etc/rancher/ssl/cert.pem \
    -v /etc/ssl/server.key:/etc/rancher/ssl/key.pem \
    -v /etc/ssl/ca.crt:/etc/rancher/ssl/cacerts.pem \
    --privileged \
    rancher/rancher:latest
