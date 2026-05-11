#!/usr/bin/env bash
# Stop hook: 交付验收检查
# 规则：本轮有代码/配置/文档改动 → 必须有验证标记 → 否则阻止结束
# exit 0 = 通过，exit 2 = 阻止，触发 rewake

set -euo pipefail

MARKER="$HOME/.claude/verification-done"

# .claude 配置目录直接放行
case "$(pwd)" in
  "$HOME/.claude"|"$HOME/.claude/"*) exit 0 ;;
esac

CHANGED=0

if git rev-parse --git-dir >/dev/null 2>&1; then
  ALL=$( {
    git diff --cached --name-only 2>/dev/null || true
    git diff --name-only 2>/dev/null || true
    git ls-files --others --exclude-standard 2>/dev/null || true
  } | grep -iE '\.(py|js|ts|tsx|jsx|go|rs|java|rb|php|c|h|cpp|hpp|yaml|yml|json|toml|cfg|ini|md|rst|sql|sh|bash|css|scss|less|html|vue|svelte)$' | grep -vE '(^|/)\.(claude|git)/' | head -1)
  [ -n "$ALL" ] && CHANGED=1
else
  RECENT=$(find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.yaml" -o -name "*.yml" -o -name "*.json" -o -name "*.md" -o -name "*.sql" -o -name "*.sh" -o -name "*.css" -o -name "*.html" \) -mmin -60 2>/dev/null | grep -vE '(^|/)\.(claude|git)/' | head -1)
  [ -n "$RECENT" ] && CHANGED=1
fi

if [ "$CHANGED" -eq 0 ]; then
  echo "✅ [Stop Hook] 本轮无代码改动，验收通过。"
  exit 0
fi

if [ -f "$MARKER" ]; then
  echo "✅ [Stop Hook] 验证标记存在，验收通过。"
  exit 0
fi

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║  🛑 交付验收未通过 — 禁止结束               ║"
echo "╠══════════════════════════════════════════════╣"
echo "║                                              ║"
echo "║  本轮改动需完成至少一项验证:                 ║"
echo "║    1. 运行测试                               ║"
echo "║    2. 运行 lint / 格式检查                   ║"
echo "║    3. 类型检查 (typecheck)                   ║"
echo "║    4. 功能验证 (手动测试)                    ║"
echo "║    5. TODO/FIXME 检查                        ║"
echo "║                                              ║"
echo "║  验证完毕后在回复中说明结果，并执行:         ║"
echo "║    touch ~/.claude/verification-done         ║"
echo "║                                              ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

exit 2
