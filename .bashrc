# Exit if non-interactive, e.g. scp
if [ -z "$PS1" ]; then
    return
fi

BLUE='\033[1;31m'
NC='\033[0m'

#export PS1="${BLUE}$ ${NC}"
export PS1="$ "

# if [[ -z "$TMUX" ]] && [ "$SSH_CONNECTION" != "" ]; then
#     tmux attach-session -t ssh_tmux || tmux new-session -s ssh_tmux
# fi

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin:/usr/local/go/bin:/usr/local/kubebuilder/bin/

eval "$(lua ~/z.lua --init bash enhanced once fzf)"

set -o vi
export EDITOR=vi

alias v="nvim ."
alias vim="nvim"
alias vims="nvim -S ~/.vim/sessions/curr.vim"

# add kubectl completions to k
complete -o default -F __start_kubectl k

function g() {
    rg -i $@ -g '!vendor*' -g '*.go'
}

function r() {
    rg -i $@ -g '!vendor*'
}

function f() {
    find . -iname $@ | grep -v vendor | grep -v node_modules
}

function kenv() {
    export KUBECONFIG=$1
}

function kc() {
    k config current-context
}

function kcur-ctx() {
  k config current-context
}

function diskusage() {
    sudo du -h / | grep '[0-9\.]\+G'
}

alias kget="get_aks_kubeconfig"

function get_aks_kubeconfig {
  pushd ~/go/src/goms.io/acsrp
  cluster_id=$2
  source ~/go/src/goms.io/acsrp/hcp/prodenv/envrc-$1-cx-default
  make -f ~/go/src/goms.io/acsrp/Makefile.hcp download-kubeconfig

  export KUBECONFIG=~/.kube/config.hcp-underlay-$1-$2
  popd
}

function kx {
    pod=`k get pods -n monitoring -l app=cpmonitor | grep Running | awk '{print $1}'`
    set -x
    k exec -it -n monitoring $pod -- /bin/bash
    set +x
}

function kcp {
    pod=`k get pods -n monitoring -l app=cpmonitor | grep Running | awk '{print $1}'`
    set -x
    k cp -n monitoring $1 $pod:$2
    set +x
}

function kl {
    pod=`k get pods -n monitoring -l app=cpmonitor | grep Running | awk '{print $1}'`
    set -x
    k logs -n monitoring $pod
    set +x
}

source <(kubectl completion bash)

function agent {
    eval `ssh-agent`
    ssh-add ~/.ssh/id_rsa.vsts
}


alias c="clear"
alias e="echo"
alias cb="cd -"
alias la="ls -alh"

alias ic="ifconfig"
alias sic="sudo ifconfig"

alias gs="git status"
alias ga="git add"
alias gap="git add -p"
alias gau="git add -u"
alias gm="git commit -m "
alias gam="git add -u; git commit -m"
alias grr="git add -u; git commit --amend --no-edit"
alias gd="git diff --color"
alias gds="git diff --staged --color"
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
alias grbx="git rebase -i HEAD~10"
alias grbxx="git rebase -i HEAD~20"
alias gba="git branch -a"
alias gcp="git cherry-pick"
alias gst="git stash"
alias gstp="git stash pop"
alias ggrep="git grep -i --color --break --heading --line-number"
alias grmba="git fetch --all --prune && git remote prune origin; git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -D"

alias fgrep="find . | grep"
alias sfgrep="sudo find . | grep"

alias vbm="VBoxManage"

alias dl="diskutil list"
alias tmp="mkdir /tmp/test;cd /tmp/test"

alias sni="sudo node index.js"
alias snid="sudo node debug index.js"
alias ni="node index.js"
alias nid="node debug index.js"
alias nr="cd ~/.noderepl;node ~/.noderepl/repl.js;cd -"

alias nd="node debug"
alias m="mocha"
alias viewcover="./node_modules/.bin/istanbul report html; open coverage/index.html"

alias d="docker"

export LESS="IRN"

# quick aliasing for repetitive, but throwaway, tasks
function a() {
    alias $1="${*:2}"
    echo "Set up alias $1=\"${*:2}\""
}

function buildcpmonitor() {
    az pipelines build queue --definition-name "AKS cpmonitor build" --branch $(git rev-parse --abbrev-ref HEAD) > ~/.buildvsts
    echo "https://msazure.visualstudio.com/CloudNativeCompute/_build/results?buildId=$(cat ~/.buildvsts | jq '.id')"
    cat ~/.buildvsts | jq '.id'
}

function buildlogging() {
    az pipelines build queue --definition-name "AKS logging build" --branch $(git rev-parse --abbrev-ref HEAD) > ~/.buildvsts
    echo "https://msazure.visualstudio.com/CloudNativeCompute/_build/results?buildId=$(cat ~/.buildvsts | jq '.id')"
    echo "https://dev.azure.com/msazure/CloudNativeCompute/_release?definitionId=112&view=mine&_a=releases"
    # cat ~/.buildvsts | jq '.id'
}

function buildrem() {
    az pipelines build queue --definition-name "AKS remediator build" --branch $(git rev-parse --abbrev-ref HEAD) > ~/.buildvsts
    echo "https://msazure.visualstudio.com/CloudNativeCompute/_build/results?buildId=$(cat ~/.buildvsts | jq '.id')"
    cat ~/.buildvsts | jq '.id'
}

# Remove vim swap files
alias rmswap="find . -name '*sw[m-p]'|xargs rm"
alias rmswapn="find ~/.local/share/nvim/swap/ -name '*sw[m-p]' | xargs rm"

alias goog="ping 8.8.8.8"
alias cf="ping 1.1.1.1"

function mkcd() {
    mkdir $1
    cd $1
}

