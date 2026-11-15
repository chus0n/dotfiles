#!/bin/sh
# PostToolUse hook: 編集した設定ファイルが読み込めるかを確認する。
# 問題があれば exit 2 で Claude にエラー内容を返す。
file=$(jq -r '.tool_input.file_path // empty')
root=${CLAUDE_PROJECT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}

case "$file" in
  */.config/nvim/*)
    # リポジトリ内の設定を Neovim の設定として読み込む（~/.config の symlink に依存しない）
    out=$(XDG_CONFIG_HOME="$root/.config" nvim --headless +qa 2>&1)
    label="Neovim の設定読み込みでエラー" ;;
  */.zshrc)
    out=$(zsh -n "$file" 2>&1)
    label=".zshrc の構文エラー" ;;
  *) exit 0 ;;
esac

if [ -n "$out" ]; then
  printf '%s:\n%s\n' "$label" "$out" >&2
  exit 2
fi
