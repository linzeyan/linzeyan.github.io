#!/usr/bin/env bash

nameSpace='monitoring'
prometheusPort=9090
grafanaPort=3000
kubeControllerManagerDefaultPort=10257

## helm
## https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
## 1. monitoring every namespaces and export port
## 2. export grafana port
## 3. monitoring kubeControllerManager
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace "${nameSpace}" \
  --create-namespace \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.ruleSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.service.type=NodePort \
  --set prometheus.service.nodePort=${prometheusPort} \
  --set grafana.service.type=NodePort \
  --set grafana.service.nodePort=${grafanaPort} \
  --set kubeControllerManager.service.port=${kubeControllerManagerDefaultPort} \
  --set kubeControllerManager.service.targetPort=${kubeControllerManagerDefaultPort} \
  --set kubeControllerManager.ServiceMonitor.https=true \
  --set kubeControllerManager.ServiceMonitor.insecureSkipVerify=true \
  --set kubeControllerManager.ServiceMonitor.serverName=localhost

sleep 30

account=$(kubectl -n "${nameSpace}" get secret kube-prometheus-stack-grafana -o jsonpath="{.data.admin-user}" | base64 -d)
password=$(kubectl -n "${nameSpace}" get secret kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d)
