# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

项目概览
- 本仓库是一个基于 Bash 的 CLI，用于通过 npm 全局包管理多个 AI 开发工具的安装、升级与卸载。本仓库不包含编译构建或单元测试框架。
- 主要入口：jt-code.sh（可直接调用，或通过 jt-code-setup.sh 在 ~/.local/bin 安装名为 jt-code 的软链接来调用）。
- 独立工具脚本：mcp-manager.sh，用于诊断与清理 Model Context Protocol (MCP) 相关进程，并校验 MCP 配置文件。

先决条件
- Node.js 与 npm：推荐 Node >= 18（modules/tools.sh 会进行校验并给出提示）。
- 仅 mcp-manager.sh 需要：jq、pgrep、pkill 需存在于 PATH 中；缺失时脚本会报错并给出安装指引。

常用命令
1) 安装 jt-code CLI（在 ~/.local/bin 创建 jt-code 软链接）
- 安装所有受管脚本（当前仅 jt-code）：
  ./jt-code-setup.sh install
- 安装/卸载单个脚本（名称可为 jt-code 或 jt-code.sh）：
  ./jt-code-setup.sh install jt-code
  ./jt-code-setup.sh uninstall jt-code
- 查看软链接状态与受管脚本列表：
  ./jt-code-setup.sh status
  ./jt-code-setup.sh list

注意
- 在 macOS/zsh 环境，请确保 ~/.local/bin 已加入 PATH（以便系统找到 jt-code）：
  如有需要，在 ~/.zshrc 中加入：export PATH="$HOME/.local/bin:$PATH"
- 验证安装：which jt-code

2) 使用 jt-code 管理工具
- 列出可用工具并查看状态：
  jt-code list
  jt-code status
- 安装单个工具：
  jt-code install iflow
  jt-code install claude-code
  jt-code install qwen
  jt-code install codebuddy
  jt-code install copilot
  jt-code install gemini
- 安装全部支持的工具：
  jt-code install all
- 升级单个或全部工具：
  jt-code upgrade claude-code
  jt-code upgrade all
- 卸载单个或全部工具：
  jt-code uninstall qwen
  jt-code uninstall all

3) 不安装软链接直接本地运行
- 可直接调用 CLI 入口脚本：
  ./jt-code.sh status
  ./jt-code.sh install claude-code

4) MCP 服务器诊断与清理（独立工具）
- 检查、清理、校验配置并重启相关进程：
  ./mcp-manager.sh status
  ./mcp-manager.sh cleanup
  ./mcp-manager.sh validate
  ./mcp-manager.sh restart
  ./mcp-manager.sh diagnose
  ./mcp-manager.sh full-reset

重要行为与注意事项
- 非交互式使用：避免出现交互式提示。例如 uninstall_codebuddy 可能会询问是否删除配置，这会在自动化场景下造成阻塞。建议选择非交互路径或手动处理清理。
- 网络访问：安装脚本依赖 npm，需要能访问 npm registry 的 HTTPS 网络。

高层架构
- CLI 入口：jt-code.sh
  - 解析自身真实路径（支持以软链接方式调用），设置 SCRIPT_DIR，随后加载以下模块：
    modules/core.sh   — 彩色日志与 execute_command 封装
    modules/tools.sh  — 环境检查、工具列表与状态汇总
    modules/iflow.sh  — 安装/卸载/升级 @iflow-ai/iflow-cli
    modules/claude-code.sh — 安装/卸载/升级 @anthropic-ai/claude-code，并写入 ~/.claude.json 的 onboarding 标记
    modules/qwen.sh   — 安装/卸载/升级 @qwen-code/qwen-code
    modules/codebuddy.sh — 安装/卸载/升级 @tencent-ai/codebuddy-code
    modules/copilot.sh — 安装/卸载/升级 @github/copilot
    modules/gemini.sh — 安装/卸载/升级 @google/gemini-cli
  - 分发子命令：install、uninstall、upgrade、list、status、help。
  - 对于 all 的 install/uninstall/upgrade，会依次调用各工具对应函数。

- 软链接管理：jt-code-setup.sh
  - 维护 ~/.local/bin 下名为 jt-code 的软链接，指向仓库内的 jt-code.sh。
  - 命令：install [<script>]、uninstall [<script>]、status、list、help。
  - 安全行为：备份有冲突且非软链接的同名可执行文件，修复指向错误的软链接，对源脚本执行 chmod +x。

- 核心工具：modules/core.sh
  - 提供 print_info/print_success/print_warning/print_error 彩色输出助手。
  - execute_command "<cmd>" ["suppress"] 支持可选的静默输出执行。

- 工具辅助：modules/tools.sh
  - check_nodejs：确保 Node 存在；Node 版本 < 18 给出警告。
  - check_tool_status：若命令存在则打印版本（node、npm、iflow、claude、qwen、cbc/codebuddy、copilot、gemini）。
  - list_tools：输出受支持工具与使用说明。

- 工具模块（基于 npm 的安装器）
  - modules/iflow.sh：npm install -g @iflow-ai/iflow-cli
  - modules/claude-code.sh：npm install -g @anthropic-ai/claude-code，并写入 ~/.claude.json 的 hasCompletedOnboarding 标记
  - modules/qwen.sh：npm install -g @qwen-code/qwen-code
  - modules/codebuddy.sh：npm install -g @tencent-ai/codebuddy-code
  - modules/copilot.sh：npm install -g @github/copilot
  - modules/gemini.sh：npm install -g @google/gemini-cli
  - 每个模块均提供 install_<tool>、uninstall_<tool>、upgrade_<tool>；升级优先尝试 npm update -g，失败则回退为卸载后重装。

- MCP 工具：mcp-manager.sh
  - 提供 status、cleanup、restart、validate、diagnose、full-reset，用于 MCP 相关进程与配置。
  - validate：优先查找 ~/.claude.json；找不到则回退到 VSCode 扩展目录；使用 jq 校验 JSON 并列出服务器与文件系统参数。
  - cleanup：通过 pgrep/kill 清理重复或残留的 MCP 进程（filesystem、context7、browser-tools、git、sequential-thinking、figma developer），包含安全检查与重试。
  - diagnose：打印环境与连通性检查（npm registry 可达性、node/npm/npx/python/jq 的存在与版本）。

构建、测试、规范检查
- 构建：不适用（纯 Bash 脚本）。
- 测试：本仓库未包含测试。
- 规范检查（可选）：开发时可使用 shellcheck 进行脚本静态检查，例如：
  shellcheck jt-code.sh jt-code-setup.sh mcp-manager.sh modules/*.sh

参考
- 存在一个最小化的 README.md，内容为“jt code 工具集合”。
- 当前未发现 CLAUDE.md、Cursor 规则或 Copilot 指南。
