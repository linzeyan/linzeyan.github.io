---
title: "Articles"
date: 2026-06-10T10:59:53+08:00
menu:
  sidebar:
    name: "Articles"
    identifier: articles-recent-20260610
    weight: 10
tags:
  [
    "Links",
    "Bookmark",
    "3D printing",
    "Skill",
    "WASM",
    "Pokemon",
    "Github",
    "VSCode",
    "Bug",
    "Browser",
    "Extension",
    "Agent",
    "Privacy",
    "iOS",
    "macOS",
    "SSH",
    "Security",
    "Iptables",
    "DNS",
    "Docker",
    "Registry",
    "Go",
    "Chinese",
    "Tailscale",
    "RustDesk",
    "RDAP",
  ]
categories:
  [
    "Links",
    "Bookmark",
    "3D printing",
    "Skill",
    "WASM",
    "Pokemon",
    "Github",
    "VSCode",
    "Bug",
    "Browser",
    "Extension",
    "Agent",
    "Privacy",
    "iOS",
    "macOS",
    "SSH",
    "Security",
    "Iptables",
    "DNS",
    "Docker",
    "Registry",
    "Go",
    "Chinese",
    "Tailscale",
    "RustDesk",
    "RDAP",
  ]
---

- [Pokemon Emerald in WebAssembly(https://github.com/tripplyons/pokeemerald-wasm)](https://pokeemerald.com/)
- **Github**
  - [wxt: Next-gen Web Extension Framework](https://github.com/wxt-dev/wxt)
  - [Skills for threat modeling, scanning, triage, patching, plus an autonomous scanning harness you can `/customize`](https://github.com/anthropics/defending-code-reference-harness)
  - [A curated list of awesome 3D printing resources](https://github.com/ad-si/awesome-3d-printing)
  - [hermes-agent: It's the only agent with a built-in learning loop - it creates skills from experience, improves them during use, nudges itself to persist knowledge, searches its own past conversations, and builds a deepening model of who you are across sessions. Run it on a $5 VPS, a GPU cluster, or serverless infrastructure that costs nearly nothing when idle. It's not tied to your laptop - talk to it from Telegram while it works on a cloud VM.](https://github.com/NousResearch/hermes-agent)
  - [loupe: A privacy-focused iOS app that raises awareness about what native apps can see(https://apps.apple.com/cn/app/loupe-app%E8%83%BD%E7%9C%8B%E5%88%B0%E4%BB%80%E4%B9%88/id6766152470)](https://github.com/mysk-research/loupe)
  - [LaunchNext: Bring your Launchpad back in MacOS26+ ,highly customizable, powerful, free.](https://github.com/RoversX/LaunchNext)
  - [endlessh: SSH tarpit that slowly sends an endless banner](https://github.com/skeeto/endlessh)
  - [iptables-tracer: Trace packets as they go through iptables chains](https://github.com/akerouanton/iptables-tracer)
  - [serverless-dns: The RethinkDNS resolver that deploys to Cloudflare Workers, Deno Deploy, Fastly, and Fly.io](https://github.com/serverless-dns/serverless-dns)
  - [ouch: stands for Obvious Unified Compression Helper. It's a CLI tool for compressing and decompressing various formats.(https://github.com/ouch-org/ouch#supported-formats)](https://github.com/ouch-org/ouch)
  - [shpool: shpool is a service that enables session persistence by allowing the creation of named shell sessions owned by shpool so that the session is not lost if the connection drops. shpool can be thought of as a lighter weight alternative to tmux or GNU screen. While tmux and screen take over the whole terminal and provide window splitting and tiling features, shpool only provides persistent sessions. The biggest advantage of this approach is that shpool does not break native scrollback or copy-paste.](https://github.com/shell-pool/shpool)
  - [capslock: is a capability analysis CLI for Go packages that informs users of which privileged operations a given package can access. This works by classifying the capabilities of Go packages by following transitive calls to privileged standard library operations.](https://github.com/google/capslock)
  - [unregistry: Push docker images directly to remote servers without an external registry](https://github.com/psviderski/unregistry)
  - [NetNewsWire is a free and open-source feed reader for macOS and iOS. It supports RSS, Atom, JSON Feed, and RSS-in-JSON formats.](https://github.com/Ranchero-Software/NetNewsWire)
  - [K4YT3X's Hardened & Optimized Linux Kernel Parameters](https://github.com/k4yt3x/sysctl)
  - [Turso is an in-process SQL database, compatible with SQLite.](https://github.com/tursodatabase/turso)
  - [zizmor is a static analysis tool for GitHub Actions.](https://github.com/zizmorcore/zizmor)
  - [RustFS is a high-performance, distributed object storage system built in Rust.](https://github.com/rustfs/rustfs)
  - [Usage: is a spec and CLI for defining CLI tools. Arguments, flags, environment variables, and config files can all be defined in a Usage spec. It can be thought of like OpenAPI (swagger) for CLIs.](https://github.com/jdx/usage)
  - [SurfSense: An open source, privacy focused alternative to NotebookLM for teams with no data limits.](https://github.com/MODSetter/SurfSense)
  - [ICANN implementation of the Registry Data Access Protocol (RDAP)](https://github.com/icann/icann-rdap)
  - [OpenRDAP is a command line RDAP client implementation in Go.](https://github.com/openrdap/rdap)
- **Article**
  - [1-Click GitHub Token Stealing via a VSCode Bug](https://blog.ammaraskar.com/github-token-stealing/)
  - [Linux 系统误将 chmod 权限改成 了 000，如何恢复?](https://www.zhihu.com/question/590661860)
  - [Laptops all have built-in security tokens these days](https://ahelwer.ca/post/2026-05-08-builtin-u2f/)
  - [Tailscale and RustDesk: Secure remote access to all your desktops](https://tailscale.com/blog/tailscale-rustdesk-remote-desktop-access)
  - [Unexpected security footguns in Go's parsers](https://blog.trailofbits.com/2025/06/17/unexpected-security-footguns-in-gos-parsers/)
  - [君子慎讀](https://marvin.yabi.me/misc/junzishendoo.htm)
  - [辭典中標注的「讀音」和「語音」是什麼？](https://marvin.yabi.me/misc/wenbai.htm)
  - [拜託別再「我汗你」了！](https://marvin.yabi.me/misc/AND.htm)

---

## Linux 系统误将 chmod 权限改成 了 000，如何恢复?

```c
#include <sys/stat.h>

int main() {
    chmod("/usr/bin/chmod", 0755);
    return 0;
}
```

```shell
ubuntu@ubuntu:~$ which chmod
/usr/bin/chmod
ubuntu@ubuntu:~$ ls -lh /usr/bin/chmod
lrwxrwxrwx 1 root root 8 Sep 27  2025 /usr/bin/chmod -> gnuchmod
ubuntu@ubuntu:~$ ls -lh /usr/bin/gnuchmod
-rwxr-xr-x 1 root root 67K Jan 23 21:34 /usr/bin/gnuchmod
ubuntu@ubuntu:~$ sudo chmod 000 /usr/bin/chmod
ubuntu@ubuntu:~$ ls -lh /usr/bin/chmod
lrwxrwxrwx 1 root root 8 Sep 27  2025 /usr/bin/chmod -> gnuchmod
ubuntu@ubuntu:~$ ls -lh /usr/bin/gnuchmod
---------- 1 root root 67K Jan 23 21:34 /usr/bin/gnuchmod
ubuntu@ubuntu:~$ cat main.c
#include <sys/stat.h>

int main() {
    chmod("/usr/bin/chmod", 0755);
    return 0;
}

ubuntu@ubuntu:~$ gcc ./main.c
ubuntu@ubuntu:~$ sudo ./a.out
ubuntu@ubuntu:~$ ls -lh /usr/bin/chmod
lrwxrwxrwx 1 root root 8 Sep 27  2025 /usr/bin/chmod -> gnuchmod
ubuntu@ubuntu:~$ ls -lh /usr/bin/gnuchmod
-rwxr-xr-x 1 root root 67K Jan 23 21:34 /usr/bin/gnuchmod
```

---

## Laptops all have built-in security tokens these days

### macOS

> https://github.com/yubico/libfido2
>
> `$ brew install libfido2`

#### 1. 建立 Secure Enclave 身份

> 建立一個受 Touch ID 保護的金鑰

```bash
sc_auth create-ctk-identity -l ssh -k p-256-ne -t bio
```

#### 2. 產生 SSH Key

> 真正私鑰在 Secure Enclave 裡

```bash
ssh-keygen -w /usr/lib/ssh-keychain.dylib -K -N ""

id_ecdsa_sk_rk
id_ecdsa_sk_rk.pub
```

#### 3. SSH 設定 `~/.ssh/config`

```shell
Host *
  IdentityFile ~/.ssh/id_ecdsa_sk_rk
  SecurityKeyProvider=/usr/lib/ssh-keychain.dylib
```

#### 4. 上傳 Public Key 或手動加入 `~/.ssh/authorized_keys`

```bash
ssh-copy-id -i ~/.ssh/id_ecdsa_sk_rk.pub server
```

#### 5. SSH 登入 Mac 會跳 Touch ID 驗證

```bash
ssh server
```

驗證成功才會使用私鑰簽章。

### Git Commit Signing 額外步驟

直接指定 key 會失敗：

```bash
git config --global user.signingKey ~/.ssh/id_ecdsa_sk_rk
device not found
```

必須改成：

#### 1. 加入 ssh-agent

```bash
ssh-add -K -S /usr/lib/ssh-keychain.dylib
```

#### 2. Git 使用 Agent Key

```ini
[user]
    signingKey = "key::<pubkey>"
```

格式：

```text
key:: + id_ecdsa_sk_rk.pub 內容
```

之後 `git commmit`會要求 Touch ID：

### Windows

作者測試：

```powershell
winget install Microsoft.OpenSSH.preview

ssh-keygen -t ecdsa-sk
```

之後 SSH 時：

- Windows Hello
- 臉部辨識
- 指紋
- PIN

---

## Tailscale and RustDesk: Secure remote access to all your desktops

### RustDesk Server(https://github.com/rustdesk/rustdesk-server)

https://rustdesk.com/docs/en/self-host/rustdesk-server-oss/docker/

```yml
services:
  hbbs:
    container_name: hbbs
    image: rustdesk/rustdesk-server:latest
    command: hbbs
    volumes:
      - ./data:/root
    network_mode: "host"

    depends_on:
      - hbbr
    restart: unless-stopped

  hbbr:
    container_name: hbbr
    image: rustdesk/rustdesk-server:latest
    command: hbbr
    volumes:
      - ./data:/root
    network_mode: "host"
    restart: unless-stopped
```

- **hbbs**:
  - 21114 (TCP): used for web console, only available in Pro version.
  - 21115 (TCP): used for the NAT type test.
  - 21116 (TCP/UDP): Please note that 21116 should be enabled both for TCP and UDP. 21116/UDP is used for the ID registration and heartbeat service. 21116/TCP is used for TCP hole punching and connection service.
  - 21118 (TCP): used to support web clients.
- **hbbr**:
  21117 (TCP): used for the Relay services.
  21119 (TCP): used to support web clients.

After the server is running, clients usually need the ID Server address and the server public Key. The key is usually generated on the first run of **hbbs** and can be found in the file `id_ed25519.pub` in your working directory `/data` folder.

### RustDesk Client(https://github.com/rustdesk/rustdesk)

**Docker**

```bash
docker run -d \
  --name rustdesk-client \
  -p 6901:6901 \
  -e VNC_PW=password \
  rustdesk/rustdesk:latest
```

Settings -> Security -> Enable direct IP access

---

## Unexpected security footguns in Go's parsers

1. Implement strict parsing by default. Use DisallowUnknownFields for JSON, KnownFields(true) for YAML. Unfortunately, this is all you can do directly with the Go parser APIs.
2. Maintain consistency across boundaries. When input in processed in multiple services, ensure consistent parsing behavior by always using the same parser or implement additional validation layers, such as the strictJSONParse function shown above.
3. Watch for JSON v2.
4. Leverage static analysis. Use the Semgrep rules we've provided to detect a few vulnerable patterns in your codebase, particularly the misuse of the `-` tag and omitempty fields. Try them with `semgrep -c r/trailofbits.go.unmarshal_tag_is_dash.unmarshal-tag-is-dash` and `semgrep -c r/trailofbits.go.unmarshal_tag_is_omitempty.unmarshal-tag-is-omitempty`!

---
