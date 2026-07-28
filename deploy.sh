#!/usr/bin/env bash
# ============================================================
#  自动部署到 GitHub Pages — https://hanekiba.github.io/tap-hero/
#  用法：在 Git Bash 中运行  bash site/deploy.sh
#  无需任何交互，一键推送。
# ============================================================
set -e

REPO_URL="https://github.com/Hanekiba/tap-hero.git"
BRANCH="main"

# 进入 site/ 目录（无论从哪个目录运行此脚本都能正确工作）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

echo "🚀 部署 tap-hero → GitHub Pages"
echo "   仓库：${REPO_URL}"
echo "   分支：${BRANCH}"
echo ""

# 确保是 git 仓库（首次运行或 .git 被误删时自动初始化）
if [ ! -d .git ]; then
  echo "📦 初始化 git 仓库…"
  git init
  git branch -M "$BRANCH"
  git remote add origin "$REPO_URL"
fi

# 尝试拉取远程（首次推送时远程分支可能还不存在，忽略错误）
echo "📥 同步远程…"
if git ls-remote origin "$BRANCH" | grep -q "$BRANCH"; then
  # 远程分支存在：拉取后做 soft reset，保留本地改动
  git fetch origin "$BRANCH" 2>/dev/null || {
    echo "⚠️ 无法连接远程仓库（请确认已配置 GitHub 凭据）"
    exit 1
  }
  git reset --soft "origin/$BRANCH" 2>/dev/null || true
else
  echo "   远程分支尚不存在，将创建首次提交。"
fi

# 暂存所有部署文件
git add -A

# 如果没有改动就跳过
COMMIT_MSG="deploy: $(date '+%Y-%m-%d %H:%M:%S')"
if git diff --cached --quiet 2>/dev/null; then
  echo "✅ 没有新改动，已是最新。"
  exit 0
fi

git commit -m "$COMMIT_MSG"
echo "📤 推送到 GitHub…"
git push -u origin "$BRANCH"

echo ""
echo "🎉 推送完成！等 1~2 分钟后访问："
echo "   https://hanekiba.github.io/tap-hero/"
echo ""
echo "💡 如果没有自动生效，检查 GitHub 仓库 Settings → Pages："
echo "   Source 选 'Deploy from a branch' → main 分支 / root 目录"
