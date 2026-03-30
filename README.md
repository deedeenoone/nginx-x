# Nginx-X

一个多功能、交互式的 Nginx 管理脚本。

## 当前功能（初始骨架）

- 数字菜单交互界面
- 安装 / 卸载 Nginx
- 启动 / 停止 / 重启 / 重载 Nginx 服务
- 查看 Nginx 运行状态
- 检测 Nginx 配置（`nginx -t`）
- 预留扩展模块：
  - 站点 / VHost 管理
  - SSL / TLS 管理
  - 日志分析

## 快速开始

```bash
git clone https://github.com/Xiuyixx/Nginx-X.git
cd Nginx-X
bash install.sh
```

安装完成后：

```bash
nx
```

## 说明

- 脚本涉及系统级操作，默认会使用 `sudo`。
- 当前版本支持的包管理器：`apt`、`dnf`、`yum`、`pacman`。

## 文档约定

- 本项目说明文档默认使用中文维护。
- 后续新增功能会持续以中文补充到本文档中。

---

下一步：我们可以按模块逐步实现详细功能。