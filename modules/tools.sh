#!/bin/bash

# =================================================================
# JT Code CLI - 工具管理模块
# 作者: JTStudio Dev Team
# 描述: 提供工具检查、状态检查等通用工具管理功能
# =================================================================

# 检查 Node.js 是否已安装
check_nodejs() {
    if ! command -v node >/dev/null 2>&1; then
        print_error "Node.js 未安装，请先安装 Node.js"
        return 1
    fi
    
    local current_version=$(node -v | sed 's/v//')
    local major_version=$(echo $current_version | cut -d. -f1)
    
    if [ "$major_version" -lt 18 ]; then
        print_warning "Node.js 版本 ($current_version) 较低，建议升级到 v18 或更高版本"
    else
        print_success "Node.js v$current_version 已安装"
    fi
    return 0
}

# 检查工具状态
check_tool_status() {
    print_info "检查 AI 工具状态..."
    echo ""
    
    # 检查 Node.js
    if command -v node >/dev/null 2>&1; then
        local node_version=$(node -v)
        print_success "Node.js: $node_version"
    else
        print_error "Node.js: 未安装"
    fi
    
    # 检查 npm
    if command -v npm >/dev/null 2>&1; then
        local npm_version=$(npm -v)
        print_success "npm: v$npm_version"
    else
        print_error "npm: 未安装"
    fi
    
    echo ""
    
    # 检查 iFlow
    if command -v iflow >/dev/null 2>&1; then
        local iflow_version=$(iflow --version 2>/dev/null || echo "unknown")
        print_success "iFlow CLI: $iflow_version"
    else
        print_warning "iFlow CLI: 未安装"
    fi
    
    # 检查 Claude Code
    if command -v claude >/dev/null 2>&1; then
        local claude_version=$(claude --version 2>/dev/null || echo "unknown")
        print_success "Claude Code: $claude_version"
    else
        print_warning "Claude Code: 未安装"
    fi
    
    # 检查 Qwen Code
    if command -v qwen >/dev/null 2>&1; then
        local qwen_version=$(qwen --version 2>/dev/null || echo "unknown")
        print_success "Qwen Code: $qwen_version"
    else
        print_warning "Qwen Code: 未安装"
    fi
    
    # 检查 CodeBuddy
    if command -v cbc >/dev/null 2>&1 || command -v codebuddy >/dev/null 2>&1; then
        local version_cmd="cbc"
        if ! command -v cbc >/dev/null 2>&1; then
            version_cmd="codebuddy"
        fi
        local codebuddy_version=$($version_cmd --version 2>/dev/null || echo "unknown")
        print_success "CodeBuddy: $codebuddy_version"
    else
        print_warning "CodeBuddy: 未安装"
    fi
    
    # 检查 GitHub Copilot CLI
    if command -v copilot >/dev/null 2>&1; then
        local copilot_version=$(copilot --version 2>/dev/null || echo "unknown")
        print_success "GitHub Copilot CLI: $copilot_version"
    else
        print_warning "GitHub Copilot CLI: 未安装"
    fi
    
    # 检查 Google Gemini CLI
    if command -v gemini >/dev/null 2>&1; then
        local gemini_version=$(gemini --version 2>/dev/null || echo "unknown")
        print_success "Google Gemini CLI: $gemini_version"
    else
        print_warning "Google Gemini CLI: 未安装"
    fi
}

# 列出可用工具
list_tools() {
    echo "可用的 AI 开发工具:"
    echo ""
    echo "  iflow        - iFlow CLI: 智能代码助手和自动化工具"
    echo "               官方网站: https://iflow.ai"
    echo "  claude-code  - Claude Code: Anthropic 的 Claude 代码助手"
    echo "               官方网站: https://claude.ai"
    echo "  qwen         - Qwen Code: 阿里云通义千问代码助手"
    echo "               官方网站: https://qwenlm.github.io/qwen-code-docs/"
    echo "  codebuddy    - CodeBuddy: 智能编程伴侣 (命令: cbc 或 codebuddy)"
    echo "               官方网站: https://www.codebuddy.ai/cli"
    echo "  copilot      - GitHub Copilot CLI: GitHub AI 代码助手 (命令: copilot)"
    echo "               官方网站: https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli"
    echo "  gemini       - Google Gemini CLI: Google AI 代码助手 (命令: gemini)"
    echo "               官方网站: https://github.com/google-gemini/gemini-cli"
    echo ""
    echo "使用 '$0 install <tool>' 安装工具"
    echo "使用 '$0 uninstall <tool>' 卸载工具"
    echo "更多信息请访问: https://github.com/JTStudio/ai-dev-tools"
}