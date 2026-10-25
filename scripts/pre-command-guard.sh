#!/usr/bin/env bash
# Bottega PreToolUse Security Hook for Antigravity (`run_command` matcher)
# Reads JSON payload from stdin and outputs JSON decision {"decision": "allow"|"deny"|"ask", "reason": "..."}

set -euo pipefail

python3 -c '
import json
import os
import re
import subprocess
import sys

try:
    payload = json.load(sys.stdin)
except Exception:
    print(json.dumps({"decision": "allow"}))
    sys.exit(0)

tool_call = payload.get("toolCall", {})
args = tool_call.get("args", {})
cmd = args.get("CommandLine", "") or ""
workspaces = payload.get("workspacePaths", []) or []
cwd = workspaces[0] if workspaces else os.getcwd()

# 1. Hard-block catastrophic / destructive commands
deny_patterns = [
    (r"(^|\s|;|&|\|)rm\s+(-[a-zA-Z]*r[a-zA-Z]*f|--recursive)\s+(/|/\*|\$HOME|~)(\s|$|;)", "Blocked destructive root/home recursive deletion command."),
    (r"mkfs\.[a-z0-9]+", "Blocked filesystem formatting command."),
    (r":\(\)\s*\{\s*:\|:&\s*\}\s*;:", "Blocked fork bomb command."),
    (r"chmod\s+(-R\s+)?777\s+/", "Blocked world-writable root permission change."),
]

for pattern, reason in deny_patterns:
    if re.search(pattern, cmd):
        print(json.dumps({"decision": "deny", "reason": f"[Bottega Security Guard] {reason}"}))
        sys.exit(0)

# 2. Require explicit confirmation ("ask") for risky supply-chain or force-push operations
ask_patterns = [
    (r"curl\s+[^|]*\|\s*(ba)?sh", "Piping remote script directly to shell requires explicit user review."),
    (r"wget\s+[^|]*\|\s*(ba)?sh", "Piping remote script directly to shell requires explicit user review."),
    (r"git\s+push\s+.*(--force|-f)(\s|$)", "Force-pushing git history requires explicit user confirmation."),
]

for pattern, reason in ask_patterns:
    if re.search(pattern, cmd):
        print(json.dumps({"decision": "ask", "reason": f"[Bottega Security Guard] {reason}"}))
        sys.exit(0)

# 3. Pre-commit Secret & .env Leak Check when running `git commit`
if re.search(r"(^|\s|;|&)git\s+commit(\s|$)", cmd):
    try:
        staged_files = subprocess.check_output(
            ["git", "-C", cwd, "diff", "--cached", "--name-only"],
            stderr=subprocess.DEVNULL,
            text=True,
            timeout=4,
        ).splitlines()

        forbidden_files = []
        for f in staged_files:
            base = os.path.basename(f)
            if (base == ".env" or (base.startswith(".env.") and not base.endswith((".example", ".sample", ".template")))) or base.endswith((".pem", ".key", "id_rsa", "id_ed25519")):
                forbidden_files.append(f)

        if forbidden_files:
            print(json.dumps({
                "decision": "deny",
                "reason": f"[Bottega Security Guard] Blocked git commit: sensitive environment/key file(s) staged: {forbidden_files}. Remove them with `git reset HEAD <file>` and add to .gitignore."
            }))
            sys.exit(0)

        staged_diff = subprocess.check_output(
            ["git", "-C", cwd, "diff", "--cached", "-U0"],
            stderr=subprocess.DEVNULL,
            text=True,
            timeout=4,
        )
        added_lines = "\n".join(
            line[1:] for line in staged_diff.splitlines()
            if line.startswith("+") and not line.startswith("+++")
        )

        secret_regexes = [
            (r"-----BEGIN (RSA |EC |OPENSSH |DSA |PRIVATE )?PRIVATE KEY-----", "Private Key"),
            (r"AKIA[0-9A-Z]{16}", "AWS Access Key ID"),
            (r"gh[pousr]_[A-Za-z0-9_]{36,}", "GitHub Token"),
            (r"AIza[0-9A-Za-z\-_]{35}", "Google API Key"),
            (r"xox[baprs]-[0-9A-Za-z\-]{10,}", "Slack Token"),
        ]
        for s_pat, s_name in secret_regexes:
            if re.search(s_pat, added_lines):
                print(json.dumps({
                    "decision": "deny",
                    "reason": f"[Bottega Security Guard] Blocked git commit: potential hardcoded {s_name} detected in staged diff."
                }))
                sys.exit(0)
    except Exception:
        pass

print(json.dumps({"decision": "allow"}))
'
