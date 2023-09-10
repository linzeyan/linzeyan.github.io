---
title: Git Command
weight: 100
menu:
  notes:
    name: git
    identifier: notes-bash-git
    parent: notes-bash
    weight: 10
---

{{< note title="Search in git" >}}

```bash
git rev-list --all | xargs git grep -F ''
```

{{< /note >}}

{{< note title="Count commits" >}}

```bash
git rev-list --count main
```

{{< /note >}}

{{< note title="View a file of another branch" >}}

```bash
git show dev:main.go
```

{{< /note >}}

{{< note title="Take a backup of untracked files" >}}

```bash
git ls-files --others --exclude-standard -z | xargs -0 tar rvf backup-untracked.zip
```

{{< /note >}}

{{< note title="Submodule" >}}

```bash
# Add submodule
git submodule add -b main git@github.com:linzeyan/toha.git themes/toha

# Update submodule
git submodule update --init --remote

# Remove submodule
modulePath="themes/toha"
git submodule deinit -f ${modulePath}
git rm ${modulePath}
rm -rf .git/modules/${modulePath}
git config --remove-section submodule.${modulePath}.
rm -f .gitmodules
```

{{< /note >}}
