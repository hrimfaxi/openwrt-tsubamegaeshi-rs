# tsubamegaeshi-rs OpenWrt Package

燕返 — 轻量级双轨 DNS 分流器，支持基于 IP 的地理决策、缓存和 Xray 集成。

本仓库是 OpenWrt 的 package feed，用于在 OpenWrt SDK 中编译 tsubamegaeshi-rs。

## 前提条件

- OpenWrt SDK（已 `./scripts/feeds update -a && ./scripts/feeds install -a`）
- 目标设备对应的 toolchain 已编译或已下载预编译版本
- Rust 工具链（SDK 中需安装 `rust` 和 `cargo`，或通过 feed 安装）

## 编译步骤

### 1. 添加 feed

在 OpenWrt SDK 根目录下，将本仓库添加为自定义 feed：

```bash
# 编辑 feeds.conf.default，追加一行（根据实际路径调整）
echo 'src-git tsubamegaeshi https://github.com/hrimfaxi/openwrt-tsubamegaeshi-rs.git' >> feeds.conf.default

# 更新并安装 feed
./scripts/feeds update tsubamegaeshi
./scripts/feeds install tsubamegaeshi-rs
```

如果使用本地仓库：

```bash
echo "src-link tsubamegaeshi /path/to/openwrt-tsubamegaeshi-rs" >> feeds.conf.default
./scripts/feeds update tsubamegaeshi
./scripts/feeds install tsubamegaeshi-rs
```

### 2. 选择包

```bash
make menuconfig
```

进入 `Network` -> 勾选 `tsubamegaeshi-rs` 为 `M`（模块）或 `*`（内置）。

### 3. 编译

```bash
# 仅编译本包
make package/tsubamegaeshi-rs/compile V=s

# 或编译整个固件（会一并打包）
make -j$(nproc) V=s
```

编译产物位于 `bin/targets/<target>/<subtarget>/` 或 `build_dir/` 下。

## 支持的架构

Makefile 自动识别目标架构并选择对应的 Rust target triple：

| OpenWrt ARCH | Rust Target |
|---|---|
| aarch64 | `aarch64-unknown-linux-musl` |
| x86_64 | `x86_64-unknown-linux-musl` |
| mips | `mips-unknown-linux-musl` |
| mipsel | `mipsel-unknown-linux-musl` |
| arm (v7) | `armv7-unknown-linux-musleabihf` |
| arm | `arm-unknown-linux-musleabi` |

其他架构会回退到 `<arch>-unknown-linux-musl`。

## 安装到设备

编译完成后，将生成的 `.ipk` 文件传到 OpenWrt 设备上安装：

```bash
scp bin/packages/*/tsubamegaeshi/*.ipk root@<router>:/tmp/
ssh root@<router> "opkg install /tmp/tsubamegaeshi-rs_*.ipk"
```

## 包含的文件

安装后会在设备上部署：

- `/usr/bin/tsubamegaeshi-rs` — 主程序
- `/etc/tsubamegaeshi-rs/` — 配置文件目录
- `/etc/config/tsubamegaeshi-rs` — UCI 配置
- `/etc/init.d/tsubamegaeshi-rs` — init 启动脚本
- `/etc/capabilities/tsubamegaeshi-rs.json` — 权限声明
- `/usr/libexec/update_tsubamegaeshi_files.sh` — 辅助更新脚本
- `/etc/uci-defaults/tsubamegaeshi-rs` — 首次启动初始化脚本

## 许可证

GPL-3.0
