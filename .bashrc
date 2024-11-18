# .bashrc
umask 022
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

alias rfcmd='_rfcmd(){ docker run --rm  --cap-add=SYS_PTRACE -it $@; } ; _rfcmd'
alias rfcmde='_rfcmde(){ docker run --rm --entrypoint= --cap-add=SYS_PTRACE -it $@; } ; _rfcmde'
alias rfsh='_rfsh(){ docker run --rm --cap-add=SYS_PTRACE -it $@ /.rapidfort_RtmF/sh; } ; _rfsh'
alias rmi='docker rmi -f $(docker images -aq)'

alias kcontext='kubectl config get-contexts || echo "no-kcontext"'
alias kscontext='kubectl config use-context || echo "no-kscontext"'
alias kscontext='_ksc() { [ -z $1 ] || kubectl config use-context $1 && echo "no-kscontext";}; _ksc'

alias flatj='_schema() { jq '\'' paths(scalars) | map(tostring) | join(".")'\'' $1; }; _schema'
alias flatjv='_schema1()
    { jq -r '\'' paths(scalars) as $p | [ ( [ $p[] | tostring ] | join(".") ), ( getpath($p) | tojson )] | join(" = ") '\'' $1; }; _schema1'
alias pretty_csv='_pc() { column -t -s, -n "$@" | less -F -S -X -K; }; _pc'
alias pyl='pylint --rcfile=~/.pylintrc --overgeneral-exceptions=builtins.BaseException,builtins.Exception'
alias bdo='./build.sh deploy_onprem'

alias rfstart='/root/rapidfort/standalone/rf_run_unrun.sh run'
alias rfstop='/root/rapidfort/standalone/rf_run_unrun.sh unrun'

# Setting some default values first
export PYTHONPATH=/root/rapidfort/common:/root/rapidfort/package-analyzer/app


# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

if test -z "$HOME" ; then
  export HOME=/root
fi

if [ -f /root/.git-prompt.sh ]; then
  source /root/.git-prompt.sh
fi

export TERM=xterm-256color
## avoid infinite catenation when a script sources .bashrc in a loop
if ! echo "$PATH" | grep /usr/local/go/bin | grep -q /usr/local/musl/bin ; then
  export PATH=$PATH:/usr/local/bin:/usr/local/go/bin:/opt/rapidfort/common:$HOME/.local/bin:/usr/local/musl/bin
fi

## RF_LOGIN and RF_PASSWORD are set in .bashrc.rfserver
## which is created by init.sh
if [ -f /root/.user_data ]; then
  # . /root/.user_data
  source <(cat /root/.user_data | sed "s=#.*==g" | grep = | sed "s=^=export =g")
fi

if [ -f ~/.bashrc.rfserver ]; then
  . ~/.bashrc.rfserver
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

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

# export RF_APP_HOST=$(ip link | grep -E "^[0-9]+:\s+[a-zA-Z0-9]+:\s+" |  egrep -v '(veth|tailscale|lo|docker0)' | awk '{print $2}' | xargs -I {} sh -c 'ip addr show dev {} | grep -w "inet" | awk '\''{print $2}'\'' | cut -f1 -d/')
# echo $RF_APP_HOST > /tmp/my_ip_address.txt

# MEF: Get our external IP and show it in the prompt...
# export MY_EXTERNAL_IP=$(curl -s ipinfo.io/ip)
if ! test -s /tmp/my_ip_address.txt ; then
  if test -s ~/my_ip_address.txt ; then
    cp -f ~/my_ip_address.txt /tmp/my_ip_address.txt
  elif test -s /opt/rapidfort/.rf_app_host ; then
    cp -f /opt/rapidfort/.rf_app_host /tmp/my_ip_address.txt
  else
    if ip link ls dev tailscale0 | grep -q tailscale0: ; then
      export IPADDR=$(ip addr ls dev tailscale0 | awk '{print $1 " " $2}' | grep "^inet " | sed "s=/.*==g" | awk '{print $2}' | tr -d "[:space:]")
    fi
    if test -z "$IPADDR" ; then
      export IPADDR=$(ip route ls | grep "^default" | sed "s=.*\ dev\ ==g" | awk '{print "ip addr ls " $1}' | sh | awk '{print $1 " " $2}' | grep -w "^inet" | awk '{print $2}' | sed "s=/.*==g" | head -1 | tr -d "[:space:]")
    fi
    echo "$IPADDR" > /tmp/my_ip_address.txt
    test -s /tmp/my_ip_address.txt || rm -f /tmp/my_ip_address.txt
    test -s /tmp/my_ip_address.txt && cp -f /tmp/my_ip_address.txt ~/my_ip_address.txt
  fi
fi

export MY_EXTERNAL_IP=$(cat /tmp/my_ip_address.txt || echo $RF_APP_HOST)

CLUSTER=$(which kubectl > /dev/null && kubectl config get-contexts | grep '*' | awk '{print $2}' | cut -d'-' -f2 || echo "no-cluster")
if test -n "${CLUSTER}"; then
  export KCONTEXT="[$CLUSTER]"
