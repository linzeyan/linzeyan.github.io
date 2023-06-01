---
title: GPG Command
weight: 100
menu:
  notes:
    name: gpg
    identifier: notes-gpg
    parent: notes-bash
    weight: 10
---

{{< note title="Install" >}}
```bash
brew install gnupg
```
{{< /note >}}

{{< note title="Generate" >}}
```bash
gpg --full-generate-key

gpg --list-secret-keys
```
{{< /note >}}

{{< note title="Generate Problem" >}}
```shell
$ gpg --full-generate-key
gpg: Sorry, no terminal at all requested - can't get input
```

Comment out no-tty in `~/.gnupg/gpg.conf`
{{< /note >}}

{{< note title="Add to git" >}}
```bash
gpg --armor --export 51ADF7101CA64B2508AE29EEC279555531A1DD62
```
{{< /note >}}

{{< note title="Set .gitconfig" >}}
```bash
git config user.email zeyanlin@outlook.com
git config user.name Ricky
git config user.signingkey 51ADF7101CA64B2508AE29EEC279555531A1DD62
git config commit.gpgsign true
```
{{< /note >}}

{{< note title="Delete key" >}}
```bash
gpg --delete-secret-keys 51ADF7101CA64B2508AE29EEC279555531A1DD62
```
{{< /note >}}

{{< note title="Backup key" >}}
```bash
# https://www.jwillikers.com/backup-and-restore-a-gpg-key
gpg --list-secret-keys --keyid-format LONG

# Export key as a file, replace email-address and Enter the private key’s passphrase
gpg -o private.gpg --export-options backup --export-secret-keys rickylin@cloud-miner.net

# Restore key and enter the private key’s passphrase
gpg --import-options restore --import private.gpg
```
{{< /note >}}

{{< note title="If GPG not work" >}}
```bash
echo 'export GPG_TTY=$(tty)' >> ~/.zshrc
gpgconf –kill gpg-agent
exec $SHELL
```
{{< /note >}}

{{< note title="Encrypt file" >}}
```bash
# Encrypt file
gpg --symmetric --cipher-algo aes256 archive_file.tar

# Decrypt file
gpg --output archive_file.tar --decrypt archive_file.tar.gpg
```
{{< /note >}}