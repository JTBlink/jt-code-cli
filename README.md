# JTCode CLI

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Node.js](https://img.shields.io/badge/node-%3E%3D18-brightgreen.svg)](https://nodejs.org/)
[![Bash](https://img.shields.io/badge/bash-5.0%2B-orange.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)](#)

> 一个基于 Bash 的 CLI 工具，用于通过 npm 全局包管理多个 AI 开发工具的安装、升级与卸载。

## 📚 目录

- [JTCode CLI](#jtcode-cli)
  - [📚 目录](#-目录)
  - [🚀 项目概述](#-项目概述)
  - [✨ 核心功能](#-核心功能)
  - [⚙️ 先决条件](#️-先决条件)
  - [🏁 快速开始](#-快速开始)
    - [1. 安装 CLI](#1-安装-cli)
    - [2. 管理 AI 工具](#2-管理-ai-工具)
    - [3. MCP 服务器管理](#3-mcp-服务器管理)
  - [📁 项目结构](#-项目结构)
  - [💻 本地使用](#-本地使用)
  - [⚠️ 注意事项](#️-注意事项)
  - [🛠️ 支持的工具](#️-支持的工具)
  - [🤝 贡献指南](#-贡献指南)
    - [贡献步骤](#贡献步骤)
    - [代码规范](#代码规范)
    - [问题报告](#问题报告)
  - [📝 许可证](#-许可证)
  - [📫 联系方式](#-联系方式)

## 🚀 项目概述

`jt-code-cli` 是一个统一的 AI 开发工具管理器，帮助开发者轻松管理以下 AI 开发工具：

- **iFlow CLI** - @iflow-ai/iflow-cli
- **Claude Code** - @anthropic-ai/claude-code
- **Qwen Code** - @qwen-code/qwen-code
- **CodeBuddy** - @tencent-ai/codebuddy-code
- **GitHub Copilot** - @github/copilot
- **Gemini CLI** - @google/gemini-cli
- **OpenCode** - opencode-ai

## ✨ 核心功能

- 🚀 **统一管理**: 一键安装、升级、卸载多个 AI 开发工具
- 📦 **npm 集成**: 基于 npm 全局包管理，确保工具版本同步
- 🔧 **环境检测**: 自动检查 Node.js 和 npm 环境
- 🛠️ **MCP 支持**: 独立的 MCP (Model Context Protocol) 服务器诊断与管理工具
- ⚡ **软链接安装**: 支持在 `~/.local/bin` 创建便捷的软链接

## ⚙️ 先决条件

- **Node.js** >= 18.x （推荐）
- **npm** 包管理器
- **jq**, **pgrep**, **pkill** （仅 MCP 管理器需要）

## 🏁 快速开始

### 1. 安装 CLI

```bash
# 安装所有受管脚本到 ~/.local/bin
./jt-code-setup.sh install

# 确保 ~/.local/bin 在 PATH 中 (macOS/zsh)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# 验证安装
which jt-code
```

### 2. 管理 AI 工具

```bash
# 查看可用工具和状态
jt-code list
jt-code status

# 安装单个工具
jt-code install claude-code
jt-code install iflow

# 安装所有工具
jt-code install all

# 升级工具
jt-code upgrade claude-code
jt-code upgrade all

# 卸载工具
jt-code uninstall qwen
jt-code uninstall all
```

### 3. MCP 服务器管理

```bash
# 检查 MCP 服务器状态
./mcp-manager.sh status

# 清理残留进程
./mcp-manager.sh cleanup

# 验证配置文件
./mcp-manager.sh validate

# 完整重置
./mcp-manager.sh full-reset
```

## 📁 项目结构

```
jt-code-cli/
├── jt-code.sh              # 主要 CLI 入口
├── jt-code-setup.sh        # 软链接管理器
├── mcp-manager.sh          # MCP 服务器管理工具
└── modules/
    ├── core.sh             # 核心功能和日志
    ├── tools.sh            # 环境检查和工具状态
    ├── iflow.sh            # iFlow CLI 管理
    ├── claude-code.sh      # Claude Code 管理
    ├── qwen.sh             # Qwen Code 管理
    ├── codebuddy.sh        # CodeBuddy 管理
    ├── copilot.sh          # GitHub Copilot 管理
    └── gemini.sh           # Gemini CLI 管理
```

## 💻 本地使用

如果不想安装软链接，可以直接运行脚本：

```bash
# 直接使用主脚本
./jt-code.sh status
./jt-code.sh install claude-code

# 使用 MCP 管理器
./mcp-manager.sh diagnose
```

## ⚠️ 注意事项

- ⚠️ **非交互式**: 某些卸载操作可能需要手动确认，请注意自动化场景
- 🌐 **网络要求**: 需要访问 npm registry 的 HTTPS 网络连接
- 🔍 **环境检查**: 脚本会自动检查 Node.js 版本，< 18 时给出警告

## 🛠️ 支持的工具

| 工具 | npm 包 | 功能描述 |
|------|--------|----------|
| iFlow | @iflow-ai/iflow-cli | AI 工作流自动化 |
| Claude Code | @anthropic-ai/claude-code | Anthropic Claude 代码助手 |
| Qwen Code | @qwen-code/qwen-code | 阿里云通义千问代码助手 |
| CodeBuddy | @tencent-ai/codebuddy-code | 腾讯 AI 代码助手 |
| GitHub Copilot | @github/copilot | GitHub AI 编程助手 |
| Gemini CLI | @google/gemini-cli | Google Gemini AI 命令行工具 |
| OpenCode | opencode-ai | 开源 AI 编程代理 |

## 🤝 贡献指南

欢迎贡献代码、报告问题或提出改进建议！

### 贡献步骤

1. **Fork 本仓库**
2. **创建特性分支**: `git checkout -b feature/your-feature-name`
3. **提交更改**: `git commit -am 'Add some feature'`
4. **推送分支**: `git push origin feature/your-feature-name`
5. **提交 Pull Request**

### 代码规范

- 使用一致的缩进和格式
- 遵循 Bash 最佳实践
- 添加适当的注释和文档
- 使用 `shellcheck` 检查脚本质量

### 问题报告

如果发现问题，请在 [Issues](../../issues) 页面创建问题报告，并包含以下信息：

- 操作系统版本
- Node.js 和 npm 版本
- 错误消息或日志
- 重现步骤

## 📝 许可证

本项目采用 [MIT 许可证](LICENSE)。

## 📫 联系方式

如有任何问题或建议，欢迎联系：

- **邮箱**: [jtblink9@gmail.com](mailto:jtblink9@gmail.com)
- **GitHub Issues**: [提交问题](../../issues)
- **GitHub Discussions**: [参与讨论](../../discussions)

---

<div align="center">
  <p>如果这个项目对你有帮助，请给个 ⭐ Star 支持一下！</p>
  <p>Made with ❤️ by <a href="mailto:jtblink9@gmail.com">JT Studio</a></p>
</div>
