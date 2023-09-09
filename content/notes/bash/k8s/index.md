---
title: K8s Command
weight: 100
menu:
  notes:
    name: k8s
    identifier: notes-k8s
    parent: notes-bash
    weight: 10
---

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

{{< note title="gitlab-runner" >}}

[link](https://docs.gitlab.com/ee/user/project/clusters/add_remove_clusters.html)

###### gitlab-admin-service-account.yaml

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: gitlab
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: gitlab-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
  name: gitlab
  namespace: kube-system
```

```bash
# CA Certificate
  kubectl get secret $(kubectl get secret | grep default | awk '{print $1}') -o jsonpath="{['data']['ca\.crt']}" | base64 --decode

# Service Token
kubectl apply -f gitlab-admin-service-account.yaml
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab | awk '{print $1}')
```

```bash
# https://gitlab.com/gitlab-org/charts/gitlab-runner/blob/master/values.yaml
echo | openssl s_client -CAfile ca.crt -connect gitlab.knowhow.it:443 > /tmp/certs/server.pem

# Install gitlab-runner from gitlab
helm repo add gitlab https://charts.gitlab.io
kubectl create namespace gitlab

kubectl --namespace gitlab create secret generic gitlab-certs --from-file=gitlab.knowhow.it.crt=/tmp/certs/server.pem --from-file=registry.knowhow.it.crt=/tmp/certs/server.pem

helm install --namespace gitlab k8srunner --set gitlabUrl=https://gitlab.knowhow.it,runnerRegistrationToken=VmyYjzmU_FjqyMJNJxJK,certsSecretName=gitlab-certs,rbac.create=true,runners.privileged=true,runners.tags=k8s,runners.image=alpine:3.12,runners.locked=false gitlab/gitlab-runner
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
