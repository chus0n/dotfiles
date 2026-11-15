# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

macOS 用の個人 dotfiles。やり取り・コミットメッセージは日本語。

## 構成

ホームディレクトリ側はこのリポジトリへの symlink になっている。**編集はリポジトリ内のファイルに対して行う**（symlink 先を別ファイルで置き換えない）。

| ホーム側 | リポジトリ側 |
|---|---|
| `~/.zshrc` | `.zshrc`（zinit + starship） |
| `~/.vimrc` | `.vimrc`（dein、補完は vim-lsp + clangd） |
| `~/.config/nvim` | `.config/nvim/`（ディレクトリごと） |
| `~/.gitconfig` | `.gitconfig`（git-secrets のパターン定義を含む） |
| `~/.gitignore` | `.gitignore`（グローバル gitignore を兼ねる） |
| `~/Brewfile` | `Brewfile`（`brew bundle dump` で現在の環境から作ったもの） |

新しい設定ファイルを管理下に入れるときは、リポジトリに移してから `ln -s` で元の場所に戻す。

## Neovim

- 設定は `.config/nvim/init.lua` の 1 ファイル。プラグイン管理は Neovim 本体の `vim.pack`（ロックファイルは `nvim-pack-lock.json`、これもコミットする）。
- 構成: molokai（カラースキーム）、telescope（unite の代わり）、nvim-tree（nerdtree の代わり、netrw は無効化）、本体の LSP で clangd。
- プラグインの読み込みは `pcall(require, ...)` で囲み、未インストールでも起動が壊れないようにしている。追加するときも同じ形にする。
- 読み込み確認: `nvim --headless +qa` で何も出力されなければ OK。

## Hook

`.claude/settings.json` の PostToolUse hook（`.claude/hooks/check-config.sh`）が、編集後に自動で確認する:
- `.config/nvim/` 以下 → Neovim がリポジトリの設定をエラーなしで読み込めるか
- `.zshrc` → `zsh -n` で構文エラーがないか

エラーが返ってきたら、コミット前に直す。

## git-secrets

コミット時に git-secrets のフック（pre-commit / commit-msg / prepare-commit-msg）が走る。パターンは `.gitconfig` に定義し、そのパターン定義行自体は `.gitallowed` で許可している。**`--no-verify` で回避しない**。誤検知なら `.gitallowed` に許可パターンを足す。
