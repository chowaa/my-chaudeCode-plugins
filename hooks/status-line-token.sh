#!/usr/bin/env bash
# Status line: 显示 token 用量（本轮输出 + 累计总量 + 上下文占比）
# stdin 接收 Claude Code 传入的 JSON（格式见 settings.json statusLine 指令文档）
set -euo pipefail

export PYTHONIOENCODING=utf-8

python3 -c '
import sys, json

# Windows 下强制 UTF-8 输出，避免 GBK 编码报错
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

try:
    raw = sys.stdin.read()
    if not raw.strip():
        print("[等待数据...]")
        sys.exit(0)
    data = json.loads(raw)
except Exception:
    print("[等待数据...]")
    sys.exit(0)

ctx = data.get("context_window", {}) or {}

# --- 累积总量（整个对话） ---
total_in  = ctx.get("total_input_tokens", 0) or 0
total_out = ctx.get("total_output_tokens", 0) or 0
total     = total_in + total_out

# --- 最近一次 API 返回的输出 token 数（本轮） ---
usage   = ctx.get("current_usage", {}) or {}
last_out = usage.get("output_tokens", 0) or 0

# --- 上下文窗口大小 ---
ctx_size = ctx.get("context_window_size", 0) or 0
used_pct = ctx.get("used_percentage")  # 可能为 null

# --- 模型 ---
model = data.get("model", {}) or {}
model_name = model.get("display_name", "?")

# --- ANSI 颜色（终端 dimmed 色系） ---
CYA = "\033[36m"
YLW = "\033[33m"
GRN = "\033[32m"
RST = "\033[0m"

# --- 格式化输出 ---
parts = []
parts.append(f"{CYA}{model_name}{RST}")
parts.append(f"本轮:{YLW}{last_out/1000:.1f}k{RST}")
parts.append(f"总:{GRN}{total/1000:.1f}k{RST}")

if used_pct is not None:
    parts.append(f"ctx:{used_pct:.0f}%")
elif ctx_size > 0:
    pct = total / ctx_size * 100
    parts.append(f"ctx:{pct:.0f}%")

print("  ".join(parts))
'
