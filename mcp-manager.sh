#!/bin/bash

# MCP服务器管理脚本
# 用于监控、清理和重启MCP服务器

set -euo pipefail  # 更严格的错误处理

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置常量
readonly SCRIPT_NAME="$(basename "$0")"
readonly LOG_FILE="/tmp/mcp-manager-$(date +%Y%m%d).log"

# 动态获取配置文件路径
get_config_file() {
    # 优先检查Claude原生配置文件
    local claude_config="$HOME/.claude.json"
    if [ -f "$claude_config" ]; then
        echo "$claude_config"
        return 0
    fi
    
    # 检查VSCode扩展配置文件
    local config_base="$HOME/.config/Code/User/globalStorage"
    local config_dirs=("geelib-copilot-code.copilotcodepro" "rooveterinaryinc.roo-cline")
    
    for dir in "${config_dirs[@]}"; do
        local config_file="$config_base/$dir/settings/CopilotCodePro_mcp_settings.json"
        if [ -f "$config_file" ]; then
            echo "$config_file"
            return 0
        fi
        
        # 也检查可能的mcp_settings.json文件
        local alt_config_file="$config_base/$dir/settings/mcp_settings.json"
        if [ -f "$alt_config_file" ]; then
            echo "$alt_config_file"
            return 0
        fi
    done
    
    # 如果都找不到，返回Claude默认路径
    echo "$claude_config"
}

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查MCP服务器状态
check_mcp_status() {
    log_info "检查MCP服务器状态..."
    
    echo -e "\n=== 正在运行的MCP服务器进程 ==="
    local mcp_processes=$(ps aux | grep -E "(mcp-server|context7-mcp|browser-tools-mcp|figma-developer|sequential-thinking)" | grep -v grep)
    
    if [ -z "$mcp_processes" ]; then
        log_warning "没有发现运行中的MCP服务器进程"
        return 1
    else
        echo "$mcp_processes"
        
        # 统计进程数量
        local total_processes=$(echo "$mcp_processes" | wc -l)
        echo -e "\n总计: $total_processes 个MCP进程正在运行"
        
        # 检查是否有重复进程
        local filesystem_count=$(echo "$mcp_processes" | grep -c "mcp-server-filesystem" || true)
        local context7_count=$(echo "$mcp_processes" | grep -c "context7-mcp" || true)
        local browser_count=$(echo "$mcp_processes" | grep -c "browser-tools-mcp" || true)
        local git_count=$(echo "$mcp_processes" | grep -c "mcp-server-git" || true)
        local sequential_count=$(echo "$mcp_processes" | grep -c "sequential-thinking" || true)
        local figma_count=$(echo "$mcp_processes" | grep -c "figma-developer" || true)
        
        echo -e "\n进程分布："
        echo "  - filesystem服务器: $filesystem_count"
        echo "  - context7服务器: $context7_count"
        echo "  - browser工具服务器: $browser_count"
        echo "  - git服务器: $git_count"
        echo "  - sequential-thinking服务器: $sequential_count"
        echo "  - figma开发工具: $figma_count"
        
        # 检查重复进程
        local has_duplicates=false
        local services_with_counts=(
            "filesystem:$filesystem_count"
            "context7:$context7_count" 
            "browser-tools:$browser_count"
            "git:$git_count"
            "sequential-thinking:$sequential_count"
            "figma:$figma_count"
        )
        
        for service_count in "${services_with_counts[@]}"; do
            local count=${service_count#*:}
            if [ "$count" -gt 1 ]; then
                has_duplicates=true
                break
            fi
        done
        
        if [ "$has_duplicates" = true ]; then
            log_warning "检测到重复的MCP服务器进程！"
            return 2
        fi
    fi
    
    return 0
}

# 安全的进程终止
safe_kill_processes() {
    local pattern="$1"
    local signal="${2:-TERM}"
    local pids
    
    log_info "查找匹配 '$pattern' 的进程..."
    
    if command -v pgrep >/dev/null 2>&1; then
        pids=$(pgrep -f "$pattern" || true)
    else
        pids=$(ps aux | grep -E "$pattern" | grep -v grep | awk '{print $2}' || true)
    fi
    
    if [ -z "$pids" ]; then
        log_info "没有找到匹配的进程"
        return 0
    fi
    
    log_info "找到进程: $pids"
    
    for pid in $pids; do
        if [ -d "/proc/$pid" ]; then
            local cmd_line=$(cat "/proc/$pid/cmdline" 2>/dev/null | tr '\0' ' ' || echo "unknown")
            log_info "终止进程 $pid: $cmd_line"
            
            if kill "-$signal" "$pid" 2>/dev/null; then
                log_success "进程 $pid 已终止"
            else
                log_warning "无法终止进程 $pid"
            fi
        fi
    done
    
    # 等待进程退出
    sleep 2
    
    # 检查是否还有残留进程
    local remaining
    if command -v pgrep >/dev/null 2>&1; then
        remaining=$(pgrep -f "$pattern" || true)
    else
        remaining=$(ps aux | grep -E "$pattern" | grep -v grep | awk '{print $2}' || true)
    fi
    
    if [ -n "$remaining" ]; then
        log_warning "仍有残留进程，尝试强制终止..."
        for pid in $remaining; do
            if [ -d "/proc/$pid" ]; then
                kill -KILL "$pid" 2>/dev/null || true
                log_info "强制终止进程 $pid"
            fi
        done
    fi
}

# 清理重复的MCP进程
cleanup_mcp_processes() {
    log_info "清理MCP进程..."
    
    # 扩展的MCP服务列表，包括各种扩展和插件
    local services=(
        "mcp-server-filesystem" 
        "context7-mcp" 
        "browser-tools-mcp" 
        "mcp-server-git" 
        "mcp-server-sequential-thinking" 
        "figma-developer-mcp"
    )
    local cleaned=false
    
    for service in "${services[@]}"; do
        local count=0
        if command -v pgrep >/dev/null 2>&1; then
            count=$(pgrep -f "$service" | wc -l)
        else
            count=$(ps aux | grep -E "$service" | grep -v grep | wc -l)
        fi
        
        if [ "$count" -gt 0 ]; then
            log_info "清理 $service 进程 ($count 个)..."
            safe_kill_processes "$service"
            cleaned=true
        fi
    done
    
    if [ "$cleaned" = true ]; then
        log_success "MCP进程清理完成"
        
        # 验证清理结果
        sleep 2
        local remaining_total=0
        for service in "${services[@]}"; do
            local count=0
            if command -v pgrep >/dev/null 2>&1; then
                count=$(pgrep -f "$service" | wc -l)
            else
                count=$(ps aux | grep -E "$service" | grep -v grep | wc -l)
            fi
            remaining_total=$((remaining_total + count))
        done
        
        if [ "$remaining_total" -gt 0 ]; then
            log_warning "仍有 $remaining_total 个进程未被清理"
        else
            log_success "所有MCP进程已成功清理"
        fi
    else
        log_info "没有需要清理的MCP进程"
    fi
}

# 验证配置文件
validate_config() {
    local config_file=$(get_config_file)
    
    log_info "验证MCP配置文件: $config_file"
    
    if [ ! -f "$config_file" ]; then
        log_error "配置文件不存在: $config_file"
        log_info "正在检查其他可能的配置文件位置..."
        
        # 检查Claude原生配置
        if [ ! -f "$HOME/.claude.json" ]; then
            log_info "Claude配置文件: $HOME/.claude.json - 不存在"
        fi
        
        # 尝试查找其他配置文件
        local config_base="$HOME/.config/Code/User/globalStorage"
        if [ -d "$config_base" ]; then
            find "$config_base" -name "*mcp*settings*.json" 2>/dev/null | while read -r file; do
                log_info "找到配置文件: $file"
            done
        fi
        
        return 1
    fi
    
    # 检查JSON格式
    if ! jq empty "$config_file" 2>/dev/null; then
        log_error "配置文件JSON格式错误"
        return 1
    fi
    
    log_success "配置文件验证通过"
    
    # 根据配置文件类型显示不同信息
    if [[ "$config_file" == *".claude.json" ]]; then
        echo -e "\n=== Claude原生MCP配置 ==="
        log_info "配置文件类型: Claude Desktop"
        
        # 显示MCP服务器列表
        echo -e "\n=== 配置的MCP服务器 ==="
        if jq -e '.mcpServers' "$config_file" >/dev/null 2>&1; then
            jq -r '.mcpServers | keys[]' "$config_file" 2>/dev/null | while read -r server; do
                echo "  - $server"
            done
        else
            log_warning "未找到MCP服务器配置"
        fi
        
        # 显示文件系统访问路径（如果存在）
        if jq -e '.mcpServers.filesystem' "$config_file" >/dev/null 2>&1; then
            echo -e "\n=== 文件系统访问路径 ==="
            jq -r '.mcpServers.filesystem.args[]? // empty' "$config_file" 2>/dev/null | while read -r path; do
                if [[ "$path" == /* ]]; then
                    echo "  - $path"
                fi
            done
        fi
    else
        echo -e "\n=== VSCode扩展MCP配置 ==="
        log_info "配置文件类型: VSCode Extension"
        
        # 检查filesystem服务器配置
        local filesystem_config=$(jq '.mcpServers["github.com/modelcontextprotocol/servers/tree/main/src/filesystem"]' "$config_file" 2>/dev/null)
        if [ "$filesystem_config" != "null" ] && [ -n "$filesystem_config" ]; then
            echo -e "\n=== 配置的允许目录 ==="
            jq -r '.mcpServers["github.com/modelcontextprotocol/servers/tree/main/src/filesystem"].args[]? | select(startswith("/"))' "$config_file" 2>/dev/null
        else
            log_warning "filesystem服务器配置未找到"
        fi
    fi
    
    return 0
}

# 重启MCP扩展
restart_mcp_extensions() {
    log_info "重启MCP扩展..."
    
    # 查找VSCode扩展进程
    local vscode_pids=$(pgrep -f "code.*mcp" || true)
    
    if [ -n "$vscode_pids" ]; then
        log_info "停止VSCode MCP扩展进程..."
        echo "$vscode_pids" | xargs kill -TERM 2>/dev/null || true
        sleep 3
        
        # 强制杀死仍在运行的进程
        vscode_pids=$(pgrep -f "code.*mcp" || true)
        if [ -n "$vscode_pids" ]; then
            log_warning "强制停止残留进程..."
            echo "$vscode_pids" | xargs kill -KILL 2>/dev/null || true
        fi
    fi
    
    log_success "MCP扩展重启完成"
    log_info "请手动重新启动VSCode以重新加载MCP服务器"
}

# 显示诊断信息
show_diagnostics() {
    log_info "MCP系统诊断信息"
    
    echo -e "\n=== 系统信息 ==="
    echo "当前用户: $(whoami)"
    echo "当前工作目录: $(pwd)"
    echo "当前时间: $(date)"
    
    echo -e "\n=== 网络连接检查 ==="
    if command -v nc >/dev/null; then
        if timeout 3 nc -z registry.npmjs.org 443 2>/dev/null; then
            log_success "NPM注册表连接正常"
        else
            log_warning "NPM注册表连接异常"
        fi
    fi
    
    echo -e "\n=== 依赖检查 ==="
    for cmd in node npm npx python jq; do
        if command -v $cmd >/dev/null; then
            local version=$($cmd --version 2>/dev/null | head -1)
            echo "  ✓ $cmd: $version"
        else
            echo "  ✗ $cmd: 未安装"
        fi
    done
    
    echo -e "\n=== 磁盘空间 ==="
    df -h /home/zhoubin /ssd 2>/dev/null | grep -E "(文件系统|Filesystem|/)" || df -h /home/zhoubin
}

# 显示帮助信息
show_help() {
    echo "MCP服务器管理脚本"
    echo ""
    echo "用法: $SCRIPT_NAME [命令]"
    echo ""
    echo "可用命令:"
    echo "  status     - 检查MCP服务器状态"
    echo "  cleanup    - 清理重复的MCP进程" 
    echo "  restart    - 重启MCP扩展"
    echo "  validate   - 验证配置文件"
    echo "  diagnose   - 显示诊断信息"
    echo "  full-reset - 完全重置(清理+重启)"
    echo "  help       - 显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $SCRIPT_NAME status"
    echo "  $SCRIPT_NAME cleanup"
    echo "  $SCRIPT_NAME full-reset"
}

# 完全重置
full_reset() {
    log_info "开始完全重置MCP系统..."
    
    cleanup_mcp_processes
    sleep 2
    
    if validate_config; then
        restart_mcp_extensions
        log_success "完全重置完成！请重新启动VSCode。"
    else
        log_error "配置验证失败，请检查配置文件"
        return 1
    fi
}

# 主函数
main() {
    case "${1:-help}" in
        "status")
            check_mcp_status
            ;;
        "cleanup")
            cleanup_mcp_processes
            ;;
        "restart")
            restart_mcp_extensions
            ;;
        "validate")
            validate_config
            ;;
        "diagnose")
            show_diagnostics
            ;;
        "full-reset")
            full_reset
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# 依赖检查函数
check_dependencies() {
    local missing_deps=()
    local deps=("jq" "pgrep" "pkill")
    
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "缺少必要依赖: ${missing_deps[*]}"
        log_info "请安装缺少的依赖："
        echo "  Ubuntu/Debian: sudo apt install ${missing_deps[*]}"
        echo "  CentOS/RHEL: sudo yum install ${missing_deps[*]}"
        exit 1
    fi
}

# 权限检查
check_permissions() {
    if [ "$EUID" -eq 0 ]; then
        log_warning "不建议以root身份运行此脚本"
        read -p "确定要继续吗？(y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# 检查依赖和权限
check_dependencies
check_permissions

# 运行主函数
main "$@"
