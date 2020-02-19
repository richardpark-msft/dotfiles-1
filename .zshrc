if [ "$TMUX" = "" ]; then
    tmux attach-session -t wsl_tmux || tmux new-session -s wsl_tmux;
fi

export TERM=xterm-256color

# Load Antigen
source ~/antigen.zsh
# Load Antigen configurations
antigen init ~/.antigenrc

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin:/usr/local/go/bin:/usr/local/kubebuilder/bin
export PATH=$PATH:~/.local/lib/python2.7/site-packages
export PATH=$PATH:/snap/bin

# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle :compinstall filename '/home/ben/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=1000
setopt autocd extendedglob
bindkey -v
# End of lines configured by zsh-newuser-install

### --------------- Custom ------------------

# autoload -U colors && colors
# autoload -U promptinit && promptinit

# Reset command output to normal font
preexec() { printf "\e[0m"; }

function insert-mode () { echo "%F{blue}⇉ ⇉ ⇉" }
function normal-mode () { echo "%F{green}↘ ↘ ↘" }

function set-prompt () {
    case ${KEYMAP} in
      (vicmd)      VI_MODE="$(normal-mode)" ;;
      (main|viins) VI_MODE="$(insert-mode)" ;;
      (*)          VI_MODE="$(insert-mode)" ;;
    esac
    # Space is a non-breaking space to support reverse prompt navigation
    PS1="$VI_MODE %F{yellow}"
}

function zle-line-init zle-keymap-select {
    set-prompt
    zle reset-prompt
}

# preexec () { print -rn -- $terminfo[el]; }

zle -N zle-line-init
zle -N zle-keymap-select

# export KEYTIMEOUT=3

function reloadrc() {
    source ~/.zshrc
}
zle -N reloadrc

bindkey -M viins 'jk' vi-cmd-mode 
bindkey -M viins ',d' reloadrc
#bindkey -M viins ',r' history-incremental-pattern-search-backward
bindkey -M viins ',r' zaw-history
bindkey -M vicmd ',r' zaw-history
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

eval "$(lua ~/z.lua --init zsh)"

alias vim="nvim"

alias freeram="sudo sync ; echo 3 | sudo tee /proc/sys/vm/drop_caches"

function run-with-less() {
    BUFFER+=" | less"
    zle accept-line
}
function run-with-rg() {
    BUFFER+=" | rg -i "
    zle end-of-line
}
zle -N run-with-less
zle -N run-with-rg
bindkey -M viins ',l' run-with-less
bindkey -M vicmd ',l' run-with-less
bindkey -M viins ',g' run-with-rg
bindkey -M vicmd ',g' run-with-rg

function r() {
    rg -i $@ -g '!vendor*'
}

function gr() {
    rg -i $@ -g '!vendor*' -g '*.go'
}

function f() {
    find . -iname $@
}

alias gs="git status"
alias ga="git add"
alias gap="git add -p"
alias gau="git add -u"
alias gm="git commit -m "
alias gam="git add -u; git commit -m"
alias grr="git add -u; git commit --amend --no-edit"
alias gd="git diff --color"
alias gdc="git diff --color -U0"
alias gco="git checkout"
alias gcob="git checkout -b"
alias gl="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit -n10"
alias glg="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit"
alias gpo="git push origin"
alias gpl="git fetch --all --prune; git pull --rebase"
alias gf="git fetch --all --prune"
alias gre="git remote"
alias grei="git rebase -i"
alias grb2="git rebase -i HEAD~2"
alias grb3="git rebase -i HEAD~3"
alias grb5="git rebase -i HEAD~5"
alias gba="git branch -a"
alias gcp="git cherry-pick"
alias gst="git stash"
alias gstp="git stash pop"
alias ggrep="git grep -i --color --break --heading --line-number"


# ----- Kubectl ----- 


function kc() {
    export KUBECONFIG="$1"
}

alias kd=k3d
alias k=kubectl
source <(k completion zsh)
#alias k=microk8s.kubectl
#sudo snap alias microk8s.kubectl mk
alias kde='export KUBECONFIG="$(k3d get-kubeconfig)"'

# source <(kubectl completion zsh)
#source <(mk completion zsh | sed "s/kubectl/mk/g")

# Validator/ctrlarm
alias kgv='k get validators'
alias kdelv='k delete validators'
alias kgm='k get managedclusters'
alias kdelm='k delete managedclusters'
alias kgvo='k get validators --all -o yaml'
alias kgmo='k get managedclusters --all -o yaml'

# Logs
alias kl='k logs'
alias klf='k logs -f'

# Namespace management
alias kgns='k get namespaces'
alias kens='k edit namespace'
alias kdns='k describe namespace'
alias kdelns='k delete namespace'
alias kcn='k config set-context $(k config current-context) --namespace'

# Pod management
alias kgp='k get pods'
alias kgpw='kgp --watch'
alias kgpwide='kgp -o wide'
alias kep='k edit pods'
alias kdp='k describe pods'
alias kdelp='k delete pods'

# General aliases
alias kdel='k delete'
alias kdelf='k delete -f'

# Apply a YML file
alias kaf='k apply -f'

# Drop into an interactive terminal on a container
alias keti='k exec -ti'


function kns() {
    k config set-context --current --namespace=$1
}

funcion ku() {
    kustomize build $1
}

funcion kue() {
    kustomize build $1 | envsubst | kubectl apply -f -
}

funcion kua() {
    kustomize build $1 | kubectl apply -f -
}

funcion kud() {
    kustomize build $1 | kubectl delete -f -
}

function col() {
    cmd='{print $'$1}
    cat - | awk $cmd
}

function load-git-keys() {
    eval `ssh-agent` > /dev/null 2>&1
    ssh-add ~/.ssh/id_rsa.vsts > /dev/null 2>&1
    ssh-add ~/.ssh/id_rsa.github.2 > /dev/null 2>&1
}

load-git-keys 
