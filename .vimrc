syntax enable
set number

" Tab settings
set tabstop=2
set autoindent
set expandtab
set shiftwidth=2

" color settings
set background=dark
colorscheme solarized
let g:solarized_termcolors=256

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
inoremap { {}<LEFT>
inoremap ( ()<LEFT>
inoremap [ []<LEFT>
inoremap ' ''<LEFT>
inoremap " ""<LEFT>

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

" NeoBundle plugin {{
if 0 | endif

if has('vim_starting')
    if &compatible
        set nocompatible    " Be iMproved
    endif

    " Required
    set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required
call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
" Required
NeoBundleFetch 'Shougo/neobundle.vim'

" My Bundles here:
" Refer to |:NeoBundle-examples|.
" Note: You don't set neobundle setting in .gvimrc!
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/neocomplete'
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'scrooloose/nerdtree'
NeoBundle 'tpope/vim-surround'
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'othree/html5.vim'
NeoBundle 'hail2u/vim-css3-syntax'
NeoBundle 'jelera/vim-javascript-syntax'
NeoBundle 'mattn/emmet-vim'
NeoBundle 'bronson/vim-trailing-whitespace'
NeoBundle 'plasticboy/vim-markdown'
NeoBundle 'kannokanno/previm'
NeoBundle 'tyru/open-browser.vim'
NeoBundle 'https://github.com/powerline/powerline.git', { 'rtp' : 'powerline/bindings/vim'}

call neobundle#end()

" Required
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will convenientry prompt you to install them.
NeoBundleCheck
" }}


" Unite.vim {{
" 入力モードで開始する
let g:unite_enable_start_=1
" buffer list
noremap <C-P> :Unite buffer<CR>
" file list
noremap <C-N> :Unite -buffer-name=file file<CR>
" current file list
noremap <C-Z> :Unite file-mru<CR>
" window を分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
au FileType unite inoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
" window を縦に分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')
au FileType unite nnoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')
" ESCキーを二回押すと終了する
au FileType unite nnoremap <silent> <buffer> <expr> <ESC><ESC> :q<CR>
au FileType unite nnoremap <silent> <buffer> <expr> <ESC><ESC> <ESC>:q<CR>
" }}

" vim-indent-guides {{
let g:indent_guides_enable_on_vim_startup = 1
" }}

" powerline {{
set laststatus=2
set showtabline=2
set noshowmode
" }}

" markdown {{
au BufRead,BufNewFile *.md set filetype=markdown
" }}

" neocomplete {{
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocompete#enable_start_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#source#dictionary#dictionaries = {
      \ 'default' : '',
      \ 'vimshell' : $HOME.'/.vimshell_hist',
      \ 'scheme' : $HOME.'/.gosh_completions',
        \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
  let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>    neocomplete#undo_completion()
inoremap <expr><C-l>    neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return (pumvisible() ? "\<C-y>" : "") . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? "\<C-y>" : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? "\<C-y>" : "\<Space>"

" AutoComplPop like behavior.
"let g:neocomplete#enable_auto_select = 1

" Shell like behavior(not recommended.)
"set completeopt+=longest
"let g:neocomplete#enable_auto_select = 1
"let g:neocomplete#disable_auto_complete = 1
"inoremap <expr><TAB>   pumvisible() ? "\<DOWN>" : "\<C-x>\<C-u>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
" let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*:;'
" let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
" let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
" let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
" }}

" neosnippet {{
" Plugin key-mappings
imap <C-k>    <Plug>(neosnippet_expand_or_jump)
smap <C-k>    <Plug>(neosnippet_expand_or_jump)
xmap <C-k>    <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
" imap <expr><TAB>
" \ pumvisible() ? "\<C-n>" :
" \ neosnippet#expandable_or_jumpable() ?
" \   "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandble_or_jumpable() ?
      \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For conceal markers.
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif
" }}
