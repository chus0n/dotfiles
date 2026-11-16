-- 最小限の Neovim 設定
-- .vimrc の基本設定 + 括弧補完 + 本体の LSP（clangd）による補完
-- プラグイン（vim.pack）: molokai / telescope / nvim-tree

---------------------------------------------------------------------------
-- 基本設定
---------------------------------------------------------------------------
local opt = vim.opt

-- 標準のファイラー netrw を無効化（nvim-tree と競合するため、先頭で設定する）
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

opt.number = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

opt.ignorecase = true -- 大文字小文字を区別しない
opt.smartcase = true  -- 検索文字に大文字がある場合は区別する

opt.list = true
opt.listchars = { tab = '»-', trail = '-', extends = '»', precedes = '«', nbsp = '%', eol = '↲' }

opt.clipboard = 'unnamedplus'
opt.undofile = true -- undo 履歴を保存（保存先は Neovim の既定: ~/.local/state/nvim/undo）
opt.signcolumn = 'yes'

opt.completeopt = { 'menuone', 'noinsert', 'noselect', 'popup' }
opt.shortmess:append('c')

-- 全角スペースを可視化
vim.api.nvim_set_hl(0, 'ZenkakuSpace', { reverse = true, fg = 'lightblue' })
vim.api.nvim_create_autocmd({ 'VimEnter', 'WinEnter', 'BufRead' }, {
  callback = function()
    -- matchadd はウィンドウごとに積み上がるので、未登録のウィンドウにだけ追加する
    if not vim.w.zenkaku_match then
      vim.w.zenkaku_match = vim.fn.matchadd('ZenkakuSpace', '　')
    end
  end,
})
vim.api.nvim_create_autocmd('ColorScheme', {
  callback = function() vim.api.nvim_set_hl(0, 'ZenkakuSpace', { reverse = true, fg = 'lightblue' }) end,
})

---------------------------------------------------------------------------
-- カラースキーム（molokai）
-- Neovim 本体のプラグイン管理（vim.pack）で取得する。初回起動時にインストール確認が出る。
-- 保存先: ~/.local/share/nvim/site/pack/core/opt/molokai
---------------------------------------------------------------------------
vim.pack.add({ 'https://github.com/tomasr/molokai' })
opt.background = 'dark'
-- 未インストールでも起動時にエラーで止まらないよう pcall で読み込む
pcall(vim.cmd.colorscheme, 'molokai')

---------------------------------------------------------------------------
-- telescope（unite の代わり）
-- キーは .vimrc の unite と同じ:
--   <C-p> バッファ一覧 / <C-n> ファイル一覧 / <C-z> 最近使ったファイル
-- 追加: <leader>fg 全文検索（ripgrep） / <leader>fh ヘルプ検索
-- telescope の中: <C-j> 横分割で開く / <C-k> 縦分割で開く / <Esc> 2 回で閉じる
---------------------------------------------------------------------------
vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
})

local ok_telescope, telescope = pcall(require, 'telescope')
if ok_telescope then
  local actions = require('telescope.actions')
  local builtin = require('telescope.builtin')

  telescope.setup({
    defaults = {
      mappings = {
        i = {
          ['<C-j>'] = actions.select_horizontal,
          ['<C-k>'] = actions.select_vertical,
        },
        n = {
          ['<C-j>'] = actions.select_horizontal,
          ['<C-k>'] = actions.select_vertical,
        },
      },
    },
  })

  vim.keymap.set('n', '<C-p>', builtin.buffers, { desc = 'バッファ一覧' })
  vim.keymap.set('n', '<C-n>', builtin.find_files, { desc = 'ファイル一覧' })
  vim.keymap.set('n', '<C-z>', builtin.oldfiles, { desc = '最近使ったファイル' })
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '全文検索' })
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'ヘルプ検索' })
end

---------------------------------------------------------------------------
-- nvim-tree（nerdtree の代わり）
--   <leader>e ツリーの表示・非表示 / <leader>E 今のファイルをツリーで表示
-- ツリーの中: <CR> 開く / a 作成 / d 削除 / r 名前変更 / g? キー一覧
-- アイコンは Nerd Font がなくても表示できる記号にしている
---------------------------------------------------------------------------
vim.pack.add({ 'https://github.com/nvim-tree/nvim-tree.lua' })

local ok_tree, nvim_tree = pcall(require, 'nvim-tree')
if ok_tree then
  nvim_tree.setup({
    renderer = {
      icons = {
        show = { file = false, folder = false, folder_arrow = true, git = true },
        glyphs = {
          folder = { arrow_closed = '▸', arrow_open = '▾' },
          git = {
            unstaged = '✗', staged = '✓', unmerged = '!', renamed = '➜',
            untracked = '★', deleted = '-', ignored = '◌',
          },
        },
      },
    },
    filters = { git_ignored = false }, -- .gitignore 対象（kernel.elf など）も表示
  })

  local tree_api = require('nvim-tree.api')
  vim.keymap.set('n', '<leader>e', tree_api.tree.toggle, { desc = 'ツリーの表示切り替え' })
  vim.keymap.set('n', '<leader>E', function() tree_api.tree.find_file({ open = true, focus = true }) end,
    { desc = '今のファイルをツリーで表示' })
