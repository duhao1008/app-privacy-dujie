#!/usr/bin/env bash

# 暂存全部改动、提交并推送当前分支。
set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly REMOTE="${GIT_REMOTE:-origin}"

die() {
  printf '错误：%s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
用法：
  ./git-push.sh [提交说明]

示例：
  ./git-push.sh "更新应用隐私配置"

未提供提交说明时，将使用带当前时间的默认说明。
可通过环境变量 GIT_REMOTE 指定远端，默认值为 origin。
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

command -v git >/dev/null 2>&1 || die "未找到 git 命令"
git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || die "$SCRIPT_DIR 不是 Git 仓库"

branch="$(git -C "$SCRIPT_DIR" symbolic-ref --quiet --short HEAD)" \
  || die "当前处于 detached HEAD 状态，请先切换到一个分支"

git -C "$SCRIPT_DIR" remote get-url "$REMOTE" >/dev/null 2>&1 \
  || die "远端 '$REMOTE' 不存在（可通过 GIT_REMOTE 指定远端）"

if (( $# > 0 )); then
  commit_message="$*"
else
  commit_message="更新应用隐私配置 $(date '+%Y-%m-%d %H:%M:%S')"
fi

printf '正在暂存全部改动...\n'
git -C "$SCRIPT_DIR" add --all

if git -C "$SCRIPT_DIR" diff --cached --quiet; then
  printf '没有需要提交的改动，将检查是否有尚未推送的提交。\n'
else
  printf '正在提交：%s\n' "$commit_message"
  git -C "$SCRIPT_DIR" commit -m "$commit_message"
fi

if git -C "$SCRIPT_DIR" rev-parse --verify HEAD >/dev/null 2>&1; then
  if git -C "$SCRIPT_DIR" rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
    printf '正在推送分支 %s...\n' "$branch"
    git -C "$SCRIPT_DIR" push
  else
    printf '正在推送分支 %s，并设置上游为 %s/%s...\n' "$branch" "$REMOTE" "$branch"
    git -C "$SCRIPT_DIR" push --set-upstream "$REMOTE" "$branch"
  fi
else
  die "仓库还没有提交，无法推送"
fi

printf '推送完成。\n'
git -C "$SCRIPT_DIR" status --short --branch
