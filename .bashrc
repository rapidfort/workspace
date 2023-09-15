alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias l='/bin/pwd ; /bin/ls -lrtAF --color=auto'
alias pd="pushd"
alias ppd="popd"
alias gs="git status"
alias gd="git diff"
alias gc="git commit"
alias gg='git log --all --decorate --oneline --graph'
alias ggl='git log --pretty=format:"[%h] %ae, %ar: %s" --stat'
alias gurl='git remote -v'
alias rfcmd='_rfcmd(){ docker run --rm --cap-add=SYS_PTRACE -it $@; } ; _rfcmd'
alias rfsh='_rfsh(){ docker run --rm --cap-add=SYS_PTRACE -it $@ /.rapidfort_RtmF/sh; } ; _rfsh'
alias rmi='docker rmi -f $(docker images -aq)'
alias kcontext='kubectl config get-contexts'
alias kscontext='kubectl config use-context'
alias wurl='_wurl(){curl -k -i -N -H "Connection: Upgrade" -H "Upgrade: websocket" https://$1/rfpubsub;}; _wurl'
alias flatj='_schema() { jq '\'' paths(scalars) | map(tostring) | join(".")'\'' $1; }; _schema'
alias flatjv='_schema1()
    { jq -r '\'' paths(scalars) as $p | [ ( [ $p[] | tostring ] | join(".") ), ( getpath($p) | tojson )] | join(" = ") '\'' $1; }; _schema1'
alias pretty_csv='_pc() { column -t -s, -n "$@" | less -F -S -X -K; }; _pc'
alias pyl='pylint --rcfile=~/.pylintrc'

if grep -q trux "/root/BUILD_USER_NAME" ; then
  export EDITOR=emacs
else
  export EDITOR=vim
fi

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
    else
    color_prompt=
    fi
fi

if test -s ~/my_ip_address.txt ; then
    cp -vf ~/my_ip_address.txt /tmp/my_ip_address.txt
elif test -s /opt/rapidfort/.rf_app_host ; then
    cp -vf /opt/rapidfort/.rf_app_host /tmp/my_ip_address.txt
elif cat /proc/net/dev | grep -Eo '^[^:]+' | grep tailscale0; then
    echo $(tailscale ip -4) > /tmp/my_ip_address.txt
else
    netif=$(ip link show | grep 'state UP' | cut -d':' -f2 | awk '{print $1}' | egrep -v '(veth|lo|veth|br|tailscale|docker)' | tail -1)
    echo $(ip addr show $netif | grep -oE 'inet [0-9.]+' | awk '{print $2}') > /tmp/my_ip_address.txt
fi

export RF_APP_HOST=$(cat /tmp/my_ip_address.txt)

CLUSTER=$(kubectl config get-contexts | grep '*' | awk '{print$2}' | cut -d'-' -f2)

if test -z "${CLUSTER}"; then
    export KCONTEXT=$(echo [$CLUSTER])
else
    export KCONTEXT=
fi

if test -z "$HOME" ; then
    export HOME=/root
fi

if test ! -s $HOME/.git-prompt.sh ; then
    curl -Lo $HOME/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
fi

source $HOME/.git-prompt.sh

if [ "$TERM" = "dumb" ] ; then
     PS1="> "
elif [ "$color_prompt" = yes ]; then
    PS1='${KCONTEXT}[${RF_APP_HOST}] ${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]\[\033[33m\]$(__git_ps1)\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\#\n'
else
    PS1='${KCONTEXT}[${RF_APP_HOST}] ${debian_chroot:+($debian_chroot)}\u@\h$(__git_ps1):\w\#\n'
fi
unset color_prompt force_color_prompt

export HISTFILESIZE=

# MEF: So that screen window names dont revert
unset PROMPT_COMMAND

export TERM=xterm-256color
export PATH=$PATH:/usr/local/bin:/usr/local/go/bin:/opt/rapidfort/common:$HOME/.local/bin:/usr/local/musl/bin
export PATH=$PATH:/usr/local/go/bin
export PYTHONPATH=$PYTHONPATH:/root/rapidfort/package-analyzer/app:/root/rapidfort/rapidrisk/Python:/root/rapidfort/common

[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases
[ -f ~/.docker_aliases ] && source ~/.docker_aliases
[ -f ~/.git_aliases ] && source ~/.git_aliases
[ -f ~/.my_aliases ] && source ~/.my_aliases

module_log() {
    until kubectl logs -f -l app.kubernetes.io/name=$1
    do
        sleep 1
    done
    exec bash
}
export -f module_log

git config --global diff.tool vimdiff
git config --global merge.tool vimdiff
git config --global difftool.prompt false