else
  export KCONTEXT=
fi

if test -s /etc/bash_completion.d/git-prompt; then
    source /etc/bash_completion.d/git-prompt
else
    test -s /usr/share/bash-completion/bash_completion && source /usr/share/bash-completion/bash_completion || true
fi

GIT_PS1_SHOWDIRTYSTATE=true
GIT_PS1_SHOWUNTRACKEDFILES=true
export PS1='\u@\h \w$(__git_ps1) \#'

if [ "$TERM" = "dumb" ] ; then
     PS1="> "
elif [ "$color_prompt" = yes ]; then
    # MEF: Show public IP in prompt
    PS1='${KCONTEXT}[${MY_EXTERNAL_IP}] ${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]\[\033[33m\]$(__git_ps1)\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$\n'
else
    #PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    # MEF: Show public IP in prompt
    PS1='${KCONTEXT}[${MY_EXTERNAL_IP}] ${debian_chroot:+($debian_chroot)}\u@\h$(__git_ps1):\w\$\n'
fi
unset color_prompt force_color_prompt

export HISTFILESIZE=

# MEF: So that screen window names dont revert
unset PROMPT_COMMAND

if [ -f ${HOME}/.kubectl_aliases ]; then
      . ${HOME}/.kubectl_aliases
fi

alias fileupload='kubectl exec -it $(kubectl get pods | grep fileupload | head -1 | awk '\''{print $1}'\'') -c fileupload -- bash'
alias rfapi='kubectl exec -it $(kubectl get pods | grep rfapi | head -1 | awk '\''{print $1}'\'') -c rfapi -- bash'
alias rfpubsub='kubectl exec -it $(kubectl get pods | grep rfpubsub | head -1 | awk '\''{print $1}'\'') -c rfpubsub -- bash'
alias runner='kubectl exec -it $(kubectl get pods | grep runner | head -1 | awk '\''{print $1}'\'') -c runner -- bash'
alias rfvdb='kubectl exec -it $(kubectl get pods | grep rfvdb | head -1 | awk '\''{print $1}'\'') -c rfvdb -- bash'
alias aggregator='kubectl exec -it $(kubectl get pods | grep aggregator | head -1 | awk '\''{print $1}'\'') -c aggregator -- bash'
alias isomaster='kubectl exec -it $(kubectl get pods | grep iso.master | head -1 | awk '\''{print $1}'\'') -c iso-master -- bash'
alias iso-master='kubectl exec -it $(kubectl get pods | grep iso.master | head -1 | awk '\''{print $1}'\'') -c iso-master -- bash'
alias rf-scan='kubectl exec -it $(kubectl get pods | grep rf.scan | head -1 | awk '\''{print $1}'\'') -c rf-scan -- bash'
alias vulns-db='kubectl exec -it $(kubectl get pods | grep vulns-db | head -1 | awk '\''{print $1}'\'') -c vulns-db -- bash'
alias frontrow='kubectl exec -it $(kubectl get pods | grep frontrow | head -1 | awk '\''{print $1}'\'') -c frontrow -- sh'
alias backend='kubectl exec -it $(kubectl get pods | grep backend | head -1 | awk '\''{print $1}'\'') -c backend -- bash'
alias redis='kubectl exec -it $(kubectl get pods | grep redis | head -1 | awk '\''{print $1}'\'') -- bash'
alias keycloak='kubectl exec -it $(kubectl get pods | grep keycloak | head -1 | awk '\''{print $1}'\'') -c keycloak -- bash'
alias mysql='kubectl exec -it $(kubectl get pods | grep mysql | head -1 | awk '\''{print $1}'\'') -c mysql -- bash'
alias vmorchestrator='kubectl exec -it $(kubectl get pods | grep cloudvm-orchestrator | head -1 | awk '\''{print $1}'\'') -c cloudvm-orchestrator -- bash'
alias mysqldb='kubectl exec -it $(kubectl get pods | grep mysql | head -1 | awk '\''{print $1}'\'') -- mysql -u root --password="RF-123579" standalone'

