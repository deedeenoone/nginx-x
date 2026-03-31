#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Xiuyixx/Nginx-X.git"
INSTALL_DIR="/opt/Nginx-X"

SUDO=""
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  SUDO="sudo"
fi

echo "[INFO] 开始一键安装 Nginx-X..."

if ! command -v git >/dev/null 2>&1; then
  echo "[INFO] 未检测到 git，正在安装..."
  if command -v apt-get >/dev/null 2>&1; then
    ${SUDO} apt-get update
    ${SUDO} apt-get install -y git
  elif command -v dnf >/dev/null 2>&1; then
    ${SUDO} dnf install -y git
  elif command -v yum >/dev/null 2>&1; then
    ${SUDO} yum install -y git
  else
    echo "[ERROR] 无法自动安装 git，请手动安装后重试。"
    exit 1
  fi
fi

if [[ -d "$INSTALL_DIR/.git" ]]; then
  echo "[INFO] 检测到已安装目录，正在更新到最新版本..."
  ${SUDO} git -C "$INSTALL_DIR" pull --ff-only
else
  echo "[INFO] 克隆仓库到 $INSTALL_DIR"
  ${SUDO} rm -rf "$INSTALL_DIR"
  ${SUDO} git clone "$REPO_URL" "$INSTALL_DIR"
fi

${SUDO} bash "$INSTALL_DIR/install.sh"

echo "[OK] 安装完成，正在启动 Nginx-X..."
exec nx
