#!/usr/bin/env bash
# 一致性检查脚本（consistency-check.sh）
#
# 用法：
#   bash scripts/consistency-check.sh [项目目录]
#
# 默认在当前目录运行。扫描所有 *_初稿.md 文件，输出潜在的一致性冲突。
# 检查项：人名、时间线、楼层分布、章节编号、铁律违反、视角越界。

set -u

PROJECT_DIR="${1:-.}"
cd "$PROJECT_DIR" || { echo "目录不存在: $PROJECT_DIR" >&2; exit 1; }

# ANSI 颜色（Windows Git Bash 支持）
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_warn() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_err() {
    echo -e "${RED}[冲突]${NC} $1"
}

print_ok() {
    echo -e "${GREEN}[通过]${NC} $1"
}

# 找到所有初稿文件
DRAFTS=$(ls -1 *_初稿.md 2>/dev/null | sort)
if [ -z "$DRAFTS" ]; then
    echo "未找到 *_初稿.md 文件，请在项目根目录运行" >&2
    exit 1
fi

echo "检测到的初稿文件："
echo "$DRAFTS" | sed 's/^/  - /'

# ========== 1. 人名一致性 ==========
print_header "1. 人名扫描"

# 主要人物名单（从人物小传/CONTEXT.md 提取的固定名单）
NAMES="陈砚 周小雨 小雨 苗苗 阿芳 阿欣 老周 妞妞 王建国 李秀芹 思思 老高 阿钧 张姐 老吴"

for name in $NAMES; do
    count=$(grep -c "$name" $DRAFTS 2>/dev/null | awk -F: '{sum+=$2} END {print sum+0}')
    printf "  %s: %d 次\n" "$name" "$count"
done

# 检查疑似变体（同人物的不同写法）
print_header "1.1 疑似人名变体"
VARIANTS="王建国|老王|建国 李秀芹|秀芹|小李 周小雨|小雨|周雨"
for variant_group in $VARIANTS; do
    found=$(grep -lE "$variant_group" $DRAFTS 2>/dev/null | wc -l)
    if [ "$found" -gt 0 ]; then
        echo "  $variant_group → 出现在 $found 个文件"
    fi
done

# ========== 2. 时间线 ==========
print_header "2. 时间线扫描"

# 提取所有年份
echo "年份分布："
grep -hoE "20[0-9]{2}年" $DRAFTS 2>/dev/null | sort | uniq -c | sort -rn | head -20 | sed 's/^/  /'

# 提取月份事件
print_header "2.1 月份事件"
grep -nE "(一月|二月|三月|四月|五月|六月|七月|八月|九月|十月|十一月|十二月|春|夏|秋|冬)" $DRAFTS 2>/dev/null | head -30 | sed 's/^/  /'

# ========== 3. 楼层分布 ==========
print_header "3. 楼层分布检查"

# CONTEXT.md 规定：二楼王家，三楼老高，四楼陈砚，五楼姐妹，六楼阿钧
echo "预期分布：二楼-王家 / 三楼-老高 / 四楼-陈砚 / 五楼-姐妹 / 六楼-阿钧"
echo ""
echo "实际出现："
for floor in 一楼 二楼 三楼 四楼 五楼 六楼 顶楼; do
    count=$(grep -c "$floor" $DRAFTS 2>/dev/null | awk -F: '{sum+=$2} END {print sum+0}')
    printf "  %s: %d 次\n" "$floor" "$count"
done

# ========== 4. 章节编号 ==========
print_header "4. 章节编号扫描"

for f in $DRAFTS; do
    echo "  $f:"
    grep -nE "^#+ ?第?[一二三四五六七八九十百零〇0-9]+[节章]" "$f" 2>/dev/null | sed 's/^/    /'
done

# ========== 5. 铁律违反扫描 ==========
print_header "5. 铁律黑名单扫描"

# 严禁的关系命名
BANNED_RELATIONS="恋人|男朋友|女朋友|姐弟|知己|好朋友"
echo "5.1 关系命名（应严禁）："
matches=$(grep -nE "$BANNED_RELATIONS" $DRAFTS 2>/dev/null)
if [ -n "$matches" ]; then
    echo "$matches" | sed 's/^/  /'
    print_err "发现关系命名词，需人工核查上下文"
