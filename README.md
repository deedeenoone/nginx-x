# Nginx-X

An interactive Bash script for automated Nginx management on Ubuntu / Debian / CentOS.

## Goals

Manage Nginx through numbered menus with a focus on stability:
- All config changes run `nginx -t` before applying
- Only reloads after validation passes
- Auto rollback on failure to avoid taking down your service

## Installation

### One-liner (recommended)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/deedeenoone/nginx-x/main/install.sh)"
```

### Manual install

```bash
git clone https://github.com/deedeenoone/nginx-x.git
cd nginx-x
bash install.sh
```

Notes:
- First run clones to `/opt/Nginx-X`
- Subsequent runs pull latest automatically
- If `/opt/Nginx-X` exists but isn't a git repo, installer prompts for confirmation
- Network/software source errors are reported explicitly, not silently skipped

> **After install, run: `nx`**

## Features

### Stability design

- All config changes validated with `nginx -t`
- Auto rollback on validation failure
- 443/HTTPS port reuse handled safely
- HTTP-01 self-check before certificate issuance
- Temp files use secure random names

### 1. Install / Upgrade Nginx

- Auto-detect existing Nginx installation
- Install dependencies: `curl wget socat cron`
- Install official Nginx stable (uses nginx.org official source, HTTPS)
- Disable default.conf to avoid conflicts
- Create SSL directory: `/etc/nginx/ssl/`
- Compare local vs latest online version (falls back to package manager if nginx.org unreachable)
- Backup `/etc/nginx/` before upgrades
- Auto validate and reload after upgrade

### 2. Config Management

Sub-menu: `Add Config` / `External Proxy` / `Config List` / `Import Existing Config`

**Add Config:**
- Input domain or IPv4, listen port, backend port
- Port reuse detection
- Auto-generate standard proxy headers
- Config written to `/etc/nginx/conf.d/domain-port.conf`

**External Proxy:**
- Input domain or IPv4, listen port, upstream URL
- Mode options:
  - Standard mode
  - Stream mode
  - Emby HTTP stream separation
  - Emby HTTPS stream separation
  - LilyEmby方案三 (with sub_filter response replacement)
- Emby/Lily modes support: main upstream, stream node URL, public source URL, Referer URL
- Auto-adapt to multi-domain on same port

**Config List:**
- Enable / Disable / Modify / Edit / Delete configs
- Swap proxy mode while keeping HTTPS联动
- Auto issue certificate when domain changes

**Import Existing Config:**
- Auto-scan `conf.d/`, `sites-enabled/`, `sites-available/` directories
-逐个确认导入 unmanaged Nginx configs
- Auto-extract domain, port, backend address, HTTPS status metadata
- Does not modify existing Nginx directives
- `sites-available` configs are copied to `conf.d/`, symlinks in `sites-enabled/` are removed
- Disabled configs (`.bak`, etc.) are not re-imported (deduplicated by domain+port)
- Auto-detect and prompt to import existing configs after first Nginx install

**HTTPS enable:**
- If certificate exists: confirm to enable HTTPS
- If no certificate: auto issue + enable HTTPS (80→443)

### 3. Certificate Management

- Set email (persisted to `${XDG_CONFIG_HOME:-$HOME/.config}/nginxx/email.conf`)
- Auto install acme.sh, issue cert via HTTP-01
- HTTP-01 self-check before issuance (DNS/80 listener/challenge path/domain resolution)
- Cert list with renewal status
- Operations: reissue / toggle renewal / delete
- One-click HTTPS enable

### 4. Real-time Info

Sub-menu: `Live Status` / `Traffic Stats` / `Health Check`

**Live Status:**
- Connection status, request stats, QPS, system resources, Nginx info, network traffic

**Traffic Stats:**
- System total + per-config estimates
- Uses `/var/log/nginx/access.host.log` if available for precision
- Falls back to last 5000 lines of access.log

**Health Check:**
- Check all sites or single site
- Checks: URL, HTTP status, DNS resolution, IP hit
- HTTPS sites show certificate expiry days
- External proxies show main upstream + stream upstream
- Auto-refresh every 5 seconds

### 5. Uninstall

- Option 1: Uninstall script only
- Option 2: Uninstall Nginx + configs
- Option 3: Uninstall Acme.sh + email
- Option 4: Full uninstall (script + Nginx + Acme)
- High-risk ops show summary + require confirmation

## Known Limitations

- Certificate issuance only supports HTTP-01 (no DNS API for wildcard certs)
- HTTP-01 self-check may show "soft fail but actually works" behind CDN/NAT
- Traffic stats are estimates unless `/var/log/nginx/access.host.log` is configured
- No full E2E tests; basic syntax check, ShellCheck, and HTTPS config regression script

## Error Handling

- Menu entries missing prerequisites show reason and return to previous level (no abrupt `set -e` exits)
- Install/upgrade paths report explicit errors for: network issues, GitHub unreachable, software source errors, signing key download failures
- Certificate email saved to user config directory, not script install directory (avoids failure if `/usr/local/bin` is not writable)

## Recommended Host-specific Log Format

For accurate traffic stats, add to Nginx main config:

```nginx
log_format nginxx_host '$host $body_bytes_sent $remote_addr [$time_local] '
                      '"$request" $status $http_referer "$http_user_agent"';
access_log /var/log/nginx/access.host.log nginxx_host;
```

## Dev Validation

GitHub Actions CI:
```bash
bash -n nx.sh
bash -n install.sh
shellcheck -x nx.sh install.sh
bash tests/https_config_regression.sh
```

## UI Conventions

- Main menu uses numbered options
- `0` = exit / back
- Color feedback:
  - Green: success
  - Yellow: warning
  - Red: error
