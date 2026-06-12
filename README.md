# 🐳 dufs-material-docker

> **基于 [dufs](https://github.com/sigoden/dufs) + [dufs-material-assets](https://github.com/TransparentLC/dufs-material-assets)，打包为 Docker 镜像，多架构自动构建**

[![Docker Build](https://github.com/take7yo/dufs-material-docker/actions/workflows/docker-build.yml/badge.svg)](https://github.com/take7yo/dufs-material-docker/actions/workflows/docker-build.yml)
[![Manual Build](https://github.com/take7yo/dufs-material-docker/actions/workflows/docker-manual.yml/badge.svg)](https://github.com/take7yo/dufs-material-docker/actions/workflows/docker-manual.yml)
[![Docker Hub](https://img.shields.io/docker/v/take7yo/dufs?label=Docker%20Hub&sort=semver)](https://hub.docker.com/r/take7yo/dufs)

---

## ✨ 特性

| 特性 | 说明 |
|------|------|
| **Material Design UI** | 内置 [dufs-material-assets](https://github.com/TransparentLC/dufs-material-assets)，Vue 3 + Vuetify 现代界面 |
| **开箱即用** | 自动构建使用 `dufs-mod` 预构建二进制（UI 已嵌入），手动构建使用 stock dufs + 分离 assets |
| **多架构支持** | 自动构建：`amd64` · `arm64` · `armv7` · `armv6` · `i386`；手动构建：`amd64` · `arm64` · `armv7` · `armv6` |
| **自动更新** | 每日检查上游新版本，自动构建发布 |
| **手动构建** | 支持选择二进制来源（`sigoden/dufs` / `take7yo/dufs`），灵活指定版本 |
| **极简镜像** | 基于 `scratch`，仅包含 dufs 二进制 + CA 证书 |
| **双仓库推送** | Docker Hub (`take7yo/dufs`) + 阿里云 ACR (`registry.cn-hangzhou.aliyuncs.com/take7yo/dufs`) |

---

## 🚀 快速开始

```bash
# 基本用法
docker run -d \
  --name dufs \
  -p 5000:5000 \
  -v /path/to/share:/data \
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

dufs 原生支持 `DUFS_*` 前缀环境变量（[完整列表](https://github.com/sigoden/dufs#cli-options)）：

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `DUFS_PORT` | `5000` | 监听端口 |
| `DUFS_BIND` | `0.0.0.0` | 绑定地址 |
| `DUFS_ALLOW_ALL` | *(未设置)* | 设为 `true` 开启所有操作权限 |
| `DUFS_AUTH` | *(未设置)* | 认证规则，如 `user:pass@/:rw` |
| `DUFS_TLS_CERT` | *(未设置)* | TLS 证书路径 |
| `DUFS_TLS_KEY` | *(未设置)* | TLS 私钥路径 |

---

## 📝 config.yml 使用说明
容器默认通过 ENTRYPOINT 硬编码了 `/data` 作为服务路径。使用 `config.yml` 时需注意：

- 默认将数据挂载到 `/data` 即可，无需额外配置
- `config.yml` 中的 `serve.path` 会被 ENTRYPOINT 的 `/data` 参数覆盖
- 如需使用自定义路径，覆盖 ENTRYPOINT：
  ```bash
  docker run --entrypoint /usr/local/bin/dufs take7yo/dufs /custom/path --assets /opt/dufs/assets
  ```
- 如需完全由 config.yml 控制，覆盖 ENTRYPOINT 移除默认路径参数

---

## 🏗️ 支持架构

| Docker 平台 | Rust Target | 自动构建 | 手动构建 |
|---|---|:---:|:---:|
| `linux/amd64` | `x86_64-unknown-linux-musl` | ✅ | ✅ |
| `linux/arm64` | `aarch64-unknown-linux-musl` | ✅ | ✅ |
| `linux/arm/v7` | `armv7-unknown-linux-musleabihf` | ✅ | ✅ |
| `linux/arm/v6` | `arm-unknown-linux-musleabihf` | ✅ | ✅ |
| `linux/386` | `i686-unknown-linux-musl` | ✅ | ❌ |

> 手动构建支持 4 架构，不支持 `i386`（stock dufs 上游未发布该平台二进制）。

---

## 📦 镜像标签

### 自动构建

| 标签 | 说明 |
|------|------|
| `latest` | 最新自动构建版本 |
| `v0.46.0` | 指定版本号（带 `v` 前缀） |

自动构建每日检查 [TransparentLC/dufs-material-assets](https://github.com/TransparentLC/dufs-material-assets) 新版本，使用该仓库发布的 `dufs-mod` 预构建二进制（Material UI 已直接编译嵌入二进制，无需额外资源包）。

### 手动构建（`-fix` 后缀）

| 标签 | 说明 |
|------|------|
| `latest` | 最新手动构建版本（会覆盖自动构建的 `latest`） |
| `v0.46.0-fix` | 指定版本号（带 `-fix` 后缀） |

手动构建使用 stock dufs 二进制 + [dufs-material-assets](https://github.com/TransparentLC/dufs-material-assets) 资源包组合方式（通过 `--assets` 参数加载 UI），支持选择二进制来源：

| 二进制来源 | 下载地址 | 说明 |
|---|---|---|
| `sigoden/dufs` | [releases](https://github.com/sigoden/dufs/releases) | 原版 dufs，stock 二进制 + 分离 assets |
| `take7yo/dufs` | [releases](https://github.com/take7yo/dufs/releases) | fork 版本，release tag 带 `-fix` 后缀 |

在 [Actions → Manual Build & Publish (-fix)](https://github.com/take7yo/dufs-material-docker/actions/workflows/docker-manual.yml) 中手动触发。

---

## 🔧 本地构建

```bash
git clone https://github.com/take7yo/dufs-material-docker.git
cd dufs-material-docker

docker buildx create --use

# 自动构建版（dufs-mod 嵌入式，5 架构）
docker buildx build --load -t dufs-local .

# 手动构建版（stock dufs + assets，3 架构）
docker buildx build --load -t dufs-local -f Dockerfile.stock \
  --build-arg DUFS_VERSION=0.46.0 \
  --build-arg DUFS_REPO=sigoden/dufs .

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
| `DOCKERHUB_USERNAME` | Docker Hub 用户名 | — |
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
- [sigoden/dufs](https://github.com/sigoden/dufs) — 文件服务器核心（Apache-2.0）
- [TransparentLC/dufs-material-assets](https://github.com/TransparentLC/dufs-material-assets) — Material Design UI + 预构建二进制（MIT）
- [take7yo/dufs](https://github.com/take7yo/dufs) — dufs fork 版本
