---
title: "Gitlab-CI Introduction"
date: 2021-09-24T11:11:03+08:00
description: Share the concept of Gitlab-CI.
menu:
  sidebar:
    name: Gitlab-CI Introduction
    identifier: gitlab-ci-introduction
    weight: 10
tags: ["Gitlab", "introduction", "slides", "ci"]
categories: ["Gitlab"]
hero: gitlab.png
---

# Gitlab CI

## Concept

### Gitlab

- DevOps
- GitOps

### Workflow

```
code push -> pipeline -> stage -> job
```

### Design

```
plan -> code -> build -> test -> release -> deploy -> operate -> monitor -> plan
```

### Runner Executors

- Shell
- VirtualBox
- Docker
- Docker Machine
- Kubernetes
- Else...

### References

- [Gitlab CI/CD][1]
- [Gitlab Runner][2]
- [.gitlab-ci.yaml][3]

---

## Runner

### Register

`gitlab-runner register`

### After register

```toml
concurrent = 1
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "public-shell"
  url = "https://gitlab.go2cloudten.com/"
  token = "-mdH9OAOzG5yPsf_AVnW"
  executor = "shell"

[[runners]]
  name = "public-docker"
  url = "https://gitlab.go2cloudten.com/"
  token = "AcEGPPKTS1uuQ_A_qpWy"
  executor = "docker"
  [runners.docker]
    dns = ["192.168.185.5", "192.168.185.6"]
    tls_verify = false
    image = "registry.go2cloudten.com/it/office_sop/node:12.13.0"
    privileged = true
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    shm_size = 0
    pull_policy = "if-not-present"
    volumes = ["/cache"]
```

---

## Repository

### .gitlab-ci.yaml

```yaml
stages:
  - domain

check-icp:
  stage: domain
  image: registry.go2cloudten.com/it/office_sop/icp
  tags:
    - docker
  script:
    - domains=$(awk -F '|' '{if($6 ~ "Y" && ($7 ~ "West" || $7 ~ "Yuqu")) print $3}' domains-info.md | sed 's/ //g' | sort | uniq)
    - if [[ "${domains}" == "" ]]; then telegram.sh 'There is no domain in list' ; else telegram.sh 'Start checking ICP.' ; fi
    - for i in ${domains}; do result=$(checkicp ${i}); if [[ "${result}" == "未备案" ]];then telegram.sh "${i} 未备案"; sleep 1 ;fi;done
    - telegram.sh 'ICP check completed.'
  only:
    - schedules
```

[1]: https://docs.gitlab.com/ee/ci/
[2]: https://docs.gitlab.com/runner/
[3]: https://docs.gitlab.com/ee/ci/yaml/
