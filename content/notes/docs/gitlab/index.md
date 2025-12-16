---
title: Gitlab docs
weight: 100
menu:
  notes:
    name: gitlab
    identifier: notes-docs-gitlab
    parent: notes-docs
    weight: 10
---

{{< note title="add member by project" >}}

Admin Area -> Settings -> General -> LDAP settings -> Lock memberships to LDAP synchronization -> Cancel

{{< /note >}}

{{< note title="backup cronjob" >}}

```bash
# Backup Gitlab configs
1 0 * * * /usr/bin/tar -zcf /var/opt/gitlab/backups/`date +%Y_%m_%d`_gitlab_config.tar.gz /etc/gitlab &> /tmp/backup.log
# Backup Gitlab data
1 1 * * * /usr/bin/gitlab-backup create STRATEGY=copy BACKUP=`date +%Y_%m_%d` &>> /tmp/backup.log
# Rotate
0 2 * * * /usr/bin/rm -f `find /data/backups/ -name "*.tar*" -mtime +15`
```

{{< /note >}}

{{< note title="gitlab-ci.yml template" >}}

##### gitbook

- [gitlab-ci.yml](/notes/docs/gitlab/ci/gitbook/.gitlab-ci.yml)
- [gitbook.yml](/notes/docs/gitlab/ci/gitbook/.gitbook.yml)

##### golang

- [gitlab-ci.yml](/notes/docs/gitlab/ci/golang/.gitlab-ci.yml)

##### hexo

- [gitlab-ci.yml](/notes/docs/gitlab/ci/hexo/.gitlab-ci.yml)

##### Static resources

- [gitlab-ci.yml](/notes/docs/gitlab/ci/static/.gitlab-ci.yml)

##### template

- [gitlab-ci.yml](/notes/docs/gitlab/ci/template/.gitlab-ci.yml)

{{< /note >}}

{{< note title="config" >}}

##### gitlab-runner

- [gitlab-runner.toml](/notes/docs/gitlab/config/gitlab-runner/gitlab-runner.toml)

{{< /note >}}

{{< note title="issue" >}}

###### console output while install

```
[execute] psql: could not connect to server: Connection refused
            Is the server running locally and accepting
            connections on Unix domain socket "/var/opt/gitlab/postgresql/.s.PGSQL.5432"?
```

###### solve

```bash
# stop service
sudo gitlab-ctl stop
sudo systemctl stop gitlab-runsvdir.service

# check if there are any postgres processes; shouldn't be
ps aux | grep postgre

# remove process pid
sudo rm /var/opt/gitlab/postgresql/data/postmaster.pid

# start service
sudo systemctl start gitlab-runsvdir.service
sudo gitlab-ctl reconfigure
```

{{< /note >}}

{{< note title="issue1" >}}

###### 解決 Gitlab Pages 限制訪問權限後的 redirect invalid url。

1. Remove "gitlab_pages" block from `/etc/gitlab/gitlab-secrets.json`
2. `gitlab-ctl reconfigure`

{{< /note >}}

{{< note title="issue2" >}}

###### console output

```shell
# Gitlab Container Registry
Error response from daemon: Get https://registry.knowhow.fun/v2/: x509: certificate has expired or is not yet valid
```

###### [/etc/gitlab/gitlab.rb](/notes/docs/gitlab/config/gitlab/gitlab.rb)

###### solve

```bash
yum install ca-certificates
cd /etc/gitlab
openssl genrsa -out ca.key 4096
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt
openssl genrsa -out server.key 4096
openssl req -new -key server.key -out server.csr
openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt
cp server.crt /etc/pki/ca-trust/source/anchors/
cp ca.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust
```

{{< /note >}}

{{< note title="issue3" >}}

###### console output

```shell
# Gitlab Container Registry
received unexpected HTTP status: 500 Internal Server Error
```

###### solve

`/etc/gitlab/gitlab.rb`

```ruby
gitlab_rails['ldap_servers'] = {
    'main' => {
        'encryption' => 'plain',
    }
}
```

{{< /note >}}
