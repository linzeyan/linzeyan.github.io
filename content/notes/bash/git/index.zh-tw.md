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

{{< note title="commit hash" >}}

```bash
git rev-parse HEAD
```

{{< /note >}}

{{< note title="commit tag" >}}

```bash
git describe --tags
```

{{< /note >}}

{{< note title="worktree" >}}

```bash
# list
git worktree list

# add
git worktree add ../dirname branch-name
```

{{< /note >}}

{{< note title="git config" >}}

```ini
[user]
  email = zeyanlin@outlook.com
  name = Ricky
  signingkey = 2A4313489FDCA802ED6FCC214B03D879EA73DF37
[commit]
  gpgsign = true
```

{{< /note >}}

{{< note title="git config1" >}}

For golang import package

```ini
[url "git@gitlab.example.com:"]
    insteadOf = https://gitlab.example.com/
```

{{< /note >}}

{{< note title="git config2" >}}

```ini
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work
```

{{< /note >}}

{{< note title="remove big file in repository" >}}

```bash
uv venv
source .venv/bin/activate
uv pip install git-filter-repo
git filter-repo --force --strip-blobs-bigger-than 100M
```

{{< /note >}}
