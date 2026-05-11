# my-chaudeCode-plugins

Claude Code 配置与插件集合。

---

## 安装

```bash
git clone https://github.com/chowaa/my-chaudeCode-plugins.git
```

所有 hook 脚本在 `hooks/` 目录下，复制到 `~/.claude/hooks/` 并配置 `~/.claude/settings.json` 即可使用。

---

## Hook 1：Status Line Token（状态栏 Token 用量）

在 Claude Code 底部状态栏显示模型名、本轮输出 token、累计总量、上下文占比。

效果：`deepseek-v4-pro  本轮:1.2k  总:45.3k  ctx:23%`

### macOS / Linux

```bash
# 1. 复制脚本
cp hooks/status-line-token.sh ~/.claude/hooks/status-line-token.sh
chmod +x ~/.claude/hooks/status-line-token.sh
```

### Windows (PowerShell)

```powershell
# 1. 复制脚本
Copy-Item hooks\status-line-token.sh $env:USERPROFILE\.claude\hooks\status-line-token.sh
```

### 配置 settings.json

在 `~/.claude/settings.json` 中添加：

```json
"statusLine": {
  "type": "command",
  "command": "bash ~/.claude/hooks/status-line-token.sh"
}
```

> 如 settings.json 不存在则新建，内容为 `{ "statusLine": { ... } }`。

---

## Hook 2：Stop Hook（交付验收检查）

Claude 结束回复前自动检查：如果本轮改了代码但未完成验证，阻止结束并强制 Claude 继续工作。

### macOS / Linux

```bash
# 1. 复制脚本
cp hooks/stop-check.sh ~/.claude/hooks/stop-check.sh
chmod +x ~/.claude/hooks/stop-check.sh
```

### Windows (PowerShell)

```powershell
# 1. 复制脚本
Copy-Item hooks\stop-check.sh $env:USERPROFILE\.claude\hooks\stop-check.sh
```

### 配置 settings.json

在 `~/.claude/settings.json` 的 `"hooks"` 中添加：

```json
"Stop": [
  {
    "hooks": [
      {
        "type": "command",
        "command": "bash ~/.claude/hooks/stop-check.sh",
        "statusMessage": "🔍 交付验收检查中...",
        "asyncRewake": true,
        "rewakeMessage": "[Stop Hook] 你本轮改了代码但未完成验证。请运行测试/lint/typecheck/功能验证/TODO检查中的至少一项，在回复中说明验证结果，然后执行: touch ~/.claude/verification-done",
        "rewakeSummary": "🛑 验收未通过，继续工作"
      }
    ]
  }
]
```

### 配置项目 CLAUDE.md（可选）

在项目根目录的 `CLAUDE.md` 中添加，Claude 每轮会参考这些规则：

```markdown
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
```

---

## 验证安装

在 Claude Code 中输入 `/hooks`，看到对应 hook 即为安装成功。

---

## 文件

| 文件 | 说明 |
|------|------|
| `hooks/status-line-token.sh` | Status Line hook 脚本 |
| `hooks/stop-check.sh` | Stop hook 脚本 |