end

-- jj でノーマルモードへ
vim.keymap.set('i', 'jj', '<Esc>', { silent = true })

-- help を q で閉じる
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'help',
  callback = function(ev) vim.keymap.set('n', 'q', '<C-w>c', { buffer = ev.buf }) end,
})

---------------------------------------------------------------------------
-- 括弧・引用符の補完（.vimrc と同じ挙動）
-- - 直後が英数字なら開き括弧を単独で入力
-- - 直後に同じ閉じ文字があれば飛び越える
-- - 空ペアの間で <BS> を押すとペアごと削除
-- - {|} の間で <CR> を押すとブロックを展開
---------------------------------------------------------------------------
local function next_char()
  local col = vim.fn.col('.')
  return vim.fn.getline('.'):sub(col, col)
end

local function prev_char()
  local col = vim.fn.col('.')
  return col > 1 and vim.fn.getline('.'):sub(col - 1, col - 1) or ''
end

local function is_word(c) return c:match('[%w_]') ~= nil end

local pairs_map = { ['('] = ')', ['['] = ']', ['{'] = '}' }
for open, close in pairs(pairs_map) do
  vim.keymap.set('i', open, function()
    return is_word(next_char()) and open or (open .. close .. '<Left>')
  end, { expr = true })
  vim.keymap.set('i', close, function()
    return next_char() == close and '<Right>' or close
  end, { expr = true })
end

for _, q in ipairs({ "'", '"' }) do
  vim.keymap.set('i', q, function()
    if next_char() == q then return '<Right>' end
    -- 英数字の直前・直後（例: don't）ではペアにしない
    if is_word(prev_char()) or is_word(next_char()) then return q end
    return q .. q .. '<Left>'
  end, { expr = true })
end

local empty_pairs = { ['()'] = true, ['[]'] = true, ['{}'] = true, ["''"] = true, ['""'] = true }
vim.keymap.set('i', '<BS>', function()
  return empty_pairs[prev_char() .. next_char()] and '<Del><BS>' or '<BS>'
end, { expr = true })

---------------------------------------------------------------------------
-- 補完メニューの操作
-- <Tab>/<S-Tab> で候補選択、<CR> で確定
---------------------------------------------------------------------------
local pumvisible = function() return vim.fn.pumvisible() == 1 end

vim.keymap.set('i', '<Tab>', function() return pumvisible() and '<C-n>' or '<Tab>' end, { expr = true })
vim.keymap.set('i', '<S-Tab>', function() return pumvisible() and '<C-p>' or '<S-Tab>' end, { expr = true })
vim.keymap.set('i', '<CR>', function()
  if pumvisible() then
    -- 候補を選んでいれば確定、選んでいなければメニューを閉じて改行
    return vim.fn.complete_info({ 'selected' }).selected ~= -1 and '<C-y>' or '<C-e><CR>'
  end
  if prev_char() .. next_char() == '{}' then return '<CR><Esc>O' end
  return '<CR>'
end, { expr = true })

---------------------------------------------------------------------------
-- LSP（Neovim 本体の機能のみ）
-- C/C++ は Homebrew LLVM の clangd を優先する（RISC-V ターゲット対応）
-- なければ PATH 上の clangd（Xcode 付属など）を使い、どちらもなければ LSP を有効にしない
-- プロジェクトの compile_flags.txt / compile_commands.json を読む
---------------------------------------------------------------------------
local clangd = '/opt/homebrew/opt/llvm/bin/clangd'
if vim.fn.executable(clangd) ~= 1 then clangd = 'clangd' end

if vim.fn.executable(clangd) == 1 then
  vim.lsp.config('clangd', {
    cmd = { clangd, '--header-insertion=never' },
    filetypes = { 'c', 'cpp' },
    root_markers = { 'compile_commands.json', 'compile_flags.txt', '.git' },
  })
  vim.lsp.enable('clangd')
end

vim.diagnostic.config({ virtual_text = true })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end

    if client:supports_method('textDocument/completion') then
      -- 識別子の入力中にも補完を出す（既定では . や -> の後だけ）
      local chars = { '.', '>', ':' }
      for c in ('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'):gmatch('.') do
        table.insert(chars, c)
      end
      client.server_capabilities.completionProvider.triggerCharacters = chars
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end

    -- 既定のキー: K（ホバー）, grn（リネーム）, grr（参照）, gra（コードアクション）,
    --             [d / ]d（前後の診断）, <C-]>（定義へ移動）
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf })
  end,
})
