#!/bin/bash

# =================================================================
# JT Code CLI - OpenCode 模块
# 作者: JTStudio Dev Team
# 描述: 提供 OpenCode 的安装、卸载、升级功能
# =================================================================

# 安装 OpenCode
install_opencode() {
    print_info "正在安装 OpenCode..."

    # 检查 Node.js
    if ! check_nodejs; then
        print_info "尝试使用其他方式安装 OpenCode..."
    fi

    # 检查是否已安装
    if command -v opencode >/dev/null 2>&1; then
        print_warning "OpenCode 已安装: $(opencode --version 2>/dev/null || echo 'unknown')"
        return 0
    fi

    # 尝试使用 npm 安装
    if command -v npm >/dev/null 2>&1; then
        print_info "使用 npm 安装 OpenCode..."
        if execute_command "npm install -g opencode-ai"; then
            if command -v opencode >/dev/null 2>&1; then
                print_success "OpenCode 安装成功: $(opencode --version 2>/dev/null || echo 'installed')"
                print_info "首次运行 'opencode' 可能需要配置 API 密钥"
                return 0
            fi
        fi
    fi

    # 如果 npm 不可用，尝试使用 curl 安装脚本
    if command -v curl >/dev/null 2>&1; then
        print_info "使用 curl 安装脚本安装 OpenCode..."
        if execute_command "curl -fsSL https://opencode.ai/install | bash"; then
            # 将安装路径添加到当前会话的 PATH
            export PATH="$HOME/.opencode/bin:$PATH"
            
            if command -v opencode >/dev/null 2>&1; then
                print_success "OpenCode 安装成功: $(opencode --version 2>/dev/null || echo 'installed')"
                print_info "首次运行 'opencode' 可能需要配置 API 密钥"
                return 0
            fi
        fi
    fi

    # 如果 curl 不可用，尝试使用 Homebrew (仅限 macOS/Linux)
    if [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v brew >/dev/null 2>&1; then
            print_info "使用 Homebrew 安装 OpenCode..."
            if execute_command "brew install anomalyco/tap/opencode"; then
                if command -v opencode >/dev/null 2>&1; then
                    print_success "OpenCode 安装成功: $(opencode --version 2>/dev/null || echo 'installed')"
                    print_info "首次运行 'opencode' 可能需要配置 API 密钥"
                    return 0
                fi
            fi
        fi
    fi

    print_error "OpenCode 安装失败"
    return 1
}

# 卸载 OpenCode
uninstall_opencode() {
    print_info "正在卸载 OpenCode..."

    # 尝试通过 npm 卸载
    if command -v npm >/dev/null 2>&1 && npm list -g opencode-ai >/dev/null 2>&1; then
        execute_command "npm uninstall -g opencode-ai"
        print_success "OpenCode (npm) 已卸载"
    elif command -v opencode >/dev/null 2>&1; then
        print_warning "检测到 OpenCode，但无法确定安装方式，可能需要手动卸载"
    else
        print_warning "OpenCode 未安装"
        return 0
    fi

    # 尝试清理配置文件
    local opencode_config="$HOME/.opencode"
    if [ -d "$opencode_config" ]; then
        execute_command "rm -rf $opencode_config"
        print_success "已清理 OpenCode 配置目录"
    fi
}

# 升级 OpenCode
upgrade_opencode() {
    print_info "正在升级 OpenCode..."

    # 检查是否已安装
    if ! command -v opencode >/dev/null 2>&1; then
        print_warning "OpenCode 未安装，请先安装"
        return 1
    fi

    # 获取当前版本
    local current_version=$(opencode --version 2>/dev/null || echo "unknown")
    print_info "当前版本: $current_version"

    # 尝试 through npm if installed via npm
    if command -v npm >/dev/null 2>&1 && npm list -g opencode-ai >/dev/null 2>&1; then
        print_info "正在尝试通过 npm 升级..."
        if execute_command "npm update -g opencode-ai" "suppress"; then
            local new_version=$(opencode --version 2>/dev/null || echo "unknown")
            if [ "$current_version" != "$new_version" ]; then
                print_success "OpenCode 升级成功: $new_version"
            else
                print_success "OpenCode 已是最新版本"
            fi
            return 0
        fi
    fi

    # If npm upgrade fails, try reinstalling
    print_info "npm upgrade 失败，尝试重新安装..."
    if execute_command "npm install -g opencode-ai"; then
        local new_version=$(opencode --version 2>/dev/null || echo "unknown")
        print_success "OpenCode 重新安装成功: $new_version"
        return 0
    else
        print_error "OpenCode 重新安装失败"
        return 1
    fi
}