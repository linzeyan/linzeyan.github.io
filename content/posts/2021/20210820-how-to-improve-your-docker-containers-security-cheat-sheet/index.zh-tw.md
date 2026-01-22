---
title: "Docker 安全最佳實務：速查表"
date: 2021-08-20T23:14:30+08:00
menu:
  sidebar:
    name: "Docker 安全最佳實務：速查表"
    identifier: docker-how-to-improve-your-docker-containers-security-cheat-sheet
    weight: 10
tags: ["Links", "Docker"]
categories: ["Links", "Docker"]
hero: images/hero/docker.jpeg
---

- [Docker 安全最佳實務：速查表](https://blog.gitguardian.com/how-to-improve-your-docker-containers-security-cheat-sheet/)

### 映像安全

#### 使用可信任的映像

#### 非特權使用者

```dockerfile
FROM base_image
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

#### User ID 命名空間

> 隔離命名空間，避免容器權限提升影響主機。

為了降低風險，請在主機與 Docker daemon 上使用 `--userns-remap` 選項設定獨立的命名空間。

### 容器執行期安全

#### 禁止新增權限

為了提升安全性，建議在建立容器後明確禁止新增權限：`--security-opt=no-new-privileges`。

#### 定義細粒度能力

例如，Web 伺服器可能只需要 `NET_BIND_SERVICE` 來綁定 80 連接埠。

#### 控制資源使用

`docker run --memory="400m" --cpus="0.5" `

### 主機系統安全

#### 敏感檔案系統區域

若需要存取主機設備，請謹慎以 `[r|w|m]` 旗標（`read`、`write`、`mknod`）開啟必要權限。

#### 容器檔案系統存取

`docker run --read-only --tmpfs /tmp:rw ,noexec,nosuid `

#### 持久化儲存

如果需要和主機檔案系統或其他容器共享資料，有兩種做法：

- 使用可限制磁碟空間的 bind mount（`--mount type=bind,o=size`）
- 為專用分割區建立 bind volume（`--mount type=volume`）

### 網路安全

#### Docker daemon socket

Docker 使用的 UNIX socket 不應暴露：`/var/run/docker.sock`

#### 自訂網路橋接

避免使用 Docker 預設的 `docker0` 網路橋接；請建立自訂網路以隔離容器。

### Docker 安全掃描與弱點管理

- 基礎映像掃描：定期掃描基礎映像的已知 CVE，例如使用
  - [Trivy](https://github.com/aquasecurity/trivy?ref=blog.gitguardian.com)
  - [Snyk](https://github.com/snyk/snyk?ref=blog.gitguardian.com)
  - `Clair`
  - [ggshield](https://github.com/GitGuardian/ggshield?ref=blog.gitguardian.com)
- 相依性分析
- 執行期監控
- 持續整合

```bash
# Scan image before deployment
trivy image myapp:latest --severity HIGH,CRITICAL
# Fail build if critical vulnerabilities found
trivy image myapp:latest --exit-code 1 --severity CRITICAL
```

### Docker 密鑰管理與設定安全

- Docker Secrets 服務

```bash
# Create and use Docker secret
echo "my_secret_password" | docker secret create db_password -
docker service create --secret db_password myapp:latest
```

- 外部密鑰管理：整合企業級密鑰管理方案，例如

  - HashiCorp Vault
  - AWS Secrets Manager
  - Azure Key Vault

- 環境變數安全：若必須使用環境變數，建議用 init container 或 sidecar 在執行期取得密鑰，而不是把密鑰寫入映像。切勿把密鑰寫入 Dockerfile 或提交到版本控制。
- 密鑰掃描：導入自動化密鑰偵測工具（例如 GitGuardian 的 ggshield）掃描容器映像與原始碼，避免密鑰被意外暴露。

### Docker Registry 安全與供應鏈防護

- Registry 存取控制：使用最小權限的 RBAC。對自動化系統，採用多因素驗證與權限範圍受限的服務帳號。
- 映像簽章與驗證：使用 Docker Content Trust 或 Notary 對映像進行簽章與驗證，確保映像在存放與傳輸過程未被竄改。

```bash
# Enable content trust
export DOCKER_CONTENT_TRUST=1
docker push myregistry.com/myapp:latest
```

- Registry 掃描：設定 registry 自動掃描推送的映像，並建立 admission controller 阻擋不符合安全政策的映像。
- 供應鏈監控
- 網路安全：使用 TLS 加密保護 registry 通訊，並透過防火牆或 VPN 限制存取。敏感應用建議使用私有 registry，而不是公開倉庫。
