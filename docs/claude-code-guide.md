# Claude Code 指令使用指南

## 目录

- [快速开始](#快速开始)
- [Slash 命令](#slash-命令)
- [CLI 命令行参数](#cli-命令行参数)
- [键盘快捷键](#键盘快捷键)
- [Hook 钩子系统](#hook-钩子系统)
- [Skills 技能系统](#skills-技能系统)
- [配置文件](#配置文件)
- [环境变量](#环境变量)
- [权限系统](#权限系统)
- [常用工作流](#常用工作流)

---

## 快速开始

```bash
# 启动 Claude Code
claude

# 启动并直接提问
claude "帮我重构这个函数"

# 从 stdin 读取指令
echo "审查 src/ 目录的代码" | claude -p

# 继续上一次对话
claude --continue
```

---

## Slash 命令

在对话中直接输入以下命令（以 `/` 开头）：

### 基础命令

| 命令 | 说明 |
|------|------|
| `/help` | 显示帮助信息和可用命令列表 |
| `/clear` | 清空当前对话，开启新一轮对话 |
| `/compact` | 压缩对话上下文，腾出空间，保留关键信息 |
| `/doctor` | 运行系统诊断，检查环境配置 |
| `/status` | 显示当前会话状态（模型、成本、token 等） |
| `/cost` | 显示当前会话的 token 用量和费用明细 |
| `/upgrade` | 升级 Claude Code 到最新版本 |
| `/login` | 登录 Anthropic 账号 |
| `/logout` | 退出登录 |

### 配置命令

| 命令 | 说明 |
|------|------|
| `/config` | 交互式配置 Claude Code 设置 |
| `/model` | 切换当前使用的模型 |
| `/output-style` | 设置输出风格（default / explanatory / concise） |
| `/permissions` | 管理工具的权限设置 |
| `/terminal-setup` | 配置终端集成 |

### 高级命令

| 命令 | 说明 |
|------|------|
| `/hooks` | 查看当前项目的 Hook 状态 |
| `/init` | 为当前项目初始化 CLAUDE.md |
| `/agents` | 管理后台和已配置的 Agent |
| `/mcp` | 管理 MCP 服务器 |
| `/plugin` | 管理插件（安装/卸载/启用/禁用） |
| `/memory` | 管理持久化记忆 |
| `/add-dir` | 添加允许访问的工作目录 |
| `/ide` | 连接/断开 IDE 集成 |
| `/resume` | 打开会话恢复选择器 |
| `/bashes` | 查看后台 Bash 任务状态 |

### CLI 子命令

除了在对话中的 slash 命令，还可以在终端直接使用 `claude <command>`：

| 命令 | 说明 |
|------|------|
| `claude agents` | 管理 Agent |
| `claude auth` | 管理身份认证 |
| `claude doctor` | 系统健康检查 |
| `claude install [target]` | 安装指定版本（stable / latest / 版本号） |
| `claude mcp` | 配置 MCP 服务器 |
| `claude plugin` | 管理插件 |
| `claude project` | 管理项目状态 |
| `claude update` | 检查并安装更新 |
| `claude ultrareview [target]` | 云端多 Agent 代码审查 |

### 自定义 Slash 命令（Skills）

用户和插件可以注册自定义 `/` 命令，参见 [Skills 技能系统](#skills-技能系统)。

---

## CLI 命令行参数

```bash
claude [选项] [提示词]
```

### 常用参数

| 参数 | 说明 | 示例 |
|------|------|------|
| `--model <model>` | 指定模型 | `claude --model opus` |
| `--continue` / `-c` | 从上次中断处继续 | `claude -c` |
| `--resume [session-id]` | 恢复指定会话或打开选择器 | `claude --resume abc123` |
| `--from-pr [pr]` | 恢复关联 PR 的会话 | `claude --from-pr 42` |
| `--fork-session` | 恢复时创建新会话 ID | `claude -c --fork-session` |
| `--name <name>` | 设置会话显示名称 | `claude --name "调试任务"` |
| `--file <path>` | 下载文件资源 | `claude --file file_id:path` |
| `--print` / `-p` | 非交互模式，直接输出结果 | `claude -p "解释这段代码"` |
| `--verbose` | 显示详细输出 | `claude --verbose` |
| `--debug [filter]` | 启用调试日志 | `claude -d "api,hooks"` |
| `--version` / `-v` | 显示版本号 | `claude --version` |
| `--help` / `-h` | 显示帮助 | `claude --help` |

### 权限和工具控制

| 参数 | 说明 |
|------|------|
| `--permission-mode <mode>` | 权限模式：`default` / `acceptEdits` / `bypassPermissions` / `plan` / `dontAsk` |
| `--allowedTools <tools>` | 允许的工具，逗号或空格分隔 |
| `--disallowedTools <tools>` | 禁止的工具 |
| `--tools <tools>` | 指定工具集：`"default"`（全部）或 `""`（无）或具体工具名 |
| `--add-dir <dirs>` | 添加允许访问的目录 |
| `--allow-dangerously-skip-permissions` | 启用权限跳过选项（不默认开启） |
| `--dangerously-skip-permissions` | 跳过所有权限检查（仅限沙箱环境） |

### 会话和输出控制

| 参数 | 说明 |
|------|------|
| `--session-id <uuid>` | 使用指定的会话 UUID |
| `--no-session-persistence` | 不保存会话到磁盘（仅 `--print` 模式） |
| `--output-format <fmt>` | 输出格式：`text` / `json` / `stream-json` |
| `--input-format <fmt>` | 输入格式：`text` / `stream-json` |
| `--json-schema <schema>` | 结构化输出的 JSON Schema |
| `--include-partial-messages` | 流式输出时包含部分消息块 |
| `--max-budget-usd <amount>` | API 花费上限（仅 `--print` 模式） |

### 模型和 Agent

| 参数 | 说明 |
|------|------|
| `--agent <agent>` | 指定 Agent |
| `--agents <json>` | JSON 定义自定义 Agent |
| `--effort <level>` | 努力程度：`low` / `medium` / `high` / `xhigh` / `max` |
| `--fallback-model <model>` | 默认模型过载时自动降级到此模型 |

### 上下文和配置

| 参数 | 说明 |
|------|------|
| `--system-prompt <text>` | 自定义 system prompt |
| `--append-system-prompt <text>` | 追加到默认 system prompt |
| `--settings <file-or-json>` | 指定 settings 文件或 JSON 字符串 |
| `--setting-sources <sources>` | 配置来源：`user` / `project` / `local`（逗号分隔） |
| `--betas <betas>` | API 请求的 Beta header |

### MCP 和插件

| 参数 | 说明 |
|------|------|
| `--mcp-config <configs>` | 从 JSON 文件或字符串加载 MCP 服务器 |
| `--strict-mcp-config` | 仅使用 `--mcp-config` 指定的 MCP，忽略其他来源 |
| `--plugin-dir <path>` | 从目录加载插件（可重复） |
| `--plugin-url <url>` | 从 URL 下载插件 .zip（可重复） |
| `--disable-slash-commands` | 禁用所有 skills |

### 工作树和远程

| 参数 | 说明 |
|------|------|
| `--worktree` / `-w [name]` | 创建 git worktree 并在此会话中使用 |
| `--tmux` | 配合 `--worktree` 创建 tmux 会话 |
| `--remote-control [name]` | 启用 Remote Control 的交互会话 |
| `--ide` | 可用时自动连接 IDE |
| `--bare` | 最小模式：跳过 hooks/LSP/插件同步等 |

### 管道模式

```bash
# 管道输入 + 非交互输出
echo "列出所有 JS 文件" | claude -p

# Git diff 审阅
git diff HEAD~3 | claude -p "审阅这些代码变更"

# 管道输入 + 继续编辑
git log -5 | claude "理解这些 commit，然后生成 CHANGELOG"
```

---

## 键盘快捷键

### 输入编辑

| 快捷键 | 说明 |
|--------|------|
| `Enter` | 发送消息 |
| `Shift + Enter` | 换行 |
| `Esc` | 清空输入框 / 拒绝编辑 / 关闭弹窗 |
| `Ctrl + C` | 取消当前操作 / 中断 Claude |
| `Ctrl + D` | 退出 Claude Code（空行时发送 EOF） |
| `Ctrl + L` | 清屏 |
| `Ctrl + O` | 切换详细输出（显示/隐藏工具返回内容） |
| `Ctrl + R` | 搜索历史命令 |
| `Ctrl + A` | 光标移到行首 |
| `Ctrl + E` | 光标移到行尾 |
| `Ctrl + K` | 剪切光标到行尾的内容 |
| `Ctrl + U` | 剪切光标到行首的内容 |
| `Ctrl + W` | 删除前一个词 |

### 权限模式快捷键

当弹出权限确认时：

| 快捷键 | 说明 |
|--------|------|
| `y` / `Enter` | 允许本次操作 |
| `n` | 拒绝本次操作 |
| `a` | 本次对话始终允许 |
| `Ctrl + C` | 取消 |

### 其他

| 快捷键 | 说明 |
|--------|------|
| `Up / Down` | 浏览历史消息 |
| `Tab` | 自动补全文件路径 |

---

## Hook 钩子系统

Hook 是 Claude Code 的事件驱动扩展机制，允许在特定时机执行自定义脚本。

### Hook 事件类型

| Hook | 触发时机 | 典型用途 |
|------|----------|----------|
| `SessionStart` | 会话启动时 | 初始化环境、加载配置、显示欢迎信息 |
| `PreToolUse` | 工具执行前 | 校验参数、日志记录、阻止危险操作 |
| `PostToolUse` | 工具执行后 | 结果校验、自动 lint、发送通知 |
| `Stop` | Claude 即将结束回复时 | 验证交付物、阻止过早结束 |
| `PreCompact` | 上下文压缩前 | 备份完整对话、自定义压缩逻辑 |
| `Notification` | 特定事件发生时 | 桌面通知、Slack 通知 |
| `SessionEnd` | 会话结束时 | 清理、日志、总结生成 |

### Hook 配置方式

在项目或全局 `settings.json` 中配置：

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/stop-check.sh",
            "statusMessage": "正在验证交付物...",
            "asyncRewake": true,
            "rewakeMessage": "发现未验证的改动，继续工作..."
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "node validate-tool-use.js",
            "matcher": "Write|Edit"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python lint-check.py",
            "matcher": "Write|Edit"
          }
        ]
      }
    ]
  }
}
```

### Hook 配置参数

| 参数 | 说明 |
|------|------|
| `type` | 类型：`"command"`（目前仅支持命令） |
| `command` | 要执行的 shell 命令 |
| `matcher` | 匹配工具名的正则，空字符串匹配所有 |
| `statusMessage` | Hook 运行时显示的状态消息 |
| `asyncRewake` | 是否异步重新唤醒 Claude |
| `rewakeMessage` | 重新唤醒时显示给 Claude 的消息 |
| `rewakeSummary` | 重新唤醒事件的摘要文本 |

### 注意事项

- Hook 脚本返回非零退出码可阻止原操作（对 `Stop` / `PreToolUse` 有效）
- `matcher` 支持正则，空字符串表示匹配所有
- Hook 脚本会收到 JSON 格式的事件数据作为参数
- 安装在 `~/.claude/hooks/` 下可跨项目复用
- 安装在 `{project}/.claude/hooks/` 下仅对当前项目生效
- 超时时间默认 60 秒，可在 settings.json 中配置 `hookTimeout`

---

## Skills 技能系统

Skills 是在对话中可通过 `/name` 调用的自定义功能模块。

### 内置 Skills

Claude Code 内置了多个 skills，可以直接使用。输入 `/` 即可查看当前可用的所有 skills 列表。

### 创建自定义 Skill

在项目的 `.claude/skills/` 目录下创建 Markdown 文件：

```markdown
# .claude/skills/lint.md

当用户调用 /lint 时，使用 ESLint 检查所有改动的 JS/TS 文件，
修复发现的问题，然后重新检查确保通过。
```

### Skill 调用方式

```bash
# 调用技能
/lint

# 带参数的技能
/review PR-URL
```

---

## 配置文件

### CLAUDE.md

项目根目录下的 `CLAUDE.md` 是项目级指令文件，Claude 每次对话都会读取。

- 支持 `@/path/to/file.md` 语法引用其他 Markdown 文件
- 可以包含项目约定、编码规范、常用命令、架构说明等
- 内容自动注入到 system prompt 中

```markdown
# CLAUDE.md

## 项目简介
这是一个 React + TypeScript 前端项目。

## 编码规范
- 使用 2 空格缩进
- 函数命名用 camelCase
- 组件命名用 PascalCase

## 常用命令
- 测试：npm test
- 构建：npm run build
- Lint：npm run lint

## 注意事项
- 不要修改 src/api/ 下的自动生成文件
- 数据库迁移需要手动执行

## 引用其他文件
@/docs/architecture.md
@/docs/api-conventions.md
```

### settings.json

配置文件层级（优先级从高到低）：
1. **项目本地** — `{project}/.claude/settings.local.json`（不提交 git）
2. **项目共享** — `{project}/.claude/settings.json`（可提交 git）
3. **用户全局** — `~/.claude/settings.json`

```json
{
  "model": "sonnet",
  "theme": "dark",
  "autoCompact": true,
  "permissions": {
    "allow": [
      "Bash(npm test)",
      "Bash(npm run lint)",
      "Read",
      "Grep",
      "Glob"
    ]
  },
  "env": {
    "NODE_ENV": "development"
  },
  "hooks": { },
  "enableAllProjectMcpServers": false
}
```

### 常用配置项

| 配置项 | 说明 | 示例值 |
|--------|------|--------|
| `model` | 默认模型 | `"sonnet"` / `"opus"` / `"haiku"` |
| `agent` | 默认 Agent | `"general-purpose"` |
| `theme` | 主题 | `"dark"` / `"light"` |
| `autoCompact` | 自动压缩上下文 | `true` / `false` |
| `outputStyle` | 输出风格 | `"default"` / `"explanatory"` / `"concise"` |
| `verbose` | 默认启用详细模式 | `true` / `false` |
| `alwaysThinkingEnabled` | 始终启用深度思考 | `true` / `false` |
| `permissions.allow` | 白名单权限 | 工具正则列表 |
| `permissions.deny` | 黑名单权限 | 工具正则列表 |
| `permissions.defaultMode` | 默认权限模式 | `"acceptEdits"` |
| `env` | 环境变量 | `{"KEY": "value"}` |
| `hooks` | Hook 配置 | 见 Hook 章节 |
| `hookTimeout` | Hook 超时（毫秒） | `60000` |
| `enableAllProjectMcpServers` | 自动启用项目 MCP | `true` / `false` |
| `enabledPlugins` | 启用的插件 | `{"plugin-name": true}` |
| `statusLine` | 自定义状态栏 | `{"type": "command", "command": "bash script.sh"}` |
| `includeCoAuthoredBy` | 在 commit 中包含 Co-authored-by | `true` / `false` |
| `settingSources` | 配置来源及优先级 | `"user,project,local"` |

---

## 环境变量

| 变量 | 说明 |
|------|------|
| `ANTHROPIC_API_KEY` | Anthropic API 密钥 |
| `ANTHROPIC_BASE_URL` | 自定义 API 基础 URL（代理/第三方 provider） |
| `ANTHROPIC_AUTH_TOKEN` | 认证 Token（配合自定义 BASE_URL 使用） |
| `ANTHROPIC_MODEL` | 默认模型 |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | 默认 Haiku 模型 |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | 默认 Sonnet 模型 |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | 默认 Opus 模型 |
| `CLAUDE_CODE_SIMPLE` | 设为 `1` 启用最小模式 |
| `NO_COLOR` | 禁用彩色输出 |
| `CLAUDE_CODE_API_KEY_HELPER` | 指定一个脚本来动态获取 API Key |
| `DEBUG` | 启用调试输出 |

---

## 权限系统

Claude Code 的工具调用需要权限确认。权限分为几个级别：

### 权限模式

| 模式 | 说明 |
|------|------|
| `default` | 每次工具调用都需确认 |
| `acceptEdits` | 自动接受编辑类操作 |
| `bypassPermissions` | 跳过所有权限（需在 settings 中配置） |
| `plan` | 仅允许只读操作 |

### 配置权限

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Grep",
      "Glob",
      "Bash(npm test)",
      "Bash(npm run *)",
      "Edit"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force)"
    ]
  }
}
```

### 权限匹配规则

- 支持通配符 `*` 和正则表达式
- `Bash(npm *)` — 匹配以 `npm` 开头的 Bash 命令
- `Edit(src/**/*.ts)` — 只允许编辑 src 下的 TS 文件
- 白名单优先处理：先检查 `allow`，再检查 `deny`

---

## 常用工作流

### 代码审查

```bash
# 审查未提交的改动
claude "审查我当前的改动，重点关注安全问题"

# 审查特定 commit
git diff HEAD~1 | claude -p "审查这些变更"
```

### 自动化修复

```bash
# Lint 修复
claude "修复所有 ESLint 错误，只改动必要的文件"

# 类型错误修复
claude "修复所有 TypeScript 类型错误"
```

### 重构

```bash
# 小范围重构
claude "把 src/utils/ 下的函数改为 camelCase 命名"

# 大范围重构（建议先进入 plan 模式）
claude "我要把项目从 JavaScript 迁移到 TypeScript，先帮我制定计划"
```

### 持续对话

```bash
# 中断后继续
claude --continue

# 恢复特定会话
claude --resume abc123
```

### 批量处理

```bash
# 批量生成文档
for dir in src/*/; do
  claude -p "为 $dir 目录生成 README 文档" >> docs.md
done
```

### Git 工作流

```bash
# 生成 commit message
claude -p "根据当前 git diff 生成一个规范的 commit message"
```

---

## 小贴士

- 使用 `/compact` 在上下文快满时压缩对话
- 项目级 `CLAUDE.md` 可以显著提升 Claude 对项目的理解
- Hook 可以用来强制执行团队规范（如代码检查、测试运行）
- 权限配置建议写在项目级的 `settings.json` 中，方便团队共享
- 使用 `--verbose` 可以在排查问题时看到更多细节
