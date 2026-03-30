#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_BIN="/usr/local/bin/nx"
SOURCE_SCRIPT="${SCRIPT_DIR}/nx.sh"

if [[ ! -f "$SOURCE_SCRIPT" ]]; then
  echo "[ERROR] nx.sh not found in ${SCRIPT_DIR}"
  exit 1
fi

chmod +x "$SOURCE_SCRIPT"

if [[ $EUID -ne 0 ]]; then
  echo "[INFO] Need sudo to install launcher to ${TARGET_BIN}"
  sudo install -m 0755 "$SOURCE_SCRIPT" "$TARGET_BIN"
else
  install -m 0755 "$SOURCE_SCRIPT" "$TARGET_BIN"
fi

echo "[OK] Installed. You can now run: nx"
