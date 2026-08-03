#!/usr/bin/env bash

# 安全地将当前分支更新到远端最新版本。
set -Eeuo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly REMOTE="${GIT_REMOTE:-origin}"

die() {
  printf '错误：%s\n' "$*" >&2
  exit 1
}

command -v git >/dev/null 2>&1 || die "未找到 git 命令"
git -C "$SCRIPT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || die "$SCRIPT_DIR 不是 Git 仓库"

branch="$(git -C "$SCRIPT_DIR" symbolic-ref --quiet --short HEAD)" \
  || die "当前处于 detached HEAD 状态，请先切换到一个分支"

git -C "$SCRIPT_DIR" remote get-url "$REMOTE" >/dev/null 2>&1 \
  || die "远端 '$REMOTE' 不存在（可通过 GIT_REMOTE 指定远端）"

printf '正在从 %s 更新分支 %s...\n' "$REMOTE" "$branch"
git -C "$SCRIPT_DIR" fetch --prune "$REMOTE"

# 只允许快进，避免更新脚本自动创建合并提交或改写本地提交。
if git -C "$SCRIPT_DIR" merge --ff-only "$REMOTE/$branch"; then
  printf '更新完成。\n'
  git -C "$SCRIPT_DIR" status --short --branch
else
  printf '\n更新失败：本地与 %s/%s 可能已经分叉，或工作区修改阻止了更新。\n' \
    "$REMOTE" "$branch" >&2
  printf '请运行 git status 检查后手动处理；脚本未自动 stash 或改写提交。\n' >&2
  exit 1
fi
