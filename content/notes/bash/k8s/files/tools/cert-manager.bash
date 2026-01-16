#!/usr/bin/env bash

## Install cert-manager
## https://cert-manager.io/docs/installation/

helm repo add jetstack https://charts.jetstack.io
helm install \
    cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.7.2 \
    --set installCRDs=true \
    --set prometheus.enabled=false \
    --set webhook.timeoutSeconds=4
