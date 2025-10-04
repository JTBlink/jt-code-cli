#!/bin/bash

# =================================================================
# JT Code CLI - Qwen Code 模块
# 作者: JTStudio Dev Team
# 描述: 提供 Qwen Code 的安装、卸载、升级功能
# =================================================================

# 安装 Qwen Code
install_qwen() {
    print_info "正在安装 Qwen Code..."
    
    # 检查 Node.js
    if ! check_nodejs; then
        return 1
    fi
    
    # 检查是否已安装
    if command -v qwen >/dev/null 2>&1; then
        print_warning "Qwen Code 已安装: $(qwen --version 2>/dev/null || echo 'unknown')"
        return 0
    fi
    
    # 安装 Qwen Code
    execute_command "npm install -g @qwen-code/qwen-code"
    
    if command -v qwen >/dev/null 2>&1; then
        print_success "Qwen Code 安装成功: $(qwen --version)"
        print_info "Qwen Code 安装完成，您可以运行 'qwen' 命令开始使用"
    else
        print_error "Qwen Code 安装失败"
        return 1
    fi
}

# 卸载 Qwen Code
uninstall_qwen() {
    print_info "正在卸载 Qwen Code..."
    
    if command -v qwen >/dev/null 2>&1; then
        execute_command "npm uninstall -g @qwen-code/qwen-code"
        print_success "Qwen Code 已卸载"
    else
        print_warning "Qwen Code 未安装"
    fi
}

# 升级 Qwen Code
upgrade_qwen() {
    print_info "正在升级 Qwen Code..."
    
    # 检查 Node.js
    if ! check_nodejs; then
        return 1
    fi
    
    # 检查是否已安装
    if ! command -v qwen >/dev/null 2>&1; then
        print_warning "Qwen Code 未安装，请先安装"
        return 1
    fi
    
    # 获取当前版本
    local current_version=$(qwen --version 2>/dev/null || echo "unknown")
    print_info "当前版本: $current_version"
    
    # 尝试升级 Qwen Code
    print_info "正在尝试升级..."
    if execute_command "npm update -g @qwen-code/qwen-code" "suppress"; then
        local new_version=$(qwen --version 2>/dev/null || echo "unknown")
        if [ "$current_version" != "$new_version" ]; then
            print_success "Qwen Code 升级成功: $new_version"
        else
            print_success "Qwen Code 已是最新版本"
        fi
        return 0
    fi
    
    print_warning "升级失败，尝试手动清理后重新安装..."
    
    # 手动清理可能存在的临时目录
    local qwen_dir="$HOME/.nvm/versions/node/v$(node -v | sed 's/v//')/lib/node_modules/@qwen-code/qwen-code"
    local qwen_temp_dir="$HOME/.nvm/versions/node/v$(node -v | sed 's/v//')/lib/node_modules/@qwen-code/.qwen-code-*"
    
    # 尝试删除可能存在的临时目录
    rm -rf $qwen_temp_dir 2>/dev/null
    
    # 强制重新安装
    print_info "正在卸载 Qwen Code..."
    execute_command "npm uninstall -g @qwen-code/qwen-code" "suppress"
    
    print_info "正在安装最新版本的 Qwen Code..."
    if execute_command "npm install -g @qwen-code/qwen-code"; then
        local new_version=$(qwen --version 2>/dev/null || echo "unknown")
        print_success "Qwen Code 重新安装成功: $new_version"
    else
        print_error "Qwen Code 重新安装失败"
        return 1
    fi
}