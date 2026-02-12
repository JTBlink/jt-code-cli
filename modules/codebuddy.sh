#!/bin/bash

# =================================================================
# JT Code CLI - CodeBuddy 模块
# 作者: JTStudio Dev Team
# 描述: 提供 CodeBuddy 的安装、卸载、升级功能
# =================================================================

# 安装 CodeBuddy
install_codebuddy() {
    print_info "正在安装 CodeBuddy..."
    
    # 检查 Node.js
    if ! check_nodejs; then
        return 1
    fi
    
    # 检查是否已安装
    if command -v cbc >/dev/null 2>&1 || command -v codebuddy >/dev/null 2>&1; then
        local version_cmd="cbc"
        if ! command -v cbc >/dev/null 2>&1; then
            version_cmd="codebuddy"
        fi
        print_warning "CodeBuddy 已安装: $($version_cmd --version 2>/dev/null || echo 'unknown')"
        return 0
    fi
    
    # 安装 CodeBuddy
    execute_command "npm install -g @tencent-ai/codebuddy-code"
    
    if command -v cbc >/dev/null 2>&1 || command -v codebuddy >/dev/null 2>&1; then
        local version_cmd="cbc"
        local run_cmd="cbc"
        if ! command -v cbc >/dev/null 2>&1; then
            version_cmd="codebuddy"
            run_cmd="codebuddy"
        fi
        print_success "CodeBuddy 安装成功: $($version_cmd --version 2>/dev/null || echo 'installed')"
        
        # 配置 CodeBuddy
        print_info "正在配置 CodeBuddy..."
        print_info "请访问 https://www.codebuddy.ai/cli 获取更多配置信息"
        print_success "CodeBuddy 配置完成"
        print_info "请运行 '$run_cmd' 命令进行初始配置"
    else
        print_error "CodeBuddy 安装失败"
        return 1
    fi
}

# 卸载 CodeBuddy
uninstall_codebuddy() {
    print_info "正在卸载 CodeBuddy..."
    
    if command -v cbc >/dev/null 2>&1 || command -v codebuddy >/dev/null 2>&1; then
        execute_command "npm uninstall -g @tencent-ai/codebuddy-code"
        print_success "CodeBuddy 已卸载"
        
        # 清理配置文件
        local codebuddy_config="$HOME/.codebuddy"
        if [ -d "$codebuddy_config" ]; then
            read -p "是否删除 CodeBuddy 配置目录? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                execute_command "rm -rf $codebuddy_config"
                print_success "已清理 CodeBuddy 配置目录"
            fi
        fi
        
        local codebuddy_config_file="$HOME/.codebuddyrc"
        if [ -f "$codebuddy_config_file" ]; then
            read -p "是否删除 CodeBuddy 配置文件? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                execute_command "rm -f $codebuddy_config_file"
                print_success "已清理 CodeBuddy 配置文件"
            fi
        fi
    else
        print_warning "CodeBuddy 未安装"
    fi
}

# 升级 CodeBuddy
upgrade_codebuddy() {
    print_info "正在升级 CodeBuddy..."

    # 检查 Node.js
    if ! check_nodejs; then
        return 1
    fi

    # 检查是否已安装
    if ! command -v cbc >/dev/null 2>&1 && ! command -v codebuddy >/dev/null 2>&1; then
        print_warning "CodeBuddy 未安装，请先安装"
        return 1
    fi

    # 获取当前版本
    local version_cmd="cbc"
    if ! command -v cbc >/dev/null 2>&1; then
        version_cmd="codebuddy"
    fi
    local current_version=$($version_cmd --version 2>/dev/null || echo "unknown")
    print_info "当前版本: $current_version"

    # 尝试 upgrade CodeBuddy
    print_info "正在尝试升级..."
    if execute_command "npm update -g @tencent-ai/codebuddy-code" "suppress"; then
        local new_version=$($version_cmd --version 2>/dev/null || echo "unknown")
        if [ "$current_version" != "$new_version" ]; then
            print_success "CodeBuddy 升级成功: $new_version"
        else
            print_success "CodeBuddy 已是最新版本"
        fi
        return 0
    fi

    # If npm update fails, try reinstalling
    print_info "npm update 失败，尝试重新安装..."
    if execute_command "npm install -g @tencent-ai/codebuddy-code"; then
        # Redetect command after reinstall
        local final_version_cmd="cbc"
        if ! command -v cbc >/dev/null 2>&1; then
            final_version_cmd="codebuddy"
        fi
        local new_version=$($final_version_cmd --version 2>/dev/null || echo "unknown")
        print_success "CodeBuddy 重新安装成功: $new_version"
        return 0
    else
        print_error "CodeBuddy 重新安装失败"
        return 1
    fi
}