---
title: "VSCode Integration with DevSpace for Debugging!"
date: 2025-12-10T15:16:12+08:00
menu:
  sidebar:
    name: "VSCode Integration with DevSpace for Debugging!"
    identifier: ide-vscode-debug-with-devspace
    weight: 10
tags: ["Links", "VSCode"]
categories: ["Links", "VSCode"]
---

- [VSCode Integration with DevSpace for Debugging!](https://ithelp.ithome.com.tw/articles/10377156)
- [DevSpace](https://github.com/devspace-sh/devspace)

### Install required tools 📦

```shell
# Check Go version
go version

# Install the Delve debugger
go install github.com/go-delve/delve/cmd/dlv@latest

# Check DevSpace version
devspace version

# Install VSCode Go extensions
code --install-extension golang.go
code --install-extension devspace.devspace
```

### Project structure design 📁

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

#### Prepare the Go application 🚀

First, build a simple but practical Go application with a few API endpoints so you can test breakpoints.

To debug Go, besides the API port you also need `SSH port 22` and the `Delve debugger port 40000`.

**_`Dockerfile.dev` - Development container config_**

This file builds a container environment dedicated to development and debugging.

```dockerfile
FROM golang:1.24

# 🛠️ Install development tools
# - git: version control
# - curl/wget: network tools for API tests
# - vim/nano: edit files inside the container
# - openssh-server: SSH access
# - build-essential: build toolchain
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

# 🔧 Install the latest Delve debugger
# Delve is the official Go debugger and supports remote debugging
RUN go install github.com/go-delve/delve/cmd/dlv@v1.23.1

# 👤 Create a dev user (avoid running as root)
RUN useradd -m -s /bin/bash developer && \
    echo "developer:devspace123" | chpasswd && \
    usermod -aG sudo developer

# 🔑 Configure SSH service (remote access)
RUN mkdir -p /var/run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 22/' /etc/ssh/sshd_config

# 📁 Set working directory
WORKDIR /app

# 📦 Copy dependency files and download
COPY go.mod go.sum ./
RUN go mod download

# 📋 Copy source code
COPY . .

# 🔨 Build a debug binary
# -gcflags="all=-N -l" disables optimizations and keeps debug info
RUN go build -gcflags="all=-N -l" -o main cmd/main.go

# 🌐 Expose ports
# 8080: app service
# 40000: Delve debugger
# 22: SSH service
EXPOSE 8080 40000 22

# 🚀 Copy startup script
COPY start-dev.sh /app/start-dev.sh
RUN chmod +x /app/start-dev.sh

# 🎯 Default command
CMD ["/app/start-dev.sh"]
```

**_🚀 `start-dev.sh` - Development startup script_**

This script orchestrates the startup flow of the development environment.

```bash
#!/bin/bash
set -e  # Exit immediately on error

echo "🚀 Starting development environment..."

# 🔑 Start SSH service (remote access)
echo "🔑 Starting SSH service..."
service ssh start

# 🔍 Check Delve version (make sure the debugger is available)
echo "🐛 Delve version:"
dlv version

# 🔨 Rebuild the application
echo "🔨 Building application..."
go build -gcflags="all=-N -l" -o main cmd/main.go

# 🐛 Start the Delve debugger
# --listen=:40000: listen on port 40000
# --headless=true: no GUI
# --api-version=2: use API v2 (DAP support)
# --accept-multiclient: allow multiple clients
# --continue: continue running after start
# --log: enable logs
echo "🐛 Starting Delve debugger on port 40000..."
dlv --listen=:40000 --headless=true --api-version=2 --accept-multiclient --continue --log exec ./main &

# ⏳ Wait for the debugger to start
sleep 5
echo "✅ Delve debugger started successfully!"

# 📊 Show service info
echo "🌐 Application available on port 8080"
echo "🔑 SSH available on port 22 (user: developer, pass: devspace123)"
echo "🐛 Debug port available on 40000"

# 🔍 Check port status
echo "📊 Checking ports..."
netstat -tlnp | grep -E "(8080|40000)" || echo "Ports not ready yet"

echo "📱 Development environment ready!"

# 🔄 Keep the container running
tail -f /dev/null
```

**_⚙️ `devspace.yaml` - DevSpace configuration_**

This file defines the full configuration for the development environment.

```yaml
version: v2beta1
name: go-debug-demo

# 🖼️ Image config: define how to build the container image
images:
  app:
    image: go-debug-demo
    dockerfile: ./Dockerfile.dev # Use the dev Dockerfile
    tags:
      - dev-${DEVSPACE_RANDOM} # Dynamic tag to avoid cache issues

# 🚀 Deployment config: define how to deploy to Kubernetes
deployments:
  app:
    kubectl:
      manifests:
        - k8s/dev/deployment.yaml
        - k8s/dev/service.yaml

# 🔄 Dev config: define dev-mode behavior
dev:
  app:
    # 🎯 Select the Pod to attach to
    labelSelector:
      app: go-debug-demo

    # 📁 File sync: sync local changes into the container
    sync:
      - path: ./
        container: /app
        excludePaths:
          - .git/
          - .devspace/
          - Dockerfile*

    # 🌐 Port forwarding: map container ports to local machine
    ports:
      - port: "8080:8080" # App service
      - port: "40000:40000" # Delve debugger
      - port: "2222:22" # SSH service

    # 🖥️ Terminal: open an interactive terminal
    terminal:
      command: ./start-dev.sh

# 🎯 Variables
vars:
  - name: DEVSPACE_RANDOM
    source: none
```

**_🎛️ VSCode `launch.json` - Debugger config_**

This file tells VSCode how to connect to the remote debugger.

```json
{
	"version": "0.2.0",
	"configurations": [
		{
			"name": "🐛 DevSpace Remote Debug",
			"type": "go", // Use Go debugger
			"request": "attach", // Attach to an existing process (instead of launching a new one)
			"mode": "remote", // Remote debugging mode
			"remotePath": "/app", // Code path in the container
			"port": 40000, // Delve debugger port
			"host": "127.0.0.1", // Connect to local (port forwarding)
			"apiVersion": 2, // Use Delve API v2

			// 📁 Path mapping: local path <-> container path
			"substitutePath": [
				{
					"from": "${workspaceFolder}", // VSCode workspace path
					"to": "/app" // Container path
				}
			],

			// 🔍 Debugger logging
			"showLog": true,
			"logOutput": "debugger",

			// ⚙️ Delve load config
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

#### Start and test 🧪

```shell
# 1️⃣ Start the development environment
devspace dev

# 2️⃣ Set breakpoints in VSCode
# - Open cmd/main.go
# - Click the first line of healthHandler to set a breakpoint

# 3️⃣ Start the debugger
# - Press F5 or click "🐛 DevSpace Remote Debug" in the debug panel

# 4️⃣ Trigger the breakpoint
curl http://localhost:8080/health
```