alias fileupload_log='kubectl logs -f -c fileupload $(kubectl get pods | grep fileupload | head -1 | awk '\''{print $1}'\'')'
alias rfapi_log='kubectl logs -f -c rfapi $(kubectl get pods | grep rfapi | head -1 | awk '\''{print $1}'\'')'
alias rfpubsub_log='kubectl logs -f -c rfpubsub $(kubectl get pods | grep rfpubsub | head -1 | awk '\''{print $1}'\'')'
alias runner_log='kubectl logs -f -c runner $(kubectl get pods | grep runner | head -1 | awk '\''{print $1}'\'')'
alias rfvdb_log='kubectl logs -f -c rfvdb $(kubectl get pods | grep rfvdb | head -1 | awk '\''{print $1}'\'')'
alias aggregator_log='kubectl logs -f -c aggregator $(kubectl get pods | grep aggregator | head -1 | awk '\''{print $1}'\'')'
alias isomaster_log='kubectl logs -f -c iso-master $(kubectl get pods | grep iso.master | head -1 | awk '\''{print $1}'\'')'
alias rf-scan_log='kubectl logs -f -c rf-scan $(kubectl get pods | grep rf.scan | head -1 | awk '\''{print $1}'\'')'
alias frontrow_log='kubectl logs -f -c frontrow $(kubectl get pods | grep frontrow | head -1 | awk '\''{print $1}'\'')'
alias backend_log='kubectl logs -f -c backend $(kubectl get pods | grep backend | head -1 | awk '\''{print $1}'\'')'
alias redis_log='kubectl logs -f $(kubectl get pods | grep redis | head -1 | awk '\''{print $1}'\'')'
alias keycloak_log='kubectl logs -f $(kubectl get pods | grep keycloak | head -1 | awk '\''{print $1}'\'')'
alias vmorchestrator_log='kubectl logs -f -c cloudvm-orchestrator $(kubectl get pods | grep cloudvm-orchestrator | head -1 | awk '\''{print $1}'\'')'

alias rfapi_debug='_rfapi_debug() {
    touch /root/funct/RF_DEBUG_rfapi
    /root/rapidfort/standalone/rapidfort.sh start
    podname=$(kubectl get po --sort-by=.metadata.creationTimestamp | tac | grep rfapi | head -1 | awk '\''{print $1}'\'')
    kubectl exec -it $podname -c rfapi -- bash
}; _rfapi_debug'

alias rfpubsub_debug='_rfpubsub_debug() {
    touch /root/funct/RF_DEBUG_rfpubsub
    /root/rapidfort/standalone/rapidfort.sh start
    podname=$(kubectl get po --sort-by=.metadata.creationTimestamp | tac | grep rfpubsub | head -1 | awk '\''{print $1}'\'')
    kubectl exec -it $podname -c rfpubsub -- bash
}; _rfpubsub_debug'

alias runner_debug='_runner_debug() {
    touch /root/funct/RF_DEBUG_runner
    /root/rapidfort/standalone/rapidfort.sh start
    podname=$(kubectl get po --sort-by=.metadata.creationTimestamp | tac | grep runner | head -1 | awk '\''{print $1}'\'')
    kubectl exec -it $podname -c runner -- bash
}; _runner_debug'

alias rfvdb_debug='_rfvdb_debug() {
    touch /root/funct/RF_DEBUG_rfvdb
    /root/rapidfort/standalone/rapidfort.sh start
    podname=$(kubectl get po --sort-by=.metadata.creationTimestamp | tac | grep rfvdb | head -1 | awk '\''{print $1}'\'')
    kubectl exec -it $podname -c rfvdb -- bash
}; _rfvdb_debug'

alias aggregator_debug='_aggregator_debug() {
    touch /root/funct/RF_DEBUG_aggregator
    /root/rapidfort/standalone/rapidfort.sh start
    podname=$(kubectl get po --sort-by=.metadata.creationTimestamp | tac | grep aggregator | head -1 | awk '\''{print $1}'\'')
    kubectl exec -it $podname -c aggregator -- bash
}; _aggregator_debug'

alias isomaster_debug='_isomaster_debug() {
    touch /root/funct/RF_DEBUG_iso-master
    /root/rapidfort/standalone/rapidfort.sh start
    podname=$(kubectl get po --sort-by=.metadata.creationTimestamp | tac | grep iso.master | head -1 | awk '\''{print $1}'\'')
    kubectl exec -it $podname -c iso-master -- bash
}; _isomaster_debug'

alias backend_debug='_backend_debug() {
    touch /root/funct/RF_DEBUG_backend
    /root/rapidfort/standalone/rapidfort.sh start
    podname=$(kubectl get po --sort-by=.metadata.creationTimestamp | tac | grep backend | head -1 | awk '\''{print $1}'\'')
    kubectl exec -it $podname -c backend -- bash
}; _backend_debug'

alias frontrow_debug='_frontrow_debug() {
    touch /root/funct/RF_DEBUG_frontrow
    /root/rapidfort/standalone/rapidfort.sh start
    podname=$(kubectl get po --sort-by=.metadata.creationTimestamp | tac | grep frontrow | head -1 | awk '\''{print $1}'\'')
    kubectl exec -it $podname -c frontrow -- sh
}; _frontrow_debug'


## git config is done in init.sh

if grep -q -e trux -e bright "/root/BUILD_USER_NAME" ; then
  export EDITOR=emacs
else
  export EDITOR=vim
fi

module_log() {
    until kubectl logs -f -l app.kubernetes.io/name=$1
    do
        sleep 1
    done
    exec bash
}

export -f module_log

if test -s $HOME/.my_aliases ; then
    set -a
    source $HOME/.my_aliases
    set +a
fi


alias rftools="/root/rapidfort/functional-tests/helpers/install.sh"