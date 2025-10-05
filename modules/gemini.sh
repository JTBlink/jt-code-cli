#!/bin/bash

# =================================================================
# JT Code CLI - Google Gemini CLI 模块
# 作者: JTStudio Dev Team
# 描述: 提供 Google Gemini CLI 的安装、卸载、升级功能
# =================================================================

# 安装 Google Gemini CLI
install_gemini() {
    print_info "正在安装 Google Gemini CLI..."
    
    # 检查 Node.js
    if ! check_nodejs; then
        return 1
    fi
    
    # 检查是否已安装
    if command -v gemini >/dev/null 2>&1; then
        print_warning "Google Gemini CLI 已安装: $(gemini --version 2>/dev/null || echo 'unknown')"
        return 0
    fi
    
    # 安装 Google Gemini CLI
    execute_command "npm install -g @google/gemini-cli"
    
    if command -v gemini >/dev/null 2>&1; then
        print_success "Google Gemini CLI 安装成功: $(gemini --version)"
        print_info "请运行 'gemini config set apiKey YOUR_API_KEY' 设置 API 密钥"
        print_info "获取 API 密钥: https://aistudio.google.com/app/apikey"
    else
        print_error "Google Gemini CLI 安装失败"
        return 1
    fi
}

# 卸载 Google Gemini CLI
uninstall_gemini() {
    print_info "正在卸载 Google Gemini CLI..."
    
    if command -v gemini >/dev/null 2>&1; then
        execute_command "npm uninstall -g @google/gemini-cli"
        print_success "Google Gemini CLI 已卸载"
    else
        print_warning "Google Gemini CLI 未安装"
    fi
}

# 升级 Google Gemini CLI
upgrade_gemini() {
    print_info "正在升级 Google Gemini CLI..."
    
    # 检查 Node.js
    if ! check_nodejs; then
        return 1
    fi
    
    # 检查是否已安装
    if ! command -v gemini >/dev/null 2>&1; then
        print_warning "Google Gemini CLI 未安装，请先安装"
        return 1
    fi
    
    # 获取当前版本
    local current_version=$(gemini --version 2>/dev/null || echo "unknown")
    print_info "当前版本: $current_version"
    
    # 尝试升级 Google Gemini CLI
    print_info "正在尝试升级..."
    if execute_command "npm update -g @google/gemini-cli" "suppress"; then
        local new_version=$(gemini --version 2>/dev/null || echo "unknown")
        if [ "$current_version" != "$new_version" ]; then
            print_success "Google Gemini CLI 升级成功: $new_version"
        else
            print_success "Google Gemini CLI 已是最新版本"
        fi
        return 0
    fi
    
    print_warning "升级失败，尝试手动清理后重新安装..."
    
    # 强制重新安装
    print_info "正在卸载 Google Gemini CLI..."
    execute_command "npm uninstall -g @google/gemini-cli" "suppress"
    
    print_info "正在安装最新版本的 Google Gemini CLI..."
    if execute_command "npm install -g @google/gemini-cli"; then
        local new_version=$(gemini --version 2>/dev/null || echo "unknown")
        print_success "Google Gemini CLI 重新安装成功: $new_version"
    else
        print_error "Google Gemini CLI 重新安装失败"
        return 1
    fi
}