---
title: "VsCode 整合 DevSpace 進行 debug !"
date: 2025-12-10T15:16:12+08:00
menu:
  sidebar:
    name: "VsCode 整合 DevSpace 進行 debug !"
    identifier: ide-vscode-debug-with-devspace
    weight: 10
tags: ["URL", "VSCode"]
categories: ["URL", "VSCode"]
---

- [VsCode 整合 DevSpace 進行 debug !](https://ithelp.ithome.com.tw/articles/10377156)
- [DevSpace](https://github.com/devspace-sh/devspace)

### 安裝必要工具 📦

```shell
# 確認 Go 版本
go version

# 安裝 Delve 除錯器
go install github.com/go-delve/delve/cmd/dlv@latest

# 確認 DevSpace 版本
devspace version

# 安裝 VSCode Go 擴充功能
code --install-extension golang.go
code --install-extension devspace.devspace
```

### 專案結構設計 📁

```shell
.
├── cmd
│   └── main.go
├── devspace.yaml
├── Dockerfile.dev
├── Dockerfile.prod
├── go.mod
├── go.sum
├── internal
│   ├── handler.go
│   ├── model.go
│   └── service.go
├── k8s
│   └── dev
│       ├── deployment.yaml
│       └── service.yaml
├── main
└── start-dev.sh
```

#### 準備 Go 應用程式 🚀

首先，讓我們建立一個簡單但實用的 Go 應用程式，包含幾個 API 端點方便我們測試 Break Points

要 Debug Go 除了需要 API Port 之外，還需要 `SSH port 22` 和 `Delve debugger port 40000`

**_`Dockerfile.dev` - 開發環境容器配置_**

這個檔案的作用是建立一個專門用於開發和 debug 的容器環境

```dockerfile
FROM golang:1.24

# 🛠️ 安裝開發必需工具
# - git: 版本控制
# - curl/wget: 網路工具，測試 API
# - vim/nano: 容器內編輯檔案
# - openssh-server: 支援 SSH 連線
# - build-essential: 編譯工具
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    vim \
    nano \
    htop \
    openssh-server \
    sudo \
    build-essential \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 🔧 安裝最新版本的 Delve 除錯器
# Delve 是 Go 的官方除錯器，支援遠端除錯
RUN go install github.com/go-delve/delve/cmd/dlv@v1.23.1

# 👤 建立開發使用者 (安全考量，避免使用 root)
RUN useradd -m -s /bin/bash developer && \
    echo "developer:devspace123" | chpasswd && \
    usermod -aG sudo developer

# 🔑 配置 SSH 服務 (支援遠端連線)
RUN mkdir -p /var/run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config

# 📁 設定工作目錄
WORKDIR /app

# 📦 複製依賴檔案並下載
COPY go.mod go.sum ./
RUN go mod download

# 📋 複製原始碼
COPY . .

# 🔨 建立除錯版本的執行檔
# -gcflags="all=-N -l" 關閉編譯器優化，保留除錯資訊
RUN go build -gcflags="all=-N -l" -o main cmd/main.go

# 🌐 暴露埠號
# 8080: 應用程式服務
# 40000: Delve 除錯器
# 22: SSH 服務
EXPOSE 8080 40000 22

# 🚀 複製啟動腳本
COPY start-dev.sh /app/start-dev.sh
RUN chmod +x /app/start-dev.sh

# 🎯 預設啟動命令
CMD ["/app/start-dev.sh"]
```

**_🚀 `start-dev.sh` - 開發環境啟動腳本_**

這個腳本的作用是統一管理開發環境的啟動流程

```bash
#!/bin/bash
set -e  # 遇到錯誤立即退出

echo "🚀 Starting development environment..."

# 🔑 啟動 SSH 服務 (支援遠端連線)
echo "🔑 Starting SSH service..."
service ssh start

# 🔍 檢查 Delve 版本 (確保除錯器可用)
echo "🐛 Delve version:"
dlv version

# 🔨 重新編譯應用程式
echo "🔨 Building application..."
go build -gcflags="all=-N -l" -o main cmd/main.go

# 🐛 啟動 Delve debgger
# --listen=:40000: 監聽 40000 埠
# --headless=true: 無 GUI 模式
# --api-version=2: 使用 API v2 (支援 DAP)
# --accept-multiclient: 允許多個客戶端連線
# --continue: 啟動後繼續執行程式
# --log: 啟用日誌
echo "🐛 Starting Delve debugger on port 40000..."
dlv --listen=:40000 --headless=true --api-version=2 --accept-multiclient --continue --log exec ./main &

# ⏳ 等待 debugger 啟動
sleep 5
echo "✅ Delve debugger started successfully!"

# 📊 顯示服務資訊
echo "🌐 Application available on port 8080"
echo "🔑 SSH available on port 22 (user: developer, pass: devspace123)"
echo "🐛 Debug port available on 40000"

# 🔍 檢查埠號狀態
echo "📊 Checking ports..."
netstat -tlnp | grep -E "(8080|40000)" || echo "Ports not ready yet"

echo "📱 Development environment ready!"

# 🔄 保持容器運行
tail -f /dev/null
```

**_⚙️ `devspace.yaml` - DevSpace 配置檔_**

這個檔案的作用是定義開發環境的完整配置

```yaml
version: v2beta1
name: go-debug-demo

# 🖼️ 映像檔配置：定義如何建立容器映像檔
images:
  app:
    image: go-debug-demo
    dockerfile: ./Dockerfile.dev # 使用開發版 Dockerfile
    tags:
      - dev-${DEVSPACE_RANDOM} # 動態標籤，避免快取問題

# 🚀 部署配置：定義如何部署到 Kubernetes
deployments:
  app:
    kubectl:
      manifests:
        - k8s/dev/deployment.yaml
        - k8s/dev/service.yaml

# 🔄 開發配置：定義開發模式行為
dev:
  app:
    # 🎯 選擇要連接的 Pod
    labelSelector:
      app: go-debug-demo

    # 📁 檔案同步：本地檔案變更自動同步到容器
    sync:
      - path: ./
        container: /app
        excludePaths:
          - .git/
          - .devspace/
          - Dockerfile*

    # 🌐 埠號轉發：將容器埠號對應到本機
    ports:
      - port: "8080:8080" # 應用程式服務
      - port: "40000:40000" # Delve 除錯器
      - port: "2222:22" # SSH 服務

    # 🖥️ 終端機：開啟互動式終端
    terminal:
      command: ./start-dev.sh

# 🎯 變數配置
vars:
  - name: DEVSPACE_RANDOM
    source: none
```

**_🎛️ VSCode `launch.json` - 除錯器配置_**

這個檔案的作用是告訴 VSCode 如何連接到遠端除錯器

```json
{
	"version": "0.2.0",
	"configurations": [
		{
			"name": "🐛 DevSpace Remote Debug",
			"type": "go", // 使用 Go 除錯器
			"request": "attach", // 附加到現有process (而非啟動新process)
			"mode": "remote", // 遠端除錯模式
			"remotePath": "/app", // 容器內的程式碼路徑
			"port": 40000, // Delve 除錯器埠號
			"host": "127.0.0.1", // 連接到本機 (因為有埠號轉發)
			"apiVersion": 2, // 使用 Delve API v2

			// 📁 路徑對應：本地路徑 <-> 容器路徑
			"substitutePath": [
				{
					"from": "${workspaceFolder}", // VSCode 工作區路徑
					"to": "/app" // 容器內對應路徑
				}
			],

			// 🔍 除錯日誌設定
			"showLog": true,
			"logOutput": "debugger",

			// ⚙️ Delve 載入配置
			"dlvLoadConfig": {
				"followPointers": true,
				"maxVariableRecurse": 1,
				"maxStringLen": 64,
				"maxArrayValues": 64,
				"maxStructFields": -1
			}
		}
	]
}
```

#### 啟動和測試 🧪

```shell
# 1️⃣ 啟動開發環境
devspace dev

# 2️⃣ 在 VSCode 中設置斷點
# - 打開 cmd/main.go
# - 在 healthHandler 函數第一行點擊設置斷點

# 3️⃣ 啟動除錯器
# - 按 F5 或點擊除錯面板中的 "🐛 DevSpace Remote Debug"

# 4️⃣ 觸發斷點
curl http://localhost:8080/health
```
