#!/bin/bash
set -e

REPO_URL="https://gitcode.com/cann/shmem.git"

TEMP_REPO_DIR="shmem_temp"

GEN_DOC_DIR="docs/master/guide/html"

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)

echo "===== 开始克隆文档仓库 ====="
if [ -d "$TEMP_REPO_DIR" ]; then
    rm -rf "$TEMP_REPO_DIR"
fi
git clone "$REPO_URL" "$TEMP_REPO_DIR"

echo -e "\n===== 开始构建文档 ====="
cd "$TEMP_REPO_DIR"
bash scripts/build.sh -onlygendoc

# 检查文档是否生成成功
DOC_FULL_PATH="$PWD/$GEN_DOC_DIR"
if [ ! -d "$DOC_FULL_PATH" ]; then
    echo "错误：文档生成失败！未找到目录: $DOC_FULL_PATH"
    # 清理临时文件
    cd "$PROJECT_ROOT"
    rm -rf "$TEMP_REPO_DIR"
    exit 1
fi

echo -e "\n===== 开始替换文档到项目 ====="
# 回到项目根目录
cd "$PROJECT_ROOT"
# 批量复制文档（覆盖重名文件，递归复制目录）
cp -rf "$DOC_FULL_PATH"/* ./

echo -e "\n===== 清理临时文件 ====="
rm -rf "$TEMP_REPO_DIR"

echo -e "\n===== 开始提交并推送代码 ====="
# 检查是否有文件变更
if [ -n "$(git status --porcelain)" ]; then
    git add .
    git commit -m "update"
    git push
    echo "✅ 文档更新并推送成功！"
else
    echo "ℹ️  没有文档变更，无需提交推送！"
fi