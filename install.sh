#!/usr/bin/env bash
# Engineered Writing Skill - 安装脚本
# 用法：
#   bash install.sh              # 自动检测环境并安装
#   bash install.sh --claude     # 安装到 Claude Code
#   bash install.sh --cursor     # 安装到 Cursor
#   bash install.sh --windsurf   # 安装到 Windsurf
#   bash install.sh --cline      # 安装到 Cline/Roo Code
#   bash install.sh --merged     # 生成合并版（单文件 system prompt）
#   bash install.sh --project    # 安装到当前项目目录

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="engineered-writing"

# 颜色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

info() { echo -e "${BLUE}[info]${NC} $1"; }
ok() { echo -e "${GREEN}[done]${NC} $1"; }
warn() { echo -e "${YELLOW}[warn]${NC} $1"; }

# 复制核心文件（排除 README、install.sh、.git）
copy_skill() {
    local dest="$1"
    mkdir -p "$dest/references" "$dest/scripts"
    cp "$SCRIPT_DIR/SKILL.md" "$dest/"
    cp "$SCRIPT_DIR/references/"*.md "$dest/references/"
    cp "$SCRIPT_DIR/scripts/"*.sh "$dest/scripts/"
    chmod +x "$dest/scripts/"*.sh 2>/dev/null || true
}

# 生成合并版（所有文件合并为一个 markdown）
generate_merged() {
    local output="${1:-$SCRIPT_DIR/engineered-writing-merged.md}"
    {
        cat "$SCRIPT_DIR/SKILL.md"
        echo ""
        echo "---"
        echo ""
        for f in "$SCRIPT_DIR/references/"*.md; do
            echo "# [Reference] $(basename "$f" .md)"
            echo ""
            # 跳过 frontmatter（如果有的话）
            cat "$f"
            echo ""
            echo "---"
            echo ""
        done
    } > "$output"
    ok "合并版已生成: $output"
}

# Claude Code 安装
install_claude() {
    local dest="$HOME/.claude/skills/$SKILL_NAME"
    if [ -d "$dest" ]; then
        warn "已存在: $dest（将覆盖）"
    fi
    copy_skill "$dest"
    ok "已安装到 Claude Code: $dest"
    info "重启 Claude Code 后生效。使用 /write、/revise、/check 等命令触发。"
}

# Cursor 安装
install_cursor() {
    local project_dir="${1:-.}"
    local dest="$project_dir/.cursor/rules"
    mkdir -p "$dest/references"
    cp "$SCRIPT_DIR/SKILL.md" "$dest/engineered-writing.md"
    cp "$SCRIPT_DIR/references/"*.md "$dest/references/"
    ok "已安装到 Cursor: $dest/engineered-writing.md"
    info "Cursor 会自动加载 .cursor/rules/ 下的规则文件。"
}

# Windsurf 安装
install_windsurf() {
    local project_dir="${1:-.}"
    local dest="$project_dir/.windsurf/rules"
    mkdir -p "$dest/references"
    cp "$SCRIPT_DIR/SKILL.md" "$dest/engineered-writing.md"
    cp "$SCRIPT_DIR/references/"*.md "$dest/references/"
    ok "已安装到 Windsurf: $dest/engineered-writing.md"
}

# Cline 安装
install_cline() {
    local project_dir="${1:-.}"
    local dest="$project_dir"
    if [ -f "$dest/.clinerules" ]; then
        warn ".clinerules 已存在，将追加内容"
        echo "" >> "$dest/.clinerules"
        echo "---" >> "$dest/.clinerules"
        echo "" >> "$dest/.clinerules"
        cat "$SCRIPT_DIR/SKILL.md" >> "$dest/.clinerules"
    else
        cp "$SCRIPT_DIR/SKILL.md" "$dest/.clinerules"
    fi
    ok "已安装到 Cline: $dest/.clinerules"
}

# 项目级安装
install_project() {
    local project_dir="${1:-.}"
    local dest="$project_dir/.engineered-writing"
    copy_skill "$dest"
    ok "已安装到项目: $dest/"
    info "AI 工具需要手动指向该目录，或将 SKILL.md 内容添加到项目规则中。"
}

# 自动检测
auto_detect() {
    if [ -d "$HOME/.claude" ]; then
        info "检测到 Claude Code 环境"
        install_claude
        return
    fi
    if [ -d ".cursor" ]; then
        info "检测到 Cursor 项目"
        install_cursor "."
        return
    fi
    if [ -d ".windsurf" ]; then
        info "检测到 Windsurf 项目"
        install_windsurf "."
        return
    fi
    if [ -f ".clinerules" ]; then
        info "检测到 Cline 项目"
        install_cline "."
        return
    fi
    # 默认：Claude Code
    if command -v claude &>/dev/null; then
        info "检测到 claude 命令，安装到 Claude Code"
        install_claude
    else
        warn "未检测到特定环境，生成合并版供手动使用"
        generate_merged
    fi
}

# 主逻辑
case "${1:-}" in
    --claude)    install_claude ;;
    --cursor)    install_cursor "${2:-.}" ;;
    --windsurf)  install_windsurf "${2:-.}" ;;
    --cline)     install_cline "${2:-.}" ;;
    --project)   install_project "${2:-.}" ;;
    --merged)    generate_merged "${2:-}" ;;
    --help|-h)
        echo "用法: bash install.sh [选项]"
        echo ""
        echo "选项:"
        echo "  (无)          自动检测环境并安装"
        echo "  --claude      安装到 Claude Code (~/.claude/skills/)"
        echo "  --cursor      安装到 Cursor (.cursor/rules/)"
        echo "  --windsurf    安装到 Windsurf (.windsurf/rules/)"
        echo "  --cline       安装到 Cline (.clinerules)"
        echo "  --project     安装到当前项目 (.engineered-writing/)"
        echo "  --merged      生成合并版单文件（适用于任何 AI）"
        echo "  --help        显示本帮助"
        ;;
    *)           auto_detect ;;
esac
