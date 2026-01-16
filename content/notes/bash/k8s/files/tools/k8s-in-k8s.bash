#!/usr/bin/env bash

## Install kubernetes-in-kubernetes

helm repo add kvaps https://kvaps.github.io/charts

helm install kik kvaps/kubernetes --version 0.13.4 \
    --namespace kik \
    --create-namespace \
    --set persistence.storageClassName=local-path
