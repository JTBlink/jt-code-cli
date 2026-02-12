#!/bin/bash

# =================================================================
# JT Code CLI - iFlow CLI 模块
# 作者: JTStudio Dev Team
# 描述: 提供 iFlow CLI 的安装、卸载、升级功能
# =================================================================

# 安装 iFlow CLI
install_iflow() {
    print_info "正在安装 iFlow CLI..."

    # 检查是否已安装
    if command -v iflow >/dev/null 2>&1; then
        print_warning "iFlow 已安装: $(iflow --version 2>/dev/null || echo 'unknown')"
        return 0
    fi

    # 尝试使用官方推荐的直接脚本安装方法
    if command -v curl >/dev/null 2>&1; then
        print_info "使用官方推荐的直接安装脚本安装 iFlow CLI..."
        if execute_command "bash -c \"\$(curl -fsSL https://gitee.com/iflow-ai/iflow-cli/raw/main/install.sh)\""; then
            if command -v iflow >/dev/null 2>&1; then
                print_success "iFlow CLI 安装成功: $(iflow --version)"
                return 0
            fi
        fi
    fi

    # 如果直接脚本安装失败，回退到 npm 安装
    print_info "尝试使用 npm 安装 iFlow CLI..."
    
    # 检查 Node.js
    if ! check_nodejs; then
        return 1
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

    # 检查是否已安装
    if ! command -v iflow >/dev/null 2>&1; then
        print_warning "iFlow 未安装，请先安装"
        return 1
    fi

    # 获取当前版本
    local current_version=$(iflow --version 2>/dev/null || echo "unknown")
    print_info "当前版本: $current_version"

    # 检查是否 installed via npm (check if it's in node_modules)
    if npm list -g @iflow-ai/iflow-cli >/dev/null 2>&1; then
        # Installed via npm, upgrade using npm
        # Check Node.js for npm installations
        if ! check_nodejs; then
            return 1
        fi
        
        print_info "正在尝试通过 npm 升级..."
        if execute_command "npm update -g @iflow-ai/iflow-cli" "suppress"; then
            local new_version=$(iflow --version 2>/dev/null || echo "unknown")
            if [ "$current_version" != "$new_version" ]; then
                print_success "iFlow CLI 升级成功: $new_version"
            else
                print_success "iFlow CLI 已是最新版本"
            fi
            return 0
        fi
        
        # If npm update fails, try reinstalling
        print_info "npm update 失败，尝试重新安装..."
        if execute_command "npm install -g @iflow-ai/iflow-cli"; then
            local new_version=$(iflow --version 2>/dev/null || echo "unknown")
            print_success "iFlow CLI 重新安装成功: $new_version"
            return 0
        else
            print_error "npm 重新安装失败"
        fi
    else
        # Likely installed via direct script, try reinstalling with script
        if command -v curl >/dev/null 2>&1; then
            print_info "检测到通过脚本安装的 iFlow，尝试使用官方脚本重新安装..."
            if execute_command "bash -c \"\$(curl -fsSL https://gitee.com/iflow-ai/iflow-cli/raw/main/install.sh)\""; then
                local new_version=$(iflow --version 2>/dev/null || echo "unknown")
                print_success "iFlow CLI 重新安装成功: $new_version"
                return 0
            else
                print_error "脚本重新安装失败"
            fi
        fi
    fi

    print_error "iFlow CLI 升级失败"
    return 1
}