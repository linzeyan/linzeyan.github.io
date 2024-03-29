---
title: K8s Command
weight: 100
menu:
  notes:
    name: k8s
    identifier: notes-bash-k8s
    parent: notes-bash
    weight: 10
---

{{< note title="cert-manager" >}}

- [cert-manager](https://cert-manager.io/docs)
- [Route53 IAM Role](/notes/bash/k8s/files/cert-manager/cert-manager-aws-iam-role.json)
- [Cert Manager Resource](/notes/bash/k8s/files/cert-manager/cert-manager-resource.yaml)
- [Cert Generate Resource](/notes/bash/k8s/files/cert-manager/cert-generate-resource.yaml)
- [Cert Ingress Resource](/notes/bash/k8s/files/cert-manager/cert-ingress-resource.yaml)

```bash
# install the cert-manager CustomResourceDefinition resources
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.crds.yaml

# Add the Jetstack Helm repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# install the cert-manager helm chart
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.1 \
  --set installCRDs=true
  --set prometheus.enabled=false \
  --set webhook.timeoutSeconds=4

# uninstalling
helm delete my-release
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.crds.yaml

# create clusterissuer
kubectl apply -f cert-manager-resource.yaml

# generate certificate
kubectl apply -f cert-generate-resource.yaml

# create ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# create ingress
kubectl apply -f cert-ingress-resource.yaml
```

{{< /note >}}

{{< note title="helm" >}}

```bash
# install plugin
helm plugin install https://github.com/chartmuseum/helm-push.git

# add repo
## helm repo add --username gitlab-ci-token --password ${CI_JOB_TOKEN} ${CI_PROJECT_NAME} ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/helm/stable
helm repo add go2helm https://gitlab.go2cloudten.com/api/v4/projects/29/packages/helm/stable --username ricky

# push chart
## https://docs.gitlab.com/ee/user/packages/helm_repository/
helm cm-push ./proxy-0.1.0.tgz go2helm
```

{{< /note >}}

{{< note title="kompose" >}}

```bash
kompose --file docker-compose.yml convert
```

{{< /note >}}

{{< note title="gitlab-runner" >}}

[link](https://docs.gitlab.com/ee/user/project/clusters/add_remove_clusters.html)

###### [gitlab-admin-service-account.yaml](/content/notes/bash/k8s/files/gitlab-runner/gitlab-admin-service-account.yaml)

```bash
# CA Certificate
kubectl get secret $(kubectl get secret | grep default | awk '{print $1}') -o jsonpath="{['data']['ca\.crt']}" | base64 --decode

# Service Token
kubectl apply -f gitlab-admin-service-account.yaml
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab | awk '{print $1}')

# https://gitlab.com/gitlab-org/charts/gitlab-runner/blob/master/values.yaml
echo | openssl s_client -CAfile ca.crt -connect gitlab.knowhow.it:443 > /tmp/certs/server.pem

# Install gitlab-runner from gitlab
helm repo add gitlab https://charts.gitlab.io
kubectl create namespace gitlab

kubectl --namespace gitlab create secret generic gitlab-certs --from-file=gitlab.knowhow.it.crt=/tmp/certs/server.pem --from-file=registry.knowhow.it.crt=/tmp/certs/server.pem

helm install --namespace gitlab k8srunner --set gitlabUrl=https://gitlab.knowhow.it,runnerRegistrationToken=VmyYjzmU_FjqyMJNJxJK,certsSecretName=gitlab-certs,rbac.create=true,runners.privileged=true,runners.tags=k8s,runners.image=alpine:3.12,runners.locked=false gitlab/gitlab-runner
```

{{< /note >}}

{{< note title="k3d" >}}

###### [k3d.yaml](/content/notes/bash/k8s/files/k3d/k3d.yaml)

```bash
# create cluster
k3d cluster create --config k3d.yaml

# delete cluster
k3d cluster delete local

# import image
k3d image import superapp -c local
```

{{< /note >}}

{{< note title="kind" >}}

###### [kind.yaml](/content/notes/bash/k8s/files/kind/kind.yaml)

```bash
# create cluster
kind create cluster --config kind.yaml

# delete cluster
kind delete cluster -n local

# import image
kind load docker-image superapp -n local
```

{{< /note >}}

{{< note title="rancher" >}}

```bash
#!/usr/bin/env bash

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
```

{{< /note >}}

{{< note title="skaffold" >}}

```bash
#!/usr/bin/env bash

# https://github.com/GoogleContainerTools/skaffold/examples/getting-started
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
    sudo install skaffold /usr/local/bin/
```

{{< /note >}}

{{< note title="k8s in k8s" >}}

```bash
#!/usr/bin/env bash

## Install kubernetes-in-kubernetes

helm repo add kvaps https://kvaps.github.io/charts

helm install kik kvaps/kubernetes --version 0.13.4 \
    --namespace kik \
    --create-namespace \
    --set persistence.storageClassName=local-path
```

{{< /note >}}

{{< note title="argocd" >}}

```bash
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
```

{{< /note >}}

{{< note title="cert manager" >}}

```bash
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
```

{{< /note >}}

{{< note title="cilium" >}}

```bash
#!/usr/bin/env bash

set -eux

use_cli() {
curl -L --remote-name-all https://github.com/cilium/cilium-cli/releases/latest/download/cilium-darwin-amd64.tar.gz{,.sha256sum}
shasum -a 256 -c cilium-darwin-amd64.tar.gz.sha256sum
sudo tar xzvfC cilium-darwin-amd64.tar.gz /usr/local/bin
rm cilium-darwin-amd64.tar.gz{,.sha256sum}
cilium install
}

helm install cilium cilium/cilium --version 1.11.0 \
  --namespace kube-system
```

{{< /note >}}

{{< note title="ingress" >}}

```bash
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
# \-\-\-
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
\-\-\-
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
```

{{< /note >}}

{{< note title="krew" >}}

```bash
#!/usr/bin/env bash

set -x
cd "$(mktemp -d)" &&
    OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
    KREW="krew-${OS}_${ARCH}" &&
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
    tar zxvf "${KREW}.tar.gz" &&
    ./"${KREW}" install krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

kubectl krew install change-ns
kubectl change-ns nginx
```

{{< /note >}}

{{< note title="prometheus" >}}

```bash
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
```

{{< /note >}}

{{< note title="Create and use secret" >}}

##### command

```bash
kubectl -n nginx create secret docker-registry gitlab --docker-server=registry.go2cloudten.com --docker-username=ricky --docker-password="token or password"
```

##### config

```yaml
imagePullSecrets:
  - name: gitlab
```

{{< /note >}}

{{< note title="Run pod" >}}

```bash
kubectl run -it --rm --image=registry.go2cloudten.com/it/docker/backup test --image-pull-policy=IfNotPresent -- bash
```

{{< /note >}}
