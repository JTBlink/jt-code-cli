#!/bin/bash

# Claude 脚本管理器
# 功能：管理Claude相关脚本的软链接，支持安装、卸载和状态查看

# 注意：不使用 set -e，以避免在函数返回非零状态时意外退出
set -u  # 只使用 set -u 来检测未定义变量

# 获取当前脚本所在目录的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TARGET_DIR="${HOME}/.local/bin"

# 要管理的脚本列表
SCRIPTS=(
    "jt-code.sh"
)

# 打印信息函数
print_info() {
    echo "[信息] $1"
}

print_success() {
    echo "[成功] $1"
}

print_warning() {
    echo "[警告] $1"
}

print_error() {
    echo "[错误] $1"
}

# 显示帮助信息
show_help() {
    echo "Claude 脚本管理器"
    echo ""
    echo "用法:"
    echo "  $0 install   # 安装所有Claude脚本软链接"
    echo "  $0 uninstall # 卸载所有Claude脚本软链接"
    echo "  $0 status    # 显示软链接状态"
    echo "  $0 list      # 列出可管理的脚本"
    echo "  $0 help      # 显示此帮助信息"
    echo ""
    echo "单个脚本操作:"
    echo "  $0 install <script>   # 安装指定脚本"
    echo "  $0 uninstall <script> # 卸载指定脚本"
    echo ""
    echo "可用脚本:"
    for script in "${SCRIPTS[@]}"; do
        local cmd_name="${script%.sh}"
        echo "  - $cmd_name ($script)"
    done
}

# 检查脚本是否在管理列表中
is_managed_script() {
    local script="$1"
    for managed in "${SCRIPTS[@]}"; do
        if [ "$script" = "$managed" ] || [ "$script" = "${managed%.sh}" ]; then
            echo "$managed"
            return 0
        fi
    done
    return 1
}

# 创建单个软链接
install_script() {
    local script="$1"
    local source_file="$SCRIPT_DIR/$script"
    local target_name="${script%.sh}"
    local target_file="$TARGET_DIR/$target_name"
    
    print_info "安装 $target_name..."
    
    # 检查源文件是否存在
    if [ ! -f "$source_file" ]; then
        print_error "源文件 $source_file 不存在"
        return 1
    fi
    
    # 确保目标目录存在
    mkdir -p "$TARGET_DIR"
    
    # 检查目标文件状态
    if [ -L "$target_file" ]; then
        local current_target=$(readlink "$target_file")
        if [ "$current_target" = "$source_file" ]; then
            print_info "$target_name 已正确安装"
            return 0
        else
            print_warning "$target_name 软链接存在但指向错误位置，正在更新..."
            rm "$target_file"
        fi
    elif [ -f "$target_file" ]; then
        print_warning "$target_name 文件已存在但不是软链接，正在备份..."
        mv "$target_file" "${target_file}.bak.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # 创建软链接
    ln -sf "$source_file" "$target_file"
    
    # 确保源文件可执行
    chmod +x "$source_file"
    
    print_success "$target_name 安装成功 -> $source_file"
    return 0
}

# 删除单个软链接
uninstall_script() {
    local script="$1"
    local target_name="${script%.sh}"
    local target_file="$TARGET_DIR/$target_name"
    
    print_info "卸载 $target_name..."
    
    if [ -L "$target_file" ]; then
        rm "$target_file"
        print_success "$target_name 卸载成功"
        return 0
    elif [ -f "$target_file" ]; then
        print_warning "$target_name 存在但不是软链接，需要手动处理"
        return 1
    else
        print_info "$target_name 未安装"
        return 0
    fi
}

# 显示脚本状态
show_script_status() {
    local script="$1"
    local source_file="$SCRIPT_DIR/$script"
    local target_name="${script%.sh}"
    local target_file="$TARGET_DIR/$target_name"
    
    printf "%-20s" "$target_name"
    
    if [ ! -f "$source_file" ]; then
        echo "❌ 源文件缺失"
        return 1
    fi
    
    if [ -L "$target_file" ]; then
        local current_target=$(readlink "$target_file")
        if [ "$current_target" = "$source_file" ]; then
            echo "✅ 已安装"
        else
            echo "⚠️  软链接错误"
        fi
    elif [ -f "$target_file" ]; then
        echo "❓ 文件冲突"
    else
        echo "❌ 未安装"
    fi
}

