#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
CLAUDE_HOME="${HOME}/.claude"
DRY_RUN=false

usage() {
  echo "Usage: $0 [--dry-run]"
  echo ""
  echo "claude-code-settings の設定を ~/.claude/ にシンボリックリンクで配置します。"
  echo ""
  echo "Options:"
  echo "  --dry-run  実際にリンクを作成せず、実行内容をプレビューします"
  echo ""
  echo "リンク対象:"
  echo "  claude/commands/*.md     → ~/.claude/commands/"
  echo "  claude/skills/*/         → ~/.claude/skills/"
  echo "  .claude/rules/*.md       → ~/.claude/rules/"
  echo "  claude/CLAUDE.md         → ~/.claude/CLAUDE.md"
}

log() {
  echo "[setup] $1"
}

warn() {
  echo "[setup] ⚠ $1"
}

link_file() {
  local src="$1"
  local dest="$2"

  if [ "$DRY_RUN" = true ]; then
    if [ -L "$dest" ]; then
      local current_target
      current_target="$(readlink "$dest")"
      if [ "$current_target" = "$src" ]; then
        log "(skip) $dest → 既にリンク済み"
      else
        log "(update) $dest → $src (現在: $current_target)"
      fi
    elif [ -e "$dest" ]; then
      warn "(backup+link) $dest → $src (既存ファイルを .bak に退避)"
    else
      log "(create) $dest → $src"
    fi
    return
  fi

  if [ -L "$dest" ]; then
    local current_target
    current_target="$(readlink "$dest")"
    if [ "$current_target" = "$src" ]; then
      return
    fi
    rm "$dest"
  elif [ -e "$dest" ]; then
    warn "$dest が既に存在します → ${dest}.bak に退避"
    mv "$dest" "${dest}.bak"
  fi

  ln -s "$src" "$dest"
  log "リンク作成: $dest → $src"
}

link_dir() {
  local src="$1"
  local dest="$2"

  if [ "$DRY_RUN" = true ]; then
    if [ -L "$dest" ]; then
      local current_target
      current_target="$(readlink "$dest")"
      if [ "$current_target" = "$src" ]; then
        log "(skip) $dest → 既にリンク済み"
      else
        log "(update) $dest → $src (現在: $current_target)"
      fi
    elif [ -d "$dest" ]; then
      warn "(backup+link) $dest → $src (既存ディレクトリを .bak に退避)"
    else
      log "(create) $dest → $src"
    fi
    return
  fi

  if [ -L "$dest" ]; then
    local current_target
    current_target="$(readlink "$dest")"
    if [ "$current_target" = "$src" ]; then
      return
    fi
    rm "$dest"
  elif [ -d "$dest" ]; then
    warn "$dest が既に存在します → ${dest}.bak に退避"
    mv "$dest" "${dest}.bak"
  fi

  ln -s "$src" "$dest"
  log "リンク作成: $dest → $src"
}

main() {
  for arg in "$@"; do
    case "$arg" in
      --dry-run) DRY_RUN=true ;;
      --help|-h) usage; exit 0 ;;
      *) echo "Unknown option: $arg"; usage; exit 1 ;;
    esac
  done

  if [ "$DRY_RUN" = true ]; then
    log "=== ドライラン: 実際の変更は行いません ==="
  fi

  log "リポジトリ: $REPO_DIR"
  log "リンク先: $CLAUDE_HOME"
  echo ""

  # ディレクトリ作成
  if [ "$DRY_RUN" = false ]; then
    mkdir -p "$CLAUDE_HOME/commands"
    mkdir -p "$CLAUDE_HOME/skills"
    mkdir -p "$CLAUDE_HOME/rules"
  fi

  # Commands
  log "--- Commands ---"
  for cmd in "$REPO_DIR/claude/commands/"*.md; do
    [ -f "$cmd" ] || continue
    link_file "$cmd" "$CLAUDE_HOME/commands/$(basename "$cmd")"
  done
  echo ""

  # Skills
  log "--- Skills ---"
  for skill_dir in "$REPO_DIR/claude/skills/"*/; do
    [ -d "$skill_dir" ] || continue
    skill_name="$(basename "$skill_dir")"
    link_dir "${skill_dir%/}" "$CLAUDE_HOME/skills/$skill_name"
  done
  echo ""

  # Rules
  log "--- Rules ---"
  for rule in "$REPO_DIR/.claude/rules/"*.md; do
    [ -f "$rule" ] || continue
    link_file "$rule" "$CLAUDE_HOME/rules/$(basename "$rule")"
  done
  echo ""

  # CLAUDE.md
  log "--- CLAUDE.md ---"
  link_file "$REPO_DIR/claude/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"
  echo ""

  if [ "$DRY_RUN" = true ]; then
    log "=== ドライラン完了 ==="
    log "実際にリンクを作成するには --dry-run を外して再実行してください"
  else
    log "=== セットアップ完了 ==="
    echo ""
    log "以下は手動で設定してください:"
    log "  - ~/.claude/settings.json (claude/settings.json を参考にマージ)"
    log "  - ~/.claude.json (.claude.json を参考に MCP サーバーを設定)"
  fi
}

main "$@"
