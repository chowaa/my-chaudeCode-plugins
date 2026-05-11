# my-chaudeCode-plugins

Claude Code 配置与插件集合。

## Stop Hook：交付验收检查

Claude 结束回复前自动检查：如果本轮改了代码/配置/文档但未完成验证，则阻止结束并强制 Claude 继续工作。

### 一键安装

```bash
git clone https://github.com/chowaa/my-chaudeCode-plugins.git
cd my-chaudeCode-plugins
bash hooks/install-stop-hook.sh /path/to/your/project
```

`/path/to/your/project` 是你的代码项目目录，用于写入 `CLAUDE.md`。省略则默认当前目录。

### 验证安装

在 Claude Code 中输入：

```
/hooks
```

看到 Stop hook 即为安装成功。

### 工作原理

1. 每轮 Claude 结束前触发 Stop hook
2. 检测是否有代码/配置/文档改动（git diff + untracked）
3. 有改动 → 检查 `~/.claude/verification-done` 标记文件是否存在
4. 无标记 → 阻止结束，Claude 被 rewake 继续工作
5. Claude 完成验证后执行 `touch ~/.claude/verification-done`

### 文件

| 文件 | 说明 |
|------|------|
| `hooks/stop-check.sh` | Hook 脚本，安装时复制到 `~/.claude/hooks/` |
| `hooks/install-stop-hook.sh` | 安装脚本，自动复制并配置 settings.json |
