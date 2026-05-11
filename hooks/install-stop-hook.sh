#!/usr/bin/env bash
# 一键安装 Stop Hook（交付验收检查）到任意主机
# 用法: bash hooks/install-stop-hook.sh [项目目录]
#       从仓库根目录执行，项目目录可选，默认当前目录

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOK_DIR="$HOME/.claude/hooks"
SETTINGS="$HOME/.claude/settings.json"
PROJECT_DIR="${1:-$(pwd)}"

echo "==> 安装 Claude Code Stop Hook（交付验收检查）"

# 1. 复制 hook 脚本
mkdir -p "$HOOK_DIR"
cp "$SCRIPT_DIR/stop-check.sh" "$HOOK_DIR/stop-check.sh"
chmod +x "$HOOK_DIR/stop-check.sh"
echo "   ✓ $HOOK_DIR/stop-check.sh"

# 2. 合并 Stop hook 配置到 settings.json
STOP_CONFIG=$(cat << 'JSON_EOF'
{
  "type": "command",
  "command": "bash REPLACE_HOME/.claude/hooks/stop-check.sh",
  "statusMessage": "🔍 交付验收检查中...",
  "asyncRewake": true,
  "rewakeMessage": "[Stop Hook] 你本轮改了代码但未完成验证。请运行测试/lint/typecheck/功能验证/TODO检查中的至少一项，在回复中说明验证结果，然后执行: touch ~/.claude/verification-done",
  "rewakeSummary": "🛑 验收未通过，继续工作"
}
JSON_EOF
)
STOP_CONFIG=$(echo "$STOP_CONFIG" | sed "s|REPLACE_HOME|$HOME|g")

if [ -f "$SETTINGS" ]; then
  if command -v jq &>/dev/null; then
    jq --argjson sc "$STOP_CONFIG" '
      .hooks.Stop = [{"hooks": [$sc]}]
    ' "$SETTINGS" > "$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
    echo "   ✓ 已合并 Stop hook 到 $SETTINGS"
  else
    echo "   ⚠ jq 未安装，无法自动合并 settings.json"
    echo "   请手动将以下配置添加到 $SETTINGS 的 hooks 字段中:"
    echo ""
    echo '   "Stop": [{"hooks": [' "$STOP_CONFIG" ']}]'
  fi
else
  cat > "$SETTINGS" << JSON_EOF
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          $STOP_CONFIG
        ]
      }
    ]
  }
}
JSON_EOF
  echo "   ✓ 已创建 $SETTINGS"
fi

# 3. 写入 CLAUDE.md（仅当项目目录不是 .claude）
if [ "$PROJECT_DIR" != "$HOME/.claude" ] && [ "$PROJECT_DIR" != "$HOME/.claude/" ]; then
  if [ -f "$PROJECT_DIR/CLAUDE.md" ]; then
    echo "   ⚠ $PROJECT_DIR/CLAUDE.md 已存在，跳过写入"
    echo ""
    echo "   请手动将以下内容添加到 CLAUDE.md:"
    echo "   ----------------------------------------"
    cat << 'MD_EOF'
## Stop Hook：交付验收

本项目配置了 Stop hook（`~/.claude/hooks/stop-check.sh`），在 Claude 结束前自动检查是否有未验证的代码改动。

### 规则
- 如果本轮**改了代码/配置/文档**（非 `.claude/` 目录下），必须完成至少一项验证（测试/lint/typecheck/功能验证/TODO检查）
- 验证完成后执行 `touch ~/.claude/verification-done` 创建标记文件
- 无改动时直接说明"本轮无改动"即可结束

### 每轮结束前
在回复末尾报告验收状态，例如：
- `✅ 本轮无代码改动。`
- `✅ 已运行 lint 通过，标记已创建。`
MD_EOF
    echo "   ----------------------------------------"
  else
    cat > "$PROJECT_DIR/CLAUDE.md" << 'MD_EOF'
# CLAUDE.md

## Stop Hook：交付验收

本项目配置了 Stop hook（`~/.claude/hooks/stop-check.sh`），在 Claude 结束前自动检查是否有未验证的代码改动。

### 规则
- 如果本轮**改了代码/配置/文档**（非 `.claude/` 目录下），必须完成至少一项验证（测试/lint/typecheck/功能验证/TODO检查）
- 验证完成后执行 `touch ~/.claude/verification-done` 创建标记文件
- 无改动时直接说明"本轮无改动"即可结束

### 每轮结束前
在回复末尾报告验收状态，例如：
- `✅ 本轮无代码改动。`
- `✅ 已运行 lint 通过，标记已创建。`
MD_EOF
    echo "   ✓ $PROJECT_DIR/CLAUDE.md"
  fi
fi

echo ""
echo "==> 安装完成！"
echo "    验证: 在 Claude Code 中输入 /hooks 查看 Stop hook 状态"
