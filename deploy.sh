#!/usr/bin/env bash
# ============================================================
#  游戏部署脚本 —— 把 site/ 目录推送到 GitHub Pages
#  适用：Windows 用户请用「Git Bash」运行（不要用 cmd/PowerShell）
#  用法：cd 到本文件所在目录后运行  bash deploy.sh
# ============================================================
set -e

echo "========================================="
echo "  游戏部署到 GitHub Pages"
echo "========================================="

# ---------- 方式一：预设仓库地址（不想每次粘贴就填这里）----------
# 例：REPO_URL="https://github.com/你的用户名/你的仓库名.git"
#     REPO_URL="git@github.com:你的用户名/你的仓库名.git"
REPO_URL=""

# 没预设就运行时手动粘贴
if [ -z "$REPO_URL" ]; then
  read -p "粘贴你的 GitHub 仓库地址 (HTTPS 或 SSH): " REPO_URL
fi
if [ -z "$REPO_URL" ]; then
  echo "没给仓库地址，已退出。"
  exit 1
fi

# 进入脚本所在目录（site/），只推送部署包，不碰项目里的临时文件
cd "$(dirname "$0")"

# 初始化仓库（已有则忽略报错）
git init 2>/dev/null || true
git branch -M main 2>/dev/null || true

# 设置远程（重复运行也不报错）
git remote remove origin 2>/dev/null || true
git remote add origin "$REPO_URL"

# 提交全部部署文件
git add -A
git commit -m "deploy: $(date +%Y-%m-%d_%H%M%S)" || { echo "没有需要提交的改动，跳过。"; }

# 推送
git push -u origin main

echo ""
echo "✅ 推送完成！"
echo "下一步：GitHub 仓库 → Settings → Pages → Source 选 'main' 分支 / root 目录 → Save"
echo "等 1~2 分钟后访问：https://你的用户名.github.io/你的仓库名/"
