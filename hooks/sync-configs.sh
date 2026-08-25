#!/bin/bash
# =============================================================================
# sync-configs.sh — SessionStart hook for bidirectional config sync
# =============================================================================
# Syncs settings.json (common fields) and .claude.json (MCP servers)
# between WSL ($HOME/.claude/) and Windows (%USERPROFILE%\.claude\)
#
# Skills, hooks, CLAUDE.md are already symlinked — no sync needed for those.
# settings.json differs per platform (MCP paths), so we merge selectively.
# =============================================================================
set -euo pipefail

WSL_SETTINGS="$HOME/.claude/settings.json"
WIN_SETTINGS="/mnt/c/Users/${WIN_USER:-$USER}/.claude/settings.json"
WSL_CLAUDE_JSON="$HOME/.claude.json"
WIN_CLAUDE_JSON="/mnt/c/Users/${WIN_USER:-$USER}/.claude.json"

JQ=$(command -v jq || echo "")
if [ -z "$JQ" ] || [ ! -x "$JQ" ]; then exit 0; fi

# --- Sync enabledPlugins and hooks from Windows → WSL ---
if [ -f "$WIN_SETTINGS" ] && [ -f "$WSL_SETTINGS" ]; then
  # Read common fields from Windows (canonical for plugins)
  PLUGINS=$("$JQ" -c '.enabledPlugins // {}' "$WIN_SETTINGS")
  EFFORT=$("$JQ" -r '.effortLevel // "high"' "$WIN_SETTINGS")
  AUTO_UPDATES=$("$JQ" -r '.autoUpdatesChannel // "latest"' "$WIN_SETTINGS")
  WIN_HOOKS=$("$JQ" -c '.hooks // {}' "$WIN_SETTINGS")

  # Update WSL settings preserving mcpServers (Linux-specific paths)
  "$JQ" --argjson plugins "$PLUGINS" \
         --arg effort "$EFFORT" \
         --arg updates "$AUTO_UPDATES" \
         --argjson hooks "$WIN_HOOKS" \
    '.enabledPlugins = $plugins | .effortLevel = $effort | .autoUpdatesChannel = $updates | .hooks = $hooks' \
    "$WSL_SETTINGS" > "${WSL_SETTINGS}.tmp" && mv "${WSL_SETTINGS}.tmp" "$WSL_SETTINGS"

  # Sync mcpServers from WSL → Windows (skip jira which has Linux paths)
  WSL_MCP=$("$JQ" -c '.mcpServers // {}' "$WSL_SETTINGS")
  # Add non-jira MCP servers to Windows
  "$JQ" --argjson wsl_mcp "$WSL_MCP" \
    '.mcpServers = (.mcpServers // {}) + ($wsl_mcp | del(.jira))' \
    "$WIN_SETTINGS" > "${WIN_SETTINGS}.tmp" && mv "${WIN_SETTINGS}.tmp" "$WIN_SETTINGS"
fi

# --- Sync .claude.json MCP servers bidirectionally ---
if [ -f "$WSL_CLAUDE_JSON" ] && [ -f "$WIN_CLAUDE_JSON" ]; then
  WSL_MCP=$("$JQ" -c '.mcpServers // {}' "$WSL_CLAUDE_JSON")
  WIN_MCP=$("$JQ" -c '.mcpServers // {}' "$WIN_CLAUDE_JSON")

  # Merge: union of both MCP server lists
  MERGED=$("$JQ" -nc --argjson a "$WSL_MCP" --argjson b "$WIN_MCP" '$a + $b')

  # Write merged to both
  "$JQ" --argjson mcp "$MERGED" '.mcpServers = $mcp' "$WSL_CLAUDE_JSON" > "${WSL_CLAUDE_JSON}.tmp" \
    && mv "${WSL_CLAUDE_JSON}.tmp" "$WSL_CLAUDE_JSON"
  "$JQ" --argjson mcp "$MERGED" '.mcpServers = $mcp' "$WIN_CLAUDE_JSON" > "${WIN_CLAUDE_JSON}.tmp" \
    && mv "${WIN_CLAUDE_JSON}.tmp" "$WIN_CLAUDE_JSON"
fi

exit 0
