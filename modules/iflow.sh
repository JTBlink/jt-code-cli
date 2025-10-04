#!/bin/bash

# =================================================================
# JT Code CLI - iFlow CLI 模块
# 作者: JTStudio Dev Team
# 描述: 提供 iFlow CLI 的安装、卸载、升级功能
# =================================================================

# 安装 iFlow CLI
install_iflow() {
    print_info "正在安装 iFlow CLI..."
    
    # 检查 Node.js
    if ! check_nodejs; then
        return 1
    fi
    
    # 检查是否已安装
    if command -v iflow >/dev/null 2>&1; then
        print_warning "iFlow 已安装: $(iflow --version 2>/dev/null || echo 'unknown')"
        return 0
    fi
    
    # 安装 iFlow
    execute_command "npm install -g @iflow-ai/iflow-cli"
    
    if command -v iflow >/dev/null 2>&1; then
        print_success "iFlow CLI 安装成功: $(iflow --version)"
    else
        print_error "iFlow CLI 安装失败"
        return 1
    fi
}

# 卸载 iFlow CLI
uninstall_iflow() {
    print_info "正在卸载 iFlow CLI..."
    
    if command -v iflow >/dev/null 2>&1; then
        execute_command "npm uninstall -g @iflow-ai/iflow-cli"
        print_success "iFlow CLI 已卸载"
    else
        print_warning "iFlow CLI 未安装"
    fi
}

# 升级 iFlow CLI
upgrade_iflow() {
    print_info "正在升级 iFlow CLI..."
    
    # 检查 Node.js
    if ! check_nodejs; then
        return 1
    fi
    
    # 检查是否已安装
    if ! command -v iflow >/dev/null 2>&1; then
        print_warning "iFlow 未安装，请先安装"
        return 1
    fi
    
    # 获取当前版本
    local current_version=$(iflow --version 2>/dev/null || echo "unknown")
    print_info "当前版本: $current_version"
    
    # 尝试升级 iFlow
    print_info "正在尝试升级..."
    if execute_command "npm i -g @iflow-ai/iflow-cli" "suppress"; then
        local new_version=$(iflow --version 2>/dev/null || echo "unknown")
        if [ "$current_version" != "$new_version" ]; then
            print_success "iFlow CLI 升级成功: $new_version"
        else
            print_success "iFlow CLI 已是最新版本"
        fi
        return 0
    fi
    
    print_warning "升级失败，尝试手动清理后重新安装..."
    
    # 手动清理可能存在的临时目录
    local iflow_dir="$HOME/.nvm/versions/node/v$(node -v | sed 's/v//')/lib/node_modules/@iflow-ai/iflow-cli"
    local iflow_temp_dir="$HOME/.nvm/versions/node/v$(node -v | sed 's/v//')/lib/node_modules/@iflow-ai/.iflow-cli-*"
    
    # 尝试删除可能存在的临时目录
    rm -rf $iflow_temp_dir 2>/dev/null
    
    # 强制重新安装
    print_info "正在卸载 iFlow CLI..."
    execute_command "npm uninstall -g @iflow-ai/iflow-cli" "suppress"
    
    print_info "正在安装最新版本的 iFlow CLI..."
    if execute_command "npm install -g @iflow-ai/iflow-cli"; then
        local new_version=$(iflow --version 2>/dev/null || echo "unknown")
        print_success "iFlow CLI 重新安装成功: $new_version"
    else
        print_error "iFlow CLI 重新安装失败"
        return 1
    fi
}