---
title: "Abount Ansible Hosts"
date: 2020-05-12T19:46:04+08:00
menu:
  sidebar:
    name: "Abount Ansible Hosts"
    identifier: ansible-ad-hoc-hosts-formats-notes
    weight: 10
tags: ["Ansible"]
categories: ["Ansible"]
hero: images/hero/ansible.png
---

```shell
# hosts 可以這樣寫

$ ansible 'max-compute[!3:9][0:3][0:3]' -m setup --list-hosts
  hosts (4):
    max-compute10
    max-compute13
    max-compute20
    max-compute23
$ ansible 'max-compute[!3:9][0:4][0:4]' -m setup --list-hosts
  hosts (3):
    max-compute10
    max-compute14
    max-compute20
$ ansible 'max-compute[!0:3]' -m setup --list-hosts
  hosts (6):
    max-compute4
    max-compute5
    max-compute6
    max-compute7
    max-compute8
    max-compute9
```

```yaml
plugin: gcp_compute
projects:
  - project-XXX
zones:
  - asia-east1-a
  - asia-east1-c
  - asia-east1-b
  - asia-east2-a
  - asia-east2-c
  - asia-east2-b
auth_kind: serviceaccount
service_account_file: /root/.ssh/sa001.json
filters:
  - status="RUNNING"
hostnames:
  - name
groups:
  nginx: "'nginx' in name"
  cassandra: "'cassandra' in name"
  redis: "'redis' in name"
  misc: "name in ('noc', 'mt-center')"
  prod: "'prod' in name and 'gke' not in name"
  all: "'gke' not in name"
  search: "'search' in name"
```

```yaml
cht_domain:
  "{{ 'web.qat.cht' if ansible_default_ipv4['network'] == '192.168.40.0'
  else 'ap.qat.cht' if ansible_default_ipv4['network'] == '192.168.50.0'
  else 'db.qat.cht' if ansible_default_ipv4['network'] == '192.168.60.0'
  else 'qat.cht' }}"
```
