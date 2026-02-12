#!/bin/bash

# =================================================================
# JT Code CLI - GitHub Copilot CLI 模块
# 作者: JTStudio Dev Team
# 描述: 提供 GitHub Copilot CLI 的安装、卸载、升级功能
# =================================================================

# 安装 GitHub Copilot CLI
install_copilot() {
    print_info "正在安装 GitHub Copilot CLI..."
    
    # 检查 Node.js
    if ! check_nodejs; then
        return 1
    fi
    
    # 检查是否已安装
    if command -v copilot >/dev/null 2>&1; then
        print_warning "GitHub Copilot CLI 已安装: $(copilot --version 2>/dev/null || echo 'unknown')"
        return 0
    fi
    
    # 安装 GitHub Copilot CLI
    execute_command "npm install -g @github/copilot"
    
    if command -v copilot >/dev/null 2>&1; then
        print_success "GitHub Copilot CLI 安装成功: $(copilot --version)"
        print_info "请运行 'copilot auth login' 进行身份验证"
    else
        print_error "GitHub Copilot CLI 安装失败"
        return 1
    fi
}

# 卸载 GitHub Copilot CLI
uninstall_copilot() {
    print_info "正在卸载 GitHub Copilot CLI..."
    
    if command -v copilot >/dev/null 2>&1; then
        execute_command "npm uninstall -g @github/copilot"
        print_success "GitHub Copilot CLI 已卸载"
    else
        print_warning "GitHub Copilot CLI 未安装"
    fi
}

# 升级 GitHub Copilot CLI
upgrade_copilot() {
    print_info "正在升级 GitHub Copilot CLI..."

    # 检查 Node.js
    if ! check_nodejs; then
        return 1
    fi

    # 检查是否已安装
    if ! command -v copilot >/dev/null 2>&1; then
        print_warning "GitHub Copilot CLI 未安装，请先安装"
        return 1
    fi

    # 获取当前版本
    local current_version=$(copilot --version 2>/dev/null || echo "unknown")
    print_info "当前版本: $current_version"

    # 尝试 upgrade GitHub Copilot CLI
    print_info "正在尝试升级..."
    if execute_command "npm update -g @github/copilot" "suppress"; then
        local new_version=$(copilot --version 2>/dev/null || echo "unknown")
        if [ "$current_version" != "$new_version" ]; then
            print_success "GitHub Copilot CLI 升级成功: $new_version"
        else
            print_success "GitHub Copilot CLI 已是最新版本"
        fi
        return 0
    fi

    # If npm update fails, try reinstalling
    print_info "npm update 失败，尝试重新安装..."
    if execute_command "npm install -g @github/copilot"; then
        local new_version=$(copilot --version 2>/dev/null || echo "unknown")
        print_success "GitHub Copilot CLI 重新安装成功: $new_version"
        return 0
    else
        print_error "GitHub Copilot CLI 重新安装失败"
        return 1
    fi
}