-- 最小限の Neovim 設定（プラグインなし）
-- .vimrc の基本設定 + 括弧補完 + 本体の LSP（clangd）による補完

---------------------------------------------------------------------------
-- 基本設定
---------------------------------------------------------------------------
local opt = vim.opt

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
  callback = function() vim.fn.matchadd('ZenkakuSpace', '　') end,
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
-- C/C++ は Homebrew LLVM の clangd を使う（RISC-V ターゲット対応）
-- プロジェクトの compile_flags.txt / compile_commands.json を読む
---------------------------------------------------------------------------
vim.lsp.config('clangd', {
  cmd = { '/opt/homebrew/opt/llvm/bin/clangd', '--header-insertion=never' },
  filetypes = { 'c', 'cpp' },
  root_markers = { 'compile_commands.json', 'compile_flags.txt', '.git' },
})
vim.lsp.enable('clangd')

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
