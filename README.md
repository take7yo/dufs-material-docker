# 🐳 dufs-material-docker

> **[dufs](https://github.com/sigoden/dufs) + [Material Design UI](https://github.com/TransparentLC/dufs-material-assets) — 打包为 Docker 镜像，多架构自动构建**

[![Docker Build](https://github.com/take7yo/dufs-material-docker/actions/workflows/docker-build.yml/badge.svg)](https://github.com/take7yo/dufs-material-docker/actions/workflows/docker-build.yml)
[![Docker Hub](https://img.shields.io/docker/v/take7yo/dufs?label=Docker%20Hub&sort=semver)](https://hub.docker.com/r/take7yo/dufs)

---

## ✨ 特性

| 特性 | 说明 |
|------|------|
| **Material Design UI** | 内置 [dufs-material-assets](https://github.com/TransparentLC/dufs-material-assets)，替代原生 UI |
| **多架构支持** | `linux/amd64` · `linux/arm64` · `linux/arm/v7` |
| **自动更新** | 每日检查上游新版本，自动构建发布 |
| **极简镜像** | 基于 `scratch`，仅包含二进制 + UI 资源 |
| **双仓库推送** | Docker Hub (`take7yo/dufs`) + 阿里云 ACR (`registry.cn-hangzhou.aliyuncs.com/take7yo/dufs`) |

---

## 🚀 快速开始

```bash
# 基本用法：挂载目录，开启所有权限
docker run -d \
  --name dufs \
  -p 5000:5000 \
  -v /path/to/share:/data \
  take7yo/dufs

# 带认证
docker run -d \
  --name dufs \
  -p 5000:5000 \
  -v /path/to/share:/data \
  -e DUFS_ALLOW_ALL=true \
  -e DUFS_AUTH="user:pass@/:rw" \
  take7yo/dufs
```

浏览器访问 `http://localhost:5000` 即可看到 Material Design 风格的文件管理界面。

---

## 🐙 Docker Compose

```yaml
services:
  dufs:
    image: take7yo/dufs
    container_name: dufs
    restart: unless-stopped
    ports:
      - "5000:5000"
    volumes:
      - ./data:/data
    environment:
      - DUFS_ALLOW_ALL=true
      # - DUFS_AUTH=user:pass@/:rw
      # - DUFS_PORT=5000
      # - DUFS_BIND=0.0.0.0
```

```bash
docker compose up -d
```

---

## ⚙️ 环境变量

所有 `DUFS_*` 环境变量均可直接使用（[完整列表](https://github.com/sigoden/dufs#cli-options)）：

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `DUFS_SERVE_PATH` | `/data` | 服务目录路径 |
| `DUFS_PORT` | `5000` | 监听端口 |
| `DUFS_BIND` | `0.0.0.0` | 绑定地址 |
| `DUFS_ALLOW_ALL` | *(未设置)* | 设为 `true` 开启所有操作权限 |
| `DUFS_AUTH` | *(未设置)* | 认证规则，如 `user:pass@/:rw` |
| `DUFS_TLS_CERT` | *(未设置)* | TLS 证书路径 |
| `DUFS_TLS_KEY` | *(未设置)* | TLS 私钥路径 |

---

## 🏗️ 架构

```
┌──────────────────────────────────────────────────────────┐
│  GitHub Actions (daily schedule / release / manual)      │
│                                                          │
│  1. 检查 TransparentLC/dufs-material-assets 新版本       │
│  2. docker buildx build --platform amd64,arm64,arm/v7   │
│     ├─ 下载 sigoden/dufs 预编译二进制                     │
│     ├─ 下载 material-assets-embed.zip                    │
│     └─ 打包为 scratch 镜像                               │
│  3. 推送至 Docker Hub + 阿里云 ACR                        │
└──────────────────────────────────────────────────────────┘
```

---

## 📦 镜像标签

| 标签 | 说明 |
|------|------|
| `latest` | 最新版本 |
| `v0.46.0` | 指定版本号（带 `v` 前缀） |

---

## 🔧 本地构建

```bash
# 安装 buildx 插件
docker buildx create --use

# 本地单架构构建
docker buildx build --load -t dufs-local .

# 多架构构建并推送
docker buildx build \
  --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t take7yo/dufs:latest \
  --push .
```

---

## 📋 GitHub Secrets 配置

在仓库 **Settings → Secrets and variables → Actions** 中添加以下 Secrets：

### Docker Hub (`docker.io`)

| Secret | 值 | 获取方式 |
|--------|-----|---------|
| `DOCKERHUB_USERNAME` | 你的 Docker Hub 用户名 | — |
| `DOCKERHUB_TOKEN` | Access Token | [hub.docker.com/settings/security](https://hub.docker.com/settings/security) → New Access Token |

### 阿里云 ACR (`registry.cn-hangzhou.aliyuncs.com`)

| Secret | 值 | 获取方式 |
|--------|-----|---------|
| `ACR_USERNAME` | ACR 登录用户名 | 阿里云控制台 → 容器镜像服务 → 访问凭证 |
| `ACR_PASSWORD` | ACR 登录密码 | 同上，设置固定密码 |

> ⚠️ 阿里云 ACR 需要先在控制台创建命名空间 `take7yo` 和仓库 `dufs`。

---

## 📄 License

MIT License — 详见 [LICENSE](./LICENSE)

上游项目：
- [sigoden/dufs](https://github.com/sigoden/dufs) — Apache-2.0
- [TransparentLC/dufs-material-assets](https://github.com/TransparentLC/dufs-material-assets) — MIT
