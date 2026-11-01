#!/usr/bin/env bash
# Bottega Installer & Workspace Linker for Google Antigravity
# Usage:
#   ./scripts/install.sh --global                  # Installs plugin globally in ~/.gemini/config/plugins/bottega
#   ./scripts/install.sh --workspace /path/to/app  # Installs rules, skills, and hooks into a project workspace
#   ./scripts/install.sh --all                     # Installs globally AND sets up current workspace .agents/

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="${1:---all}"
TARGET_WS="${2:-$REPO_ROOT}"

install_global() {
  local plugin_dir="$HOME/.gemini/config/plugins/bottega"
  echo "[Bottega] Installing global Antigravity plugin to: $plugin_dir"
  mkdir -p "$plugin_dir"
  cp -rf "$REPO_ROOT/plugin.json" "$plugin_dir/"
  cp -rf "$REPO_ROOT/hooks.json" "$plugin_dir/"
  cp -rf "$REPO_ROOT/assets" "$plugin_dir/"
  cp -rf "$REPO_ROOT/rules" "$plugin_dir/"
  cp -rf "$REPO_ROOT/skills" "$plugin_dir/"
  cp -rf "$REPO_ROOT/agents" "$plugin_dir/"
  cp -rf "$REPO_ROOT/scripts" "$plugin_dir/"
  chmod +x "$plugin_dir/scripts/"*.sh
  find "$plugin_dir/skills" -type f -name "*.sh" -exec chmod +x {} +

  # If Antigravity Language Server is reachable, enable the plugin live via RPC
  if [[ -n "${ANTIGRAVITY_CSRF_TOKEN:-}" ]]; then
    local ls_addr="${ANTIGRAVITY_LS_ADDRESS:-localhost:5387}"
    if curl -sS "http://${ls_addr}/healthz" >/dev/null 2>&1; then
      curl -sS -X POST \
        "http://${ls_addr}/exa.language_server_pb.LanguageServerService/JetboxWriteState" \
        -H "Content-Type: application/json" \
        -H "x-codeium-csrf-token: ${ANTIGRAVITY_CSRF_TOKEN}" \
        -d '{"userConfig":{"plugins":{"bottega":{"enabled":true}}}}' >/dev/null || true
      echo "[Bottega] Enabled 'bottega' plugin in Antigravity userConfig via Language Server RPC."
    fi
  fi
  echo "[Bottega] Global plugin installation complete."
}

install_workspace() {
  local ws_dir
  ws_dir="$(cd "$1" && pwd)"
  echo "[Bottega] Configuring workspace customizations in: $ws_dir"
  mkdir -p "$ws_dir/.agents/plugins"
  # Copy root AGENTS.md if not present or if updating bottega repo itself
  cp -f "$REPO_ROOT/rules/AGENTS.md" "$ws_dir/AGENTS.md"
  cp -f "$REPO_ROOT/hooks.json" "$ws_dir/.agents/hooks.json"
  mkdir -p "$ws_dir/.agents/skills"
  cp -rf "$REPO_ROOT/skills/"* "$ws_dir/.agents/skills/"
  find "$ws_dir/.agents/skills" -type f -name "*.sh" -exec chmod +x {} +
  if [[ "$ws_dir" != "$REPO_ROOT" ]]; then
    mkdir -p "$ws_dir/scripts"
    cp -f "$REPO_ROOT/scripts/pre-command-guard.sh" "$ws_dir/scripts/"
    cp -f "$REPO_ROOT/scripts/security-scan.sh" "$ws_dir/scripts/"
    chmod +x "$ws_dir/scripts/"*.sh
  fi
  echo "[Bottega] Workspace configuration complete ($ws_dir/AGENTS.md and $ws_dir/.agents/)."
}

case "$MODE" in
  --global)
    install_global
    ;;
  --workspace)
    install_workspace "$TARGET_WS"
    ;;
  --all)
    install_global
    install_workspace "$REPO_ROOT"
    ;;
  *)
    echo "Usage: $0 [--global | --workspace /path/to/project | --all]"
    exit 1
    ;;
esac
