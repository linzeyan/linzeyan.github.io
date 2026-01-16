#!/usr/bin/env bash

nameSpace='argocd'
port=8443

## helm
## https://github.com/argoproj/argo-helm/tree/master/charts/argo-cd
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install argocd argo/argo-cd \
  --namespace ${nameSpace} --create-namespace \
  --set server.service.type=NodePort \
  --set server.service.nodePortHttps=${port}

## kubectl
# kubectl create namespace ${nameSpace}
# kubectl apply -n ${nameSpace} -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# sleep 60

# kubectl apply -f - <<SVC
# ---
# apiVersion: v1
# kind: Service
# metadata:
#   labels:
#     app.kubernetes.io/component: server
#     app.kubernetes.io/name: argocd-server
#     app.kubernetes.io/part-of: argocd
#   name: argocd-server
#   namespace: ${nameSpace}
# spec:
#   type: NodePort
#   selector:
#     app.kubernetes.io/name: argocd-server
#   ports:
#     - name: https
#       nodePort: ${port}
#       port: 443
#       targetPort: 8080
# SVC

if ! which argocd 2>&1 >/dev/null; then
  wget https://github.com/argoproj/argo-cd/releases/download/v2.1.7/argocd-linux-amd64
  chmod 755 argocd-linux-amd64
  mv argocd-linux-amd64 /usr/local/bin/argocd
fi
sleep 120
account='admin'
password=$(kubectl -n ${nameSpace} get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo ${account}
echo ${password}
## CLI
# argocd login https://192.168.185.95:6443
# argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace default

delete() {
  kubectl delete clusterrole argocd-application-controller ; kubectl delete clusterrole argocd-server
  kubectl delete clusterrolebindings argocd-application-controller ; kubectl delete clusterrolebindings argocd-server
}