# 安装所有脚本
install_all() {
    print_info "开始安装所有Claude脚本..."
    
    local success_count=0
    local total=${#SCRIPTS[@]}
    
    for script in "${SCRIPTS[@]}"; do
        if install_script "$script"; then
            ((success_count++))
        fi
        echo ""
    done
    
    echo "===== 安装结果 ====="
    if [ $success_count -eq $total ]; then
        print_success "所有脚本安装成功！($success_count/$total)"
    else
        print_warning "部分脚本安装成功 ($success_count/$total)"
    fi
    
    echo ""
    echo "现在可以使用以下命令:"
    for script in "${SCRIPTS[@]}"; do
        local cmd_name="${script%.sh}"
        echo "  - $cmd_name"
    done
}

# 卸载所有脚本
uninstall_all() {
    print_info "开始卸载所有Claude脚本..."
    
    local success_count=0
    local total=${#SCRIPTS[@]}
    
    for script in "${SCRIPTS[@]}"; do
        if uninstall_script "$script"; then
            ((success_count++))
        fi
        echo ""
    done
    
    echo "===== 卸载结果 ====="
    if [ $success_count -eq $total ]; then
        print_success "所有脚本卸载成功！($success_count/$total)"
    else
        print_warning "部分脚本卸载成功 ($success_count/$total)"
    fi
}

# 显示所有脚本状态
show_status() {
    echo "===== Claude 脚本状态 ====="
    echo ""
    printf "%-20s %s\n" "脚本名称" "状态"
    printf "%-20s %s\n" "--------" "----"
    
    for script in "${SCRIPTS[@]}"; do
        show_script_status "$script"
    done
    
    echo ""
    echo "说明:"
    echo "  ✅ 已安装    - 软链接正确"
    echo "  ❌ 未安装    - 软链接不存在"
    echo "  ❌ 源文件缺失 - 源脚本文件不存在"
    echo "  ⚠️  软链接错误 - 软链接指向错误位置"
    echo "  ❓ 文件冲突  - 目标位置有同名文件但不是软链接"
}

# 列出可管理的脚本
list_scripts() {
    echo "===== 可管理的Claude脚本 ====="
    echo ""
    
    for script in "${SCRIPTS[@]}"; do
        local source_file="$SCRIPT_DIR/$script"
        local cmd_name="${script%.sh}"
        
        printf "%-20s" "$cmd_name"
        if [ -f "$source_file" ]; then
            echo "✅ ($script)"
        else
            echo "❌ ($script) - 文件不存在"
        fi
    done
    
    echo ""
    echo "使用方法:"
    echo "  安装: $0 install <脚本名>"
    echo "  卸载: $0 uninstall <脚本名>"
}

# 主函数
main() {
    case "${1:-}" in
        install)
            if [ -n "${2:-}" ]; then
                # 安装指定脚本
                if managed_script=$(is_managed_script "$2"); then
                    install_script "$managed_script"
                else
                    print_error "未知脚本: $2"
                    echo ""
                    list_scripts
                    exit 1
                fi
            else
                # 安装所有脚本
                install_all
            fi
            ;;
        uninstall)
            if [ -n "${2:-}" ]; then
                # 卸载指定脚本
                if managed_script=$(is_managed_script "$2"); then
                    uninstall_script "$managed_script"
                else
                    print_error "未知脚本: $2"
                    echo ""
                    list_scripts
                    exit 1
                fi
            else
                # 卸载所有脚本
                uninstall_all
            fi
            ;;
        status)
            show_status
            ;;
        list)
            list_scripts
            ;;
        help|-h|--help)
            show_help
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
}

main "$@"
