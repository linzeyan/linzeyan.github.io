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

{{< note title="Run pod" >}}

```bash
kubectl run -it --rm --image=registry.go2cloudten.com/it/docker/backup test --image-pull-policy=IfNotPresent -- bash
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
