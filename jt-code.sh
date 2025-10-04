#!/bin/bash

# =================================================================
# JT Code CLI
# 作者: JTStudio Dev Team
# 描述: 统一管理 AI 开发工具的安装和卸载脚本
# =================================================================

set -e

# 脚本目录（处理软链接情况）
if [ -L "$0" ]; then
    # 如果是软链接，获取实际脚本位置
    SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
SCRIPT_NAME="$(basename "$0")"

# 导入模块
source "$SCRIPT_DIR/modules/core.sh"
source "$SCRIPT_DIR/modules/tools.sh"
source "$SCRIPT_DIR/modules/iflow.sh"
source "$SCRIPT_DIR/modules/claude-code.sh"
source "$SCRIPT_DIR/modules/qwen.sh"
source "$SCRIPT_DIR/modules/codebuddy.sh"

# 帮助信息
show_help() {
    echo "用法: $SCRIPT_NAME <command> [options]"
    echo ""
    echo "命令:"
    echo "  install <tool>    安装指定的 AI 工具"
    echo "  uninstall <tool>  卸载指定的 AI 工具"
    echo "  upgrade <tool>    升级指定的 AI 工具"
    echo "  list              列出所有可用的工具"
    echo "  status            检查已安装的工具状态"
    echo ""
    echo "可用的工具:"
    echo "  iflow             iFlow CLI 工具"
    echo "                    官方网站: https://platform.iflow.cn/"
    echo "  claude-code       Claude Code 工具"
    echo "                    官方网站: https://claude.ai"
    echo "  qwen              Qwen Code 工具"
    echo "                    官方网站: https://qwenlm.github.io/qwen-code-docs/"
    echo "  codebuddy         CodeBuddy 智能编程伴侣"
    echo "                    官方网站: https://www.codebuddy.ai/cli"
    echo "  all               所有工具"
    echo ""
    echo "选项:"
    echo "  -h, --help        显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  # 安装 GitHub Copilot CLI (参考官方文档)"
    echo "  npm install -g @github/copilot"
    echo "  $SCRIPT_NAME install iflow          # 安装 iFlow"
    echo "  $SCRIPT_NAME install claude-code    # 安装 Claude Code"
    echo "  $SCRIPT_NAME install qwen           # 安装 Qwen Code"
    echo "  $SCRIPT_NAME install codebuddy      # 安装 CodeBuddy"
    echo "  $SCRIPT_NAME install all            # 安装所有工具"
    echo "  $SCRIPT_NAME uninstall iflow        # 卸载 iFlow"
    echo "  $SCRIPT_NAME upgrade iflow          # 升级 iFlow"
    echo "  $SCRIPT_NAME upgrade all            # 升级所有工具"
    echo "  $SCRIPT_NAME status                 # 检查工具状态"
    echo ""
    echo "更多信息请访问: https://github.com/JTStudio/ai-dev-tools"
    echo "GitHub Copilot CLI 文档: https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli"
}

# 主函数
main() {
    if [ $# -eq 0 ]; then
        show_help
        exit 1
    fi
    
    case "$1" in
        install)
            case "$2" in
                iflow)
                    install_iflow
                    ;;
                claude-code)
                    install_claude_code
                    ;;
                qwen)
                    install_qwen
                    ;;
                codebuddy)
                    install_codebuddy
                    ;;
                all)
                    install_iflow
                    install_claude_code
                    install_qwen
                    install_codebuddy
                    ;;
                *)
                    print_error "未知的工具: $2"
                    echo ""
                    list_tools
                    exit 1
                    ;;
            esac
            ;;
        uninstall)
            case "$2" in
                iflow)
                    uninstall_iflow
                    ;;
                claude-code)
                    uninstall_claude_code
                    ;;
                qwen)
                    uninstall_qwen
                    ;;
                codebuddy)
                    uninstall_codebuddy
                    ;;
                all)
                    uninstall_iflow
                    uninstall_claude_code
                    uninstall_qwen
                    uninstall_codebuddy
                    ;;
                *)
                    print_error "未知的工具: $2"
                    echo ""
                    list_tools
                    exit 1
                    ;;
            esac
            ;;
        upgrade)
            case "$2" in
                iflow)
                    upgrade_iflow
                    ;;
                claude-code)
                    upgrade_claude_code
                    ;;
                qwen)
                    upgrade_qwen
                    ;;
                codebuddy)
                    upgrade_codebuddy
                    ;;
                all)
                    upgrade_iflow
                    upgrade_claude_code
                    upgrade_qwen
                    upgrade_codebuddy
                    ;;
                *)
                    print_error "未知的工具: $2"
                    echo ""
                    list_tools
                    exit 1
                    ;;
            esac
            ;;
        list)
            list_tools
            ;;
        status)
            check_tool_status
            ;;
        -h|--help|help)
            show_help
            ;;
        *)
            print_error "未知的命令: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"