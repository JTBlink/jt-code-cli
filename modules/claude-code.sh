#!/bin/bash

# =================================================================
# JT Code CLI - Claude Code 模块
# 作者: JTStudio Dev Team
# 描述: 提供 Claude Code 的安装、卸载、升级功能
# =================================================================

# 安装 Claude Code
install_claude_code() {
    print_info "正在安装 Claude Code..."
    
    # 检查 Node.js
    if ! check_nodejs; then
        return 1
    fi
    
    # 检查是否已安装
    if command -v claude >/dev/null 2>&1; then
        print_warning "Claude Code 已安装: $(claude --version 2>/dev/null || echo 'unknown')"
        return 0
    fi
    
    # 安装 Claude Code
    execute_command "npm install -g @anthropic-ai/claude-code"
    
    if command -v claude >/dev/null 2>&1; then
        print_success "Claude Code 安装成功: $(claude --version)"
        
        # 配置 Claude Code
        print_info "正在配置 Claude Code..."
        local config_command="node --eval 'const os = require(\"os\"); const fs = require(\"fs\"); const path = require(\"path\"); const homeDir = os.homedir(); const filePath = path.join(homeDir, \".claude.json\"); if (fs.existsSync(filePath)) { const content = JSON.parse(fs.readFileSync(filePath, \"utf-8\")); fs.writeFileSync(filePath, JSON.stringify({ ...content, hasCompletedOnboarding: true }, null, 2), \"utf-8\"); } else { fs.writeFileSync(filePath, JSON.stringify({ hasCompletedOnboarding: true }, null, 2), \"utf-8\"); }'"
        execute_command "$config_command"
        
        print_success "Claude Code 配置完成"
        print_info "请运行 'claude' 命令进行初始配置"
    else
        print_error "Claude Code 安装失败"
        return 1
    fi
}

# 卸载 Claude Code
uninstall_claude_code() {
    print_info "正在卸载 Claude Code..."
    
    if command -v claude >/dev/null 2>&1; then
        execute_command "npm uninstall -g @anthropic-ai/claude-code"
        print_success "Claude Code 已卸载"
        
        # 清理配置文件
        local claude_config="$HOME/.claude.json"
        if [ -f "$claude_config" ]; then
            execute_command "rm -f $claude_config"
            print_success "已清理 Claude Code 配置文件"
        fi
    else
        print_warning "Claude Code 未安装"
    fi
}

# 升级 Claude Code
upgrade_claude_code() {
    print_info "正在升级 Claude Code..."

    # 检查 Node.js
    if ! check_nodejs; then
        return 1
    fi

    # 检查是否已安装
    if ! command -v claude >/dev/null 2>&1; then
        print_warning "Claude Code 未安装，请先安装"
        return 1
    fi

    # 获取当前版本
    local current_version=$(claude --version 2>/dev/null || echo "unknown")
    print_info "当前版本: $current_version"

    # 尝试 upgrade Claude Code
    print_info "正在尝试升级..."
    if execute_command "npm update -g @anthropic-ai/claude-code" "suppress"; then
        local new_version=$(claude --version 2>/dev/null || echo "unknown")
        if [ "$current_version" != "$new_version" ]; then
            print_success "Claude Code 升级成功: $new_version"
        else
            print_success "Claude Code 已是最新版本"
        fi
        return 0
    fi

    # If npm update fails, try reinstalling
    print_info "npm update 失败，尝试重新安装..."
    if execute_command "npm install -g @anthropic-ai/claude-code"; then
        local new_version=$(claude --version 2>/dev/null || echo "unknown")
        print_success "Claude Code 重新安装成功: $new_version"
        return 0
    else
        print_error "Claude Code 重新安装失败"
        return 1
    fi
}