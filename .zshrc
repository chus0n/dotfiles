#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#
typeset -U PATH

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
# fzf
export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=header,grid --line-range :100 {}"'
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

#function fzf-history-selection() {
#    BUFFER=`history -n 1 | tail -r | fzf --query "$LBUFFER"`
#    #BUFFER=`history -n 1 | tail -r  | awk '!a[$0]++' | fzf --query "$LBUFFER"`
#    CURSOR=$#BUFFER
#    zle reset-prompt
#}
#
#zle -N fzf-history-selection
#bindkey '^R' fzf-history-selection

function fzf-src() {
    local selected_dir=$(ghq list -p | fzf --query "$LBUFFER")
    if [ -n "$selected_dir" ]; then
      BUFFER="cd ${selected_dir}"
      zle accept-line
    fi
    zle reset-prompt
    #zle clear-screen
}

zle -N fzf-src
bindkey '^]' fzf-src

function fzf-git-branch() {
    local branches branch
    branches=$(git branch -vv) &&
    branch=$(echo "$branches" | fzf +m) &&
    git checkout $(echo "$branch" | awk '{ print $1 }' | sed "s/.* //")
}

zle -N fzf-git-branch

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

# for golang
if [ -x "`which go`" ]; then
    export GOPATH=$HOME
    export GOBIN="$GOPATH/bin"
    export PATH="$GOBIN:$PATH"
fi

# for python
export PATH="$HOME/.pyenv/bin:$PATH"
pyenv() {
    unset -f pyenv
    if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
    # pyenv "$@"
}

# latex path
export PATH=/Library/Tex/texbin:$PATH

# zsh reload
alias reload='exec zsh -l'


autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/Cellar/terraform/0.11.14/bin/terraform terraform

#export PATH=/usr/local/opt/openssl@1.1/bin:$PATH

# jenv
export PATH="$HOME/.jenv/bin:$PATH"
jenv() {
    unset -f jenv
    eval "$(jenv init -)"
}

# openssl
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
#export PATH="$PATH:`pwd`/bin"

# gist user
export GIST_USER=chus0n

# powerline
#powerline-daemon -q
#. /Users/yuki/.pyenv/versions/3.8.2/lib/python3.8/site-packages/powerline/bindings/zsh/powerline.zsh
function powerline_precmd() {
  # -modules default "venv,user,host,ssh,cwd,perms,git,hg,jobs,exit,root"
  eval "$($GOPATH/bin/powerline-go -error $? -shell zsh -eval -hostname-only-if-ssh -modules venv,host,ssh,cwd,perms,git,hg,exit,root)"
}

function install_powerline_precmd() {
  for s in "${precmd_functions[@]}"; do
    if [ "$s" = "powerline_precmd" ]; then
      return
    fi
  done
  precmd_functions+=(powerline_precmd)
}

if [ "$TERM" != "linux" ]; then
  install_powerline_precmd
fi

if (which zprof > /dev/null 2>&1) ; then
  zprof
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