function vmode() {
    if [[ "$1" == "on" ]];
    then
        set -o vi
    else
        set +o vi
    fi
}

function cu() {
    if [[ -z "$1" ]];
    then
        cd ..
    else
        for ((i=1; i<=$1;i++))
        do
            cd ..
        done
    fi
}

function md() {
    if [[ -z "$2" ]];
    then
        mdfind "$1"
    else
        mdfind "$1" -onlyin "$2"
    fi
}

function gld() {
    branch=`git branch | awk '/\*/ {print $2;}'`
    # glg is an alias defined above
    glg master..$branch
}

function gp() {
    branch=`git branch | awk '/\*/ {print $2;}'`
    if [[ -z "$1" ]];
    then
        if [[ "$branch" = "master" ]];
        then
            echo "You almost pushed to master!"
            echo "ABORTED: tried to push to master!"
            return
        fi
        git push origin $branch
    else
        if [[ "$1" = "-f" ]];
        then
            if [[ "$branch" = "master" ]];
            then
                echo "You almost force pushed to master!"
                echo "ABORTED: tried to force push to master!"
            else
                echo "Are you sure you want to force push to $branch?"
                read -p "(y/n): " confirm
                if [[ "$confirm" = "y" ]];
                then
                    git push origin $branch --force
                else
                    echo "Canceled"
                fi
            fi
        else
            git push origin $branch $1
        fi
    fi
}

function gsh() {
    if [[ -z "$1" ]];
    then
        sha=`git rev-parse HEAD`
    else
        sha=`git rev-parse HEAD~$1`
    fi
    git show $sha
}

function gitcl() {
    git clone git@github.com:$1
}

alias brc="vi ~/dotfiles/.bashrc; cp ~/dotfiles/.bashrc ~;source ~/.bashrc"
alias bri="vi ~/dotfiles/.inputrc; cp ~/dotfiles/.inputrc ~; bind -f ~/.inputrc"
alias brcp="vi ~/.bashrc.private; source ~/.bashrc"

alias ple="pylint -E"
function plw { pylint "$1" | grep W: ; }
function plc { pylint "$1" | grep C: ; }
export -f plw
export -f plc


verbose_commands=0

function cd_and_ls() {
    cd $1
    ls
}

function vv() {
    let verbose_commands=($verbose_commands+1)%2
    if [ $verbose_commands -eq 1 ]; then
        echo "verbose commands on"
        alias cd="cd_and_ls"
        alias ls="ls -lah"
    else
        echo "verbose commands off"
        unalias cd
        unalias ls
    fi
}

alias scf="vi ~/.ssh/config"
alias skr="ssh-keygen -R"
alias edithosts="sudo vi /etc/hosts"


# borrowed from
# http://stackoverflow.com/questions/18880024/start-ssh-agent-on-login
# SSH_ENV="$HOME/.ssh/environment"
# 
# function start_agent {
#     echo "Initialising new SSH agent..."
#     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
#     echo succeeded
#     chmod 600 "${SSH_ENV}"
#     . "${SSH_ENV}" > /dev/null
#     /usr/bin/ssh-add;
#     /usr/bin/ssh-add ~/.ssh/id_rsa.vsts;
#     # /usr/bin/ssh-add ~/.ssh/id_rsa.github;
# }
# 
# # Source SSH settings, if applicable
# 
#  if [ -f "${SSH_ENV}" ]; then
#      . "${SSH_ENV}" > /dev/null
#      #ps ${SSH_AGENT_PID} doesn't work under cywgin
#      ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
#          start_agent;
#      }
# else
#     start_agent;
# fi
###

_ssh_auth_save() {
    ln -sf "$SSH_AUTH_SOCK" "$HOME/.ssh/ssh-auth-sock.$HOSTNAME"
}
alias tmux='_ssh_auth_save ; export HOSTNAME=$(hostname) ; tmux'

if [ -e ~/.bashrc.private ]
then
    source ~/.bashrc.private
fi

function dir {
    if [ -d $1 ];
    then
        pushd $1
        ${@:2}
        popd
    else 
        echo "Directory $1 does not exist."
    fi
}

# From https://superuser.com/a/285400
function print_colors {
    for i in {0..255}; do
        printf "\x1b[38;5;${i}mcolour${i}\x1b[0m\n"
    done
}

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

zsh
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/usr/local/kubebuilder/kubebuilder_2.3.1_linux_amd64/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/usr/local/kubebuilder/kubebuilder_2.3.1_linux_amd64/bin
export PATH=$PATH:/usr/local/kubebuilder/kubebuilder_2.3.1_linux_amd64/bin
export PATH=$PATH:/usr/local/kubebuilder/bin
export PATH=$PATH:/usr/local/kubebuilder/bin
export PATH=$PATH:/usr/local/kubebuilder/bin
export PATH=$PATH:/usr/local/kubebuilder/bin
export PATH=$PATH:/usr/local/kubebuilder/bin
export PATH=$PATH:/usr/local/kubebuilder/bin
export PATH=$PATH:/usr/local/kubebuilder/bin
export PATH=$PATH:/usr/local/kubebuilder/bin
export PATH=$PATH:/usr/local/kubebuilder/bin
export PATH=$PATH:/usr/local/kubebuilder/bin
export PATH=$PATH:/usr/local/kubebuilder/bin
export PATH=$PATH:/usr/local/kubebuilder/bin
. "$HOME/.cargo/env"

[[ -s "/home/ben/.gvm/scripts/gvm" ]] && source "/home/ben/.gvm/scripts/gvm"

export PATH=$PATH:/home/ben/bin

source '/home/ben/lib/azure-cli/az.completion'
