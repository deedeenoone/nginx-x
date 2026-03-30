# Nginx-X

A multi-function interactive Nginx management script.

## Features (initial scaffold)

- Numeric menu-driven interface
- Install / uninstall Nginx
- Start / stop / restart / reload Nginx service
- Nginx status check
- Nginx config test (`nginx -t`)
- Placeholder modules for future expansion:
  - Site/VHost management
  - SSL/TLS management
  - Log analysis

## Quick Start

```bash
git clone https://github.com/Xiuyixx/Nginx-X.git
cd Nginx-X
bash install.sh
```

After installation:

```bash
nx
```

## Notes

- This script uses `sudo` for system-level operations.
- Supported package managers in this version: `apt`, `dnf`, `yum`, `pacman`.

---

Next steps: We can progressively implement each placeholder module in depth.
