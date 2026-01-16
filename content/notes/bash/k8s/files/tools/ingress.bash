#!/usr/bin/env bash

ingressClass='nginx'
ingressFile='/tmp/ing.yaml'
ingressIP='192.168.185.109'
ingressName='proxy'
ingressSuffix='ingress-nginx'
nameSpace='ingress'
nginxRepo='ingress-nginx'
replica=0

if [[ "$1" == "delete" ]]; then
    # Delete
    kubectl delete namespace ${nameSpace}
    kubectl delete IngressClass ${ingressClass}
    # kubectl delete ValidatingWebhookConfiguration ${ingressName}-ingress-nginx-admission
    exit $?
fi

if ! $(helm repo list | grep ${nginxRepo} >/dev/null); then
    echo "Install ${nginxRepo}"
    helm repo add ${nginxRepo} https://kubernetes.github.io/ingress-nginx
    helm repo update
fi

# --set controller.autoscaling.enabled=true \
# --set controller.autoscaling.maxReplicas=9 \
# --set controller.metrics.enabled=true \
helm install ${ingressName} ${nginxRepo}/${ingressSuffix} \
    --namespace ${nameSpace} --create-namespace \
    --set controller.ingressClass=${ingressClass} \
    --set controller.replicaCount=${replica} \
    --set controller.service.externalTrafficPolicy=Local
# --set controller.publishService.enabled=true
# --set controller.defaultBackend.port=443 \
# --set controller.hostNetwork=true \
# --set controller.kind=DaemonSet \
# --set controller.daemonset.useHostPorts=true \
# --set controller.service.loadBalancerIP=${ingressIP}

clusertIP=$(kubectl -n ingress get service | awk 'NR==2{print $3}')
cat <<-EOF >${ingressFile}
# apiVersion: v1
# kind: Service
# metadata:
#   name: ${ingressName}-${ingressSuffix}
# spec:
#   clusterIP: ${clusertIP}
#   externalIPs:
#   - ${ingressIP}
#   externalTrafficPolicy: Local
#   selector:
#     app: proxy-nginx-ingress
#   ports:
#   - name: https
#     port: 443
#     targetPort: 443
#   type: LoadBalancer
# status:
#   loadBalancer:
#     ingress:
#     - ip: ${ingressIP}
# ---
# kind: Endpoints
# apiVersion: v1
# metadata:
#   name: ${ingressName}-${ingressSuffix}
# subsets:
#   - addresses:
#       - ip: 54.238.209.164
#     ports:
#       - name: https
#         port: 443
      # - name: ssh
      #   port: 22
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress
  annotations:
    kubernetes.io/ingress.class: ${ingressClass}
    nginx.ingress.kubernetes.io/upstream-vhost: own.go2cloudten.com
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    nginx.ingress.kubernetes.io/default-backend: ${ingressName}-${ingressSuffix}-controller
    nginx.ingress.kubernetes.io/http2-push-preload: "true"
    nginx.ingress.kubernetes.io/service-upstream: "true"
    # nginx.ingress.kubernetes.io/rewrite-target: /
spec:
#   defaultBackend:
#     service:
#       name: ${ingressName}-${ingressSuffix}
#       port:
#         number: 443
  rules:
  - host: gitlab.go2cloudten.com
    http:
      paths:
      - path: /*
        pathType: Prefix
        backend:
          service:
            name: ${ingressName}-${ingressSuffix}
            port:
              number: 443
#       - path: /*
#         pathType: Prefix
#         backend:
#           service:
#             name: ${ingressName}-${ingressSuffix}
#             port:
#               name: ssh
EOF
# kubectl -n ingress apply -f ${ingressFile}
