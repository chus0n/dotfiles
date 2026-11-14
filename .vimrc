syntax enable
set number

" Tab settings
set tabstop=2
set autoindent
set expandtab
set shiftwidth=2

" search
set ignorecase    " 大文字小文字を区別しない
set smartcase     " 検索文字に大文字がある場合は大文字小文字を区別
set incsearch     " インクリメンタルサーチ
set hlsearch      " 検索マッチテキストをハイライト

" escape sequence
set list
set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%,eol:↲
" 全角スペース
function ZenkakuSpace()
  highlight ZenkakuSpace cterm=reverse ctermfg=lightblue gui=reverse guifg=darkgrey
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    " ZenkakuSpace をカラーファイルで設定するなら次の行を削除
    autocmd ColorScheme       * call ZenkakuSpace()
    autocmd VimEnter,WinEnter,BufRead * match ZenkakuSpace /　/
  augroup END
  call ZenkakuSpace()
endif

" 囲い文字の補完
" - 直後が英数字なら開き括弧を単独で入力
" - 直後に同じ閉じ文字があれば飛び越える（"())" の二重入力防止）
" - 空ペアの間で <BS> を押すとペアごと削除
function! s:NextChar() abort
  return getline('.')[col('.') - 1]
endfunction
function! s:PrevChar() abort
  return col('.') > 1 ? getline('.')[col('.') - 2] : ''
endfunction
function! s:OpenPair(open, close) abort
  return s:NextChar() =~# '\w' ? a:open : a:open . a:close . "\<Left>"
endfunction
function! s:ClosePair(close) abort
  return s:NextChar() ==# a:close ? "\<Right>" : a:close
endfunction
function! s:QuotePair(q) abort
  if s:NextChar() ==# a:q
    return "\<Right>"
  endif
  " 英数字の直前・直後（例: don't）ではペアにしない
  if s:PrevChar() =~# '\w' || s:NextChar() =~# '\w'
    return a:q
  endif
  return a:q . a:q . "\<Left>"
endfunction
function! s:InPair() abort
  return index(['()', '[]', '{}', "''", '""'], s:PrevChar() . s:NextChar()) >= 0
endfunction

inoremap <expr> { <SID>OpenPair('{', '}')
inoremap <expr> ( <SID>OpenPair('(', ')')
inoremap <expr> [ <SID>OpenPair('[', ']')
inoremap <expr> } <SID>ClosePair('}')
inoremap <expr> ) <SID>ClosePair(')')
inoremap <expr> ] <SID>ClosePair(']')
inoremap <expr> ' <SID>QuotePair("'")
inoremap <expr> " <SID>QuotePair('"')
inoremap <expr> <BS> <SID>InPair() ? "\<Del>\<BS>" : "\<BS>"

" insert mode escape
inoremap <silent> jj <ESC>

" menu を英語に戻す
source $VIMRUNTIME/delmenu.vim
set langmenu=none
source $VIMRUNTIME/menu.vim

" clipboard
set clipboard=unnamed,autoselect

" backup
set backupdir=$HOME/.vim/backup

" swap
set directory=$HOME/.vim/tmp

" undo
set undodir=$HOME/.vim/undo

" help を q で閉じる
autocmd FileType help nnoremap <buffer> q <C-w>c

