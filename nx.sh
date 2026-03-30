#!/usr/bin/env bash
set -euo pipefail

APP_NAME="Nginx-X"
APP_VERSION="0.1.0"

info()  { echo -e "[INFO] $*"; }
warn()  { echo -e "[WARN] $*"; }
error() { echo -e "[ERROR] $*"; }

pause() {
  echo
  read -rp "Press Enter to continue..." _
}

banner() {
  clear
  cat <<'BANNER'
 _   _       _             __   __
| \ | | __ _(_)_ __  __  __\ \ / /
|  \| |/ _` | | '_ \ \ \/ / \ V / 
| |\  | (_| | | | | | >  <   | |  
|_| \_|\__, |_|_| |_|/_/\_\  |_|  
       |___/                       
BANNER
  echo "${APP_NAME} v${APP_VERSION}"
  echo "----------------------------------------"
}

show_menu() {
  cat <<'MENU'
[1] Install Nginx
[2] Uninstall Nginx
[3] Start Nginx
[4] Stop Nginx
[5] Restart Nginx
[6] Reload Nginx
[7] Nginx Status
[8] Check Nginx Config (nginx -t)
[9] Placeholder: Site/VHost Management
[10] Placeholder: SSL/TLS Management
[11] Placeholder: Log Analysis
[0] Exit
MENU
}

has_nginx() {
  command -v nginx >/dev/null 2>&1
}

detect_pkg_mgr() {
  if command -v apt-get >/dev/null 2>&1; then
    echo "apt"
  elif command -v dnf >/dev/null 2>&1; then
    echo "dnf"
  elif command -v yum >/dev/null 2>&1; then
    echo "yum"
  elif command -v pacman >/dev/null 2>&1; then
    echo "pacman"
  else
    echo "unknown"
  fi
}

install_nginx() {
  local pkg_mgr
  pkg_mgr="$(detect_pkg_mgr)"

  if has_nginx; then
    warn "Nginx is already installed."
    return
  fi

  case "$pkg_mgr" in
    apt)
      sudo apt-get update
      sudo apt-get install -y nginx
      ;;
    dnf)
      sudo dnf install -y nginx
      ;;
    yum)
      sudo yum install -y nginx
      ;;
    pacman)
      sudo pacman -Sy --noconfirm nginx
      ;;
    *)
      error "Unsupported package manager. Please install Nginx manually."
      return 1
      ;;
  esac

  info "Nginx installed successfully."
}

uninstall_nginx() {
  local pkg_mgr
  pkg_mgr="$(detect_pkg_mgr)"

  if ! has_nginx; then
    warn "Nginx is not installed."
    return
  fi

  read -rp "Are you sure to uninstall Nginx? [y/N]: " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    info "Cancelled."
    return
  fi

  case "$pkg_mgr" in
    apt)
      sudo apt-get purge -y nginx nginx-common || true
      sudo apt-get autoremove -y || true
      ;;
    dnf)
      sudo dnf remove -y nginx
      ;;
    yum)
      sudo yum remove -y nginx
      ;;
    pacman)
      sudo pacman -Rns --noconfirm nginx
      ;;
    *)
      error "Unsupported package manager. Please uninstall Nginx manually."
      return 1
      ;;
  esac

  info "Nginx removed."
}

service_action() {
  local action="$1"

  if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl "$action" nginx
  else
    sudo service nginx "$action"
  fi
}

nginx_status() {
  if command -v systemctl >/dev/null 2>&1; then
    systemctl status nginx --no-pager || true
  else
    service nginx status || true
  fi
}

check_config() {
  sudo nginx -t
}

placeholder() {
  warn "This module is not implemented yet."
  info "We'll build detailed features in the next step."
}

main_loop() {
  while true; do
    banner
    show_menu
    echo
    read -rp "Choose an option: " choice

    case "$choice" in
      1) install_nginx; pause ;;
      2) uninstall_nginx; pause ;;
      3) service_action start; pause ;;
      4) service_action stop; pause ;;
      5) service_action restart; pause ;;
      6) service_action reload; pause ;;
      7) nginx_status; pause ;;
      8) check_config; pause ;;
      9|10|11) placeholder; pause ;;
      0)
        info "Bye."
        exit 0
        ;;
      *)
        warn "Invalid option."
        pause
        ;;
    esac
  done
}

main_loop
