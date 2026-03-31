#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Xiuyixx/Nginx-X.git"
INSTALL_DIR="/opt/Nginx-X"
TARGET_BIN="/usr/local/bin/nx"

SUDO=""
if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  SUDO="sudo"
fi

install_git_if_needed() {
  if command -v git >/dev/null 2>&1; then
    return 0
  fi

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
}

install_local() {
  local script_dir source_script
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source_script="${script_dir}/nx.sh"

  if [[ ! -f "$source_script" ]]; then
    echo "[ERROR] nx.sh not found in ${script_dir}"
    exit 1
  fi

  chmod +x "$source_script"

  if [[ $EUID -ne 0 ]]; then
    echo "[INFO] Need sudo to install launcher to ${TARGET_BIN}"
    sudo install -m 0755 "$source_script" "$TARGET_BIN"
  else
    install -m 0755 "$source_script" "$TARGET_BIN"
  fi

  echo "[OK] Installed. You can now run: nx"

  # 如果当前在交互终端，安装后直接进入菜单，免去手动再输入 nx
  if [[ -t 0 && -t 1 ]]; then
    read -rp "是否立即启动 Nginx-X？[Y/n]: " run_now
    if [[ -z "$run_now" || "$run_now" =~ ^[Yy]$ ]]; then
      exec "$TARGET_BIN"
    fi
  fi
}

bootstrap_install() {
  echo "[INFO] 开始一键安装 Nginx-X..."

  install_git_if_needed

  if [[ -d "$INSTALL_DIR/.git" ]]; then
    echo "[INFO] 检测到已安装目录，正在更新到最新版本..."
    ${SUDO} git -C "$INSTALL_DIR" pull --ff-only
  else
    echo "[INFO] 克隆仓库到 $INSTALL_DIR"
    ${SUDO} rm -rf "$INSTALL_DIR"
    ${SUDO} git clone "$REPO_URL" "$INSTALL_DIR"
  fi

  # 进入安装目录执行同一个 install.sh（此时会走本地安装逻辑）
  ${SUDO} bash "$INSTALL_DIR/install.sh"

  echo "[OK] 安装完成，正在启动 Nginx-X..."
  exec nx
}

# 统一入口：
# - 在仓库目录执行（存在 nx.sh）=> 本地安装
# - 通过 curl 一键执行（通常无 nx.sh）=> 引导克隆后安装
if [[ -f "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/nx.sh" ]]; then
  install_local
else
  bootstrap_install
fi
