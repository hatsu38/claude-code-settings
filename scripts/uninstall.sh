#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
CLAUDE_HOME="${HOME}/.claude"

log() {
  echo "[uninstall] $1"
}

remove_link() {
  local dest="$1"
  local expected_prefix="$REPO_DIR"

  if [ ! -L "$dest" ]; then
    return
  fi

  local target
  target="$(readlink "$dest")"

  case "$target" in
    "$expected_prefix"*)
      rm "$dest"
      log "リンク削除: $dest"

      if [ -e "${dest}.bak" ]; then
        mv "${dest}.bak" "$dest"
        log "バックアップ復元: ${dest}.bak → $dest"
      fi
      ;;
    *)
      ;;
  esac
}

main() {
  log "リポジトリ: $REPO_DIR"
  log "対象: $CLAUDE_HOME"
  echo ""

  # Commands
  log "--- Commands ---"
  for cmd in "$REPO_DIR/claude/commands/"*.md; do
    [ -f "$cmd" ] || continue
    remove_link "$CLAUDE_HOME/commands/$(basename "$cmd")"
  done

  # Skills
  log "--- Skills ---"
  for skill_dir in "$REPO_DIR/claude/skills/"*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    remove_link "$CLAUDE_HOME/skills/$skill_name"
  done

  # Rules
  log "--- Rules ---"
  for rule in "$REPO_DIR/.claude/rules/"*.md; do
    [ -f "$rule" ] || continue
    remove_link "$CLAUDE_HOME/rules/$(basename "$rule")"
  done

  # CLAUDE.md
  log "--- CLAUDE.md ---"
  remove_link "$CLAUDE_HOME/CLAUDE.md"

  echo ""
  log "=== アンインストール完了 ==="
}

main "$@"
