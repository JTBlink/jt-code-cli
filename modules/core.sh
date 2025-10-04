#!/bin/bash

# =================================================================
# JT Code CLI - 核心功能模块
# 作者: JTStudio Dev Team
# 描述: 提供颜色输出、命令执行等核心功能
# =================================================================

# 颜色输出函数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 执行命令并打印执行信息
execute_command() {
    local command="$1"
    local suppress_output="$2"
    
    print_info "执行命令: $command"
    
    if [ "$suppress_output" = "suppress" ]; then
        eval "$command" >/dev/null 2>&1
    else
        eval "$command"
    fi
    
    return $?
}