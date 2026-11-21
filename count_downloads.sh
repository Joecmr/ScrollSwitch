#!/bin/bash
# ============================================================
#  ScrollSwitch 全渠道累计下载统计（零预算版）
#  真值 = GitHub Releases 下载数 + 国内镜像下载数
#
#  用法：
#    ./count_downloads.sh                 # 只查 GitHub，并读取本地镜像计数
#    ./count_downloads.sh joe             # 指定 GitHub owner
#    ./count_downloads.sh joe 200         # 指定 owner 与镜像下载数
#
#  镜像下载数来自托管后台（Gitee / GitHub 镜像站 / 网盘）的手动计数，
#  由运营每周填一次 count_mirror.txt（一行一个整数），脚本自动读取。
# ============================================================

set -u
OWNER="${1:-JoeCmr}"
MIRROR_ARG="${2:-}"
REPO="ScrollSwitch"
MIRROR_FILE="$(cd "$(dirname "$0")" && pwd)/count_mirror.txt"

GH_COUNT=0

if [ "$OWNER" = "JoeCmr" ]; then
    echo "⚠ GitHub owner 未确认，用法：./count_downloads.sh <owner>"
else
    API="https://api.github.com/repos/${OWNER}/${REPO}/releases"
    RAW="$(curl -sL --max-time 15 "$API" 2>/dev/null || true)"
    if [ -z "$RAW" ]; then
        echo "✗ GitHub API 请求失败（网络不通或仓库不存在）"
    else
        GH_COUNT="$(printf '%s' "$RAW" \
          | grep -o '"download_count": *[0-9]*' \
          | grep -o '[0-9]*' \
          | awk '{s+=$1} END {print s+0}')"
        echo "GitHub Releases 下载数: ${GH_COUNT}"
    fi
fi

if [ -n "$MIRROR_ARG" ]; then
    MIRROR_COUNT="$MIRROR_ARG"
elif [ -f "$MIRROR_FILE" ]; then
    MIRROR_COUNT="$(tr -dc '0-9' < "$MIRROR_FILE" | head -c 12)"
    [ -z "$MIRROR_COUNT" ] && MIRROR_COUNT=0
else
    MIRROR_COUNT=0
    echo "! 未找到 ${MIRROR_FILE}，镜像数按 0 计"
fi
echo "国内镜像下载数: ${MIRROR_COUNT}"

TOTAL=$((GH_COUNT + MIRROR_COUNT))
echo "────────────────────────"
echo "全渠道累计下载: ${TOTAL} / 2500（$(awk -v t="$TOTAL" 'BEGIN{printf "%.1f", t/2500*100}')%）"

# 追加一行到历史表，方便画图
LOG="$(dirname "$0")/count_history.csv"
if [ ! -f "$LOG" ]; then
    echo "date,github,mirror,total" > "$LOG"
fi
echo "$(date '+%Y-%m-%d'),${GH_COUNT},${MIRROR_COUNT},${TOTAL}" >> "$LOG"
echo "已追加到 $(basename "$LOG")"
