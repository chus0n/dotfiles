# ====================
# Zinit (Plugin Manager)
# ====================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# ====================
# Plugins
# ====================
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions

# ====================
# PATH
# ====================
export PATH="$HOME/.cargo/bin:$PATH"

# for golang
if [ -x "$(which go)" ]; then
    export GOPATH=$HOME
    export GOBIN="$GOPATH/bin"
    export PATH="$GOBIN:$PATH"
fi

# for python (pyenv lazy load)
export PATH="$HOME/.pyenv/bin:$PATH"
pyenv() {
    unset -f pyenv
    if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
}

# latex
export PATH=/Library/Tex/texbin:$PATH

# ====================
# asdf
# ====================
source "$(brew --prefix asdf)/libexec/asdf.sh"
fpath=(${ASDF_DIR}/completions $fpath)

# ====================
# Google Cloud SDK
# ====================
source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

# ====================
# fzf
# ====================
source <(fzf --zsh)
export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=header,grid --line-range :100 {}"'
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

# ====================
# fzf: history search (Ctrl+R)
# ====================
function fzf-history-selection() {
    BUFFER=`history -n 1 | tail -r | fzf --query "$LBUFFER"`
    CURSOR=$#BUFFER
    zle reset-prompt
}
zle -N fzf-history-selection
bindkey '^R' fzf-history-selection

# ====================
# ghq + fzf (Ctrl+])
# ====================
function fzf-src() {
    local selected_dir=$(ghq list -p | fzf --query "$LBUFFER")
    if [ -n "$selected_dir" ]; then
      BUFFER="cd ${selected_dir}"
      zle accept-line
    fi
    zle reset-prompt
}
zle -N fzf-src
bindkey '^]' fzf-src

# ====================
# fzf: git branch switch
# ====================
function fzf-git-branch() {
    local branches branch
    branches=$(git branch -vv) &&
    branch=$(echo "$branches" | fzf +m) &&
    git checkout $(echo "$branch" | awk '{ print $1 }' | sed "s/.* //")
}
zle -N fzf-git-branch

# ====================
# fzf: SSH (Ctrl+\)
# ====================
function fzf-ssh() {
    local selected_host=$(grep "^Host " ~/.ssh/config | grep -v '*' | cut -b 6- | fzf --query "$LBUFFER" --prompt "ssh > ")
    if [ -n "$selected_host" ]; then
      BUFFER="ssh ${selected_host}"
      zle accept-line
    fi
    zle reset-prompt
}
zle -N fzf-ssh
bindkey '^\' fzf-ssh

# ====================
# zoxide (z replacement)
# ====================
eval "$(zoxide init zsh)"

# ====================
# History
# ====================
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# ====================
# Completion
# ====================
autoload -Uz compinit && compinit
zinit cdreplay -q

# ====================
# Aliases
# ====================
alias reload='exec zsh -l'

# ====================
# Environment Variables
# ====================
export GIST_USER=chus0n
export DOCKER_CONTENT_TRUST=1
export EDITOR=nvim
export VISUAL=nvim

# ====================
# Starship Prompt
# ====================
eval "$(starship init zsh)"

. "$HOME/.local/bin/env"

# 1000line os
export PATH="$PATH:$(brew --prefix)/opt/llvm/bin"