"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=/Users/yuki/.cache/dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state('/Users/yuki/.cache/dein')
  call dein#begin('/Users/yuki/.cache/dein')

  " Let dein manage dein
  " Required:
  call dein#add('/Users/yuki/.cache/dein/repos/github.com/Shougo/dein.vim')

  " Add or remove your plugins here:
  call dein#add('Shougo/unite.vim')
  call dein#add('Shougo/neomru.vim')
  call dein#add('prabirshrestha/vim-lsp')
  call dein#add('mattn/vim-lsp-settings')
  call dein#add('prabirshrestha/asyncomplete.vim')
  call dein#add('prabirshrestha/asyncomplete-lsp.vim')
  call dein#add('ujihisa/unite-colorscheme')
  call dein#add('scrooloose/nerdtree')
  call dein#add('tpope/vim-surround')
  call dein#add('tomtom/tcomment_vim')
  call dein#add('nathanaelkane/vim-indent-guides')
  call dein#add('othree/html5.vim')
  call dein#add('hail2u/vim-css3-syntax')
  call dein#add('jelera/vim-javascript-syntax')
  call dein#add('mattn/emmet-vim')
  call dein#add('bronson/vim-trailing-whitespace')
  call dein#add('plasticboy/vim-markdown')
  call dein#add('kannokanno/previm')
  call dein#add('tyru/open-browser.vim')
  call dein#add('vim-airline/vim-airline')
  call dein#add('vim-airline/vim-airline-themes')
  call dein#add('tomasr/molokai')
  call dein#add('lilydjwg/colorizer')

  " You can specify revision/branch/tag.
  "call dein#add('Shougo/vimshell', { 'rev': '3787e5' })

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

"End dein Scripts-------------------------


" Unite.vim {{{
" 入力モードで開始する
let g:unite_enable_start_=1
" buffer list
noremap <C-P> :Unite buffer<CR>
" file list
noremap <C-N> :Unite -buffer-name=file file<CR>
" current file list
noremap <C-Z> :Unite file_mru<CR>
" window を分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
au FileType unite inoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
" window を縦に分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')
au FileType unite nnoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')
" ESCキーを二回押すと終了する
au FileType unite nnoremap <silent> <buffer> <expr> <ESC><ESC> :q<CR>
au FileType unite nnoremap <silent> <buffer> <expr> <ESC><ESC> <ESC>:q<CR>
" }}}

" vim-indent-guides {{{
let g:indent_guides_enable_on_vim_startup = 1
" }}}

" airline {{{
set laststatus=2
set showtabline=2
set t_Co=256
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#whitespace#mixed_indent_algo = 1
let g:airline_theme = 'dark'
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.crypt = '🔒'
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.maxlinenr = '㏑'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.spell = 'Ꞩ'
let g:airline_symbols.notexists = '∄'
let g:airline_symbols.whitespace = 'Ξ'

" powerline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.maxlinenr = ''
""}}}

" markdown {{{
au BufRead,BufNewFile *.md set filetype=markdown
" }}}

" LSP / 補完 (vim-lsp + asyncomplete + clangd) {{{
" C/C++ は Homebrew LLVM の clangd を使う（RISC-V ターゲット対応）
if executable('/opt/homebrew/opt/llvm/bin/clangd')
  augroup lsp_clangd
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'clangd',
          \ 'cmd': {server_info->['/opt/homebrew/opt/llvm/bin/clangd', '--header-insertion=never']},
          \ 'allowlist': ['c', 'cpp'],
          \ })
  augroup END
endif
let g:lsp_settings = {'clangd': {'disabled': v:true}}

let g:asyncomplete_auto_popup = 1
let g:asyncomplete_popup_delay = 100
set completeopt=menuone,noinsert,noselect,popup
set shortmess+=c

" <Tab>/<S-Tab> で候補選択、<CR> で確定
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" {|} の間で <CR> → ブロックを展開してインデント
inoremap <expr> <CR>    pumvisible() ? asyncomplete#close_popup() . "\<CR>"
      \ : (<SID>PrevChar() . <SID>NextChar() ==# '{}' ? "\<CR>\<Esc>O" : "\<CR>")

let g:lsp_diagnostics_echo_cursor = 1
function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> gr <plug>(lsp-references)
  nmap <buffer> K  <plug>(lsp-hover)
  nmap <buffer> <leader>rn <plug>(lsp-rename)
  nmap <buffer> [g <plug>(lsp-previous-diagnostic)
  nmap <buffer> ]g <plug>(lsp-next-diagnostic)
endfunction
augroup lsp_install
  autocmd!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
" }}}


" color settings
set background=dark
colorscheme molokai
let g:solarized_termcolors=256

set backspace=indent,eol,start