else
    print_ok "无关系命名词"
fi

# 救赎/觉醒类词汇
BANNED_REDEMPTION="救赎|拯救|改变了我|让我懂得|让我明白|觉醒|重生"
echo ""
echo "5.2 救赎/觉醒类（应严禁）："
matches=$(grep -nE "$BANNED_REDEMPTION" $DRAFTS 2>/dev/null)
if [ -n "$matches" ]; then
    echo "$matches" | sed 's/^/  /'
    print_err "发现救赎类词汇，需人工核查"
else
    print_ok "无救赎类词汇"
fi

# 预言式回望
BANNED_PROPHECY="这是最后一次|那时还不知道|多年后才|谁也想不到|没人能料到"
echo ""
echo "5.3 预言式回望（应严禁）："
matches=$(grep -nE "$BANNED_PROPHECY" $DRAFTS 2>/dev/null)
if [ -n "$matches" ]; then
    echo "$matches" | sed 's/^/  /'
    print_warn "发现预言式回望，需人工核查（部分场景可能合理）"
else
    print_ok "无预言式回望"
fi

# ========== 6. 视角越界扫描 ==========
# 注意：此检测仅覆盖模式 1/2（严格外部/内省第一人称）的常见越界。
# 模式 3/4/5 需根据 CONTEXT.md 中选定的模式规则人工核查。
print_header "6. 视角越界扫描（模式 1/2 通用检测）"

POV_VIOLATIONS="大概是|其实是|心里想|后来才明白|那时一定|是为了"
matches=$(grep -nE "$POV_VIOLATIONS" $DRAFTS 2>/dev/null)
if [ -n "$matches" ]; then
    echo "$matches" | head -20 | sed 's/^/  /'
    print_warn "发现可能的视角越界，需人工核查（并确认 CONTEXT.md 中的视角模式）"
else
    print_ok "未发现明显越界"
fi

# ========== 7. AI味结构指标 ==========
print_header "7. AI味结构指标"

for f in $DRAFTS; do
    # 段落数（空行分隔）
    paragraphs=$(awk 'BEGIN{p=1} /^[[:space:]]*$/{if(prev!=""){p++}; prev=""} /^[^[:space:]]/{prev=$0}' "$f" | tail -1)
    paragraphs=$(grep -cE "^[^[:space:]#]" "$f" 2>/dev/null)
    # 句号数
    sentences=$(grep -oE "。" "$f" 2>/dev/null | wc -l)
    # 比值
    if [ "$sentences" -gt 0 ]; then
        ratio=$(awk "BEGIN {printf \"%.2f\", $paragraphs/$sentences}")
        echo "  $f: 段落 $paragraphs / 句号 $sentences = $ratio"
        # 警戒线：比值 > 0.5 即段落过碎
        warn=$(awk "BEGIN {print ($ratio > 0.5)}")
        if [ "$warn" = "1" ]; then
            print_warn "  $f 段落:句号比偏高，可能存在逐句分段"
        fi
    fi
done

# ========== 8. 大词扫描 ==========
print_header "8. 大词与固定句式扫描"

BIG_WORDS="真正|关键|核心|本质|结构上|从根本上|归根到底|本质上|这意味着|由此可见"
echo "大词："
matches=$(grep -nE "$BIG_WORDS" $DRAFTS 2>/dev/null | head -15)
if [ -n "$matches" ]; then
    echo "$matches" | sed 's/^/  /'
fi

FIXED_PATTERNS="不是.*而是|不只是.*更是|一方面.*另一方面|既.*又.*更|从.*到.*再到"
echo ""
echo "固定句式："
matches=$(grep -nE "$FIXED_PATTERNS" $DRAFTS 2>/dev/null | head -15)
if [ -n "$matches" ]; then
    echo "$matches" | sed 's/^/  /'
fi

print_header "扫描完成"
echo "提示："
echo "  - 警告项需人工核查上下文，不是所有匹配都是问题"
echo "  - 视角越界、铁律违反如确认，参照 references/pov-modes.md 和 CONTEXT.md 中的视角模式修订"
echo "  - 段落:句号比偏高的，参照 references/anti-ai-checklist.md 第1节修订"
echo "  - 跨篇冲突的修复格式参照 修订记录.md"
