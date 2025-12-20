---
title: "Docker Security Best Practices: Cheat Sheet"
date: 2021-08-20T23:14:30+08:00
menu:
  sidebar:
    name: "Docker Security Best Practices: Cheat Sheet"
    identifier: docker-how-to-improve-your-docker-containers-security-cheat-sheet
    weight: 10
tags: ["URL", "Docker"]
categories: ["URL", "Docker"]
hero: images/hero/docker.jpeg
---

- [Docker Security Best Practices: Cheat Sheet](https://blog.gitguardian.com/how-to-improve-your-docker-containers-security-cheat-sheet/)

### Image Security

#### Use Trusted Images

#### Unprivileged User

```dockerfile
FROM base_image
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

#### User ID Namespace

> Segregate namespaces to prevent container privilege escalation from affecting the host.

To mitigate this risk, configure your host and the Docker daemon to use a separate namespace with the `--userns-remap` option.

### Container Runtime Security

#### Forbid New Privileges

For enhanced security, it is recommended to explicitly forbid the addition of new privileges after container creation using this option: `--security-opt=no-new-privileges`.

#### Define Fine-grained Capabilities

For example, a web server would probably only need the `NET_BIND_SERVICE` capability to bind the port 80.

#### Control Group Utilization

`docker run --memory="400m" --cpus="0.5" `

### Host System Security

#### Sensitive Filesystem Parts

If you need access to host devices, be careful to selectively enable the access options with the `[r|w|m]` flags (`read`, `write`, and use `mknod`).

#### Container Filesystem Access

`docker run --read-only --tmpfs /tmp:rw ,noexec,nosuid `

#### Persistent Storage

If you need to share data with the host filesystem or other containers, you have two options:

- Create a bind mount with limited useable disk space (`--mount type=bind,o=size`)
- Create a bind volume for a dedicated partition (`--mount type=volume`)

### Network Security

#### Docker Daemon Socket Docker

The UNIX socket used by the Docker should not be exposed: `/var/run/docker.sock`

#### Custom Network Bridges

Avoid Docker's default `docker0` network bridge; create custom networks for container isolation.

### Docker Security Scanning and Vulnerability Management

- Base Image Scanning: Regularly scan base images for known CVEs using tools like
  - [Trivy](https://github.com/aquasecurity/trivy?ref=blog.gitguardian.com)
  - [Snyk](https://github.com/snyk/snyk?ref=blog.gitguardian.com)
  - `Clair`
  - [ggshield](https://github.com/GitGuardian/ggshield?ref=blog.gitguardian.com)
- Dependency Analysis
- Runtime Monitoring
- Continuous Integration

```bash
# Scan image before deployment
trivy image myapp:latest --severity HIGH,CRITICAL
# Fail build if critical vulnerabilities found
trivy image myapp:latest --exit-code 1 --severity CRITICAL
```

### Docker Secrets Management and Configuration Security

- Docker Secrets Service

```bash
# Create and use Docker secret
echo "my_secret_password" | docker secret create db_password -
docker service create --secret db_password myapp:latest
```

- External Secret Management: Integrate with enterprise secret management solutions like

  - HashiCorp Vault
  - AWS Secrets Manager
  - Azure Key Vault

- Environment Variable Security: When environment variables are necessary, use init containers or sidecar patterns to fetch secrets at runtime rather than embedding them in images. Never include secrets in Dockerfiles or commit them to version control.
- Secret Scanning: Implement automated secret detection tools like GitGuardian's ggshield to scan container images and source code for accidentally exposed credentials. This prevents secrets from entering your container supply chain.

### Docker Registry Security and Supply Chain Protection

- Registry Access Controls: Implement role-based access control (RBAC) with least-privilege principles. Use strong authentication mechanisms like multi-factor authentication and service accounts with limited scopes for automated systems.
- Image Signing and Verification: Deploy Docker Content Trust or Notary to cryptographically sign images and verify their integrity. This ensures images haven't been tampered with during storage or transmission.

```bash
# Enable content trust
export DOCKER_CONTENT_TRUST=1
docker push myregistry.com/myapp:latest
```

- Registry Scanning: Configure your registry to automatically scan pushed images for vulnerabilities and malware. Implement admission controllers that prevent deployment of images failing security policies.
- Supply Chain Monitoring
- Network Security: Secure registry communications using TLS encryption and restrict network access through firewalls or VPNs. Consider using private registries for sensitive applications rather than public repositories.
