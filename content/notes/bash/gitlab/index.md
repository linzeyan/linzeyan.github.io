---
title: Gitlab Command
weight: 100
menu:
  notes:
    name: gitlab
    identifier: notes-gitlab
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
