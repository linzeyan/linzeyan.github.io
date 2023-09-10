---
title: Gitlab Command
weight: 100
menu:
  notes:
    name: gitlab
    identifier: notes-bash-gitlab
    parent: notes-bash
    weight: 10
---

{{< note title="cleanup" >}}

[doc](https://docs.gitlab.com/ee/administration/packages/container_registry.html)

```bash
# artifacts
gitlab-rake gitlab:cleanup:orphan_job_artifact_files

# expire session
gitlab-rake gitlab:cleanup:sessions:active_sessions_lookup_keys

# lfs
gitlab-rake gitlab:cleanup:orphan_lfs_files

# project
gitlab-rake gitlab:cleanup:project_uploads
gitlab-rake gitlab:cleanup:remote_upload_files

# registry
gitlab-ctl registry-garbage-collect
gitlab-ctl registry-garbage-collect -m
```

{{< /note >}}

{{< note title="migration" >}}

###### 1. Copy Old Crontab、Old /etc/gitlab、update-ca-trust

###### 2. Version should be same

###### 3. Copy newest backup file

###### 4. Stop Services

```bash
gitlab-ctl stop unicorn
gitlab-ctl stop puma
gitlab-ctl stop sidekiq
gitlab-ctl status
```

###### 5. Restore

> File must put in /var/opt/gitlab/backup

```bash
chown git:git backupfile
gitlab-backup restore BACKUP=11493107454_2018_04_25_10.6.4-ce
```

###### 6. Check

```bash
gitlab-ctl reconfigure
gitlab-ctl restart
gitlab-rake gitlab:check SANITIZE=true
```

###### 7. Unlock gitlab-runner at Admin Area

###### 8. Pages: Add https settings in gitlab.rb, Admin Area -> Applications -> Destroy old System OAuth, and remove secret in gitlab-secret.json.

```bash
gitlab-ctl reconfigure
```

{{< /note >}}
