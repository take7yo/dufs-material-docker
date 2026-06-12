# dufs-material-docker

> 🐳 基于 [dufs](https://github.com/sigoden/dufs) + [dufs-material-assets](https://github.com/TransparentLC/dufs-material-assets) 的 Docker 镜像，内置 Material Design UI

## ✨ 特性

- 🎨 **Material Design UI** - Vue 3 + Vuetify 现代界面
- 🔧 **源码编译** - 从 Rust 源码编译，透明可审计
- 🏗️ **5 架构支持** - `amd64` · `arm64` · `armv7` · `armv6` · `i386`
- 🔄 **自动更新** - 每日检查上游新版本
- ⚙️ **灵活配置** - 支持自定义界面和 `config.yml`
- 📦 **极简镜像** - 基于 `scratch`，仅 ~10MB

## 🚀 快速开始

```bash
docker run -d \
  --name dufs \
  -p 5000:5000 \
  -v /path/to/share:/data \
  take7yo/dufs
```

访问 `http://localhost:5000` 即可使用。

## 🏷️ 镜像标签

| 标签 | 说明 |
|------|------|
| `latest` / `v0.46.0` | **Assets 版**（默认推荐）- 源码编译 + assets 资源包 |
| `v0.46.0-embed` | **嵌入式 UI 版** - 预构建二进制，UI 嵌入 |
| `v0.46.0-fix` | **Fix 版** - 手动触发，源码编译 |

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
```

## ⚙️ 环境变量

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `DUFS_PORT` | `5000` | 监听端口 |
| `DUFS_BIND` | `0.0.0.0` | 绑定地址 |
| `DUFS_ALLOW_ALL` | *(未设置)* | 设为 `true` 开启所有操作权限 |
| `DUFS_AUTH` | *(未设置)* | 认证规则，如 `user:pass@/:rw` |
| `DUFS_TLS_CERT` | *(未设置)* | TLS 证书路径 |
| `DUFS_TLS_KEY` | *(未设置)* | TLS 私钥路径 |

## 🎨 自定义界面

```bash
# 挂载自定义 assets 目录
docker run -d -p 5000:5000 \
  -v /path/to/share:/data \
  -v /path/to/custom/assets:/opt/dufs/assets \
  take7yo/dufs
```

从 [dufs-material-assets](https://github.com/TransparentLC/dufs-material-assets/releases) 下载默认 assets。

## 📄 License

MIT License

## 🔗 链接

- [GitHub 仓库](https://github.com/take7yo/dufs-material-docker)
- [dufs 官方仓库](https://github.com/sigoden/dufs)
- [Material UI 资源](https://github.com/TransparentLC/dufs-material-assets)
