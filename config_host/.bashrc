# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

export TERM=xterm-color
# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm|xterm-color|*-256color) color_prompt=yes;;
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

if [ "$color_prompt" = yes ]; then
    if [[ ${EUID} == 0 ]] ; then
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
    else
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]\w \$\[\033[00m\] '
    fi
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h \w \$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h \w\a\]$PS1"
    ;;
*)
    ;;
esac


DIR_FUNCTION="/opt/ffx/scripts/functions/"
if [ -e "$DIR_FUNCTION" ] ; then
	for f in $DIR_FUNCTION/* ; do
	   . $f
	done
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

if [ -x /usr/bin/mint-fortune ]; then
     /usr/bin/mint-fortune
fi

export HOSTALIASES='/etc/hosts.aliases'
export http_proxy="http://localhost:3128"
export https_proxy="http://localhost:3128"

#export PS1="[ \t ] \[$(tput sgr0)\]\[\033[38;5;196m\]\u@\h\[$(tput sgr0)\]\[\033[38;5;15m\]:\[$(tput sgr0)\]\[\033[38;5;196m\]\w:\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"
export PS1="\[$(tput bold)\]\[$(tput setaf 0)\]\t \[$(tput setaf 0)\][\[$(tput setaf 1)\]\u\[$(tput setaf 1)\]@\[$(tput setaf 1)\]\h \[$(tput setaf 1)\]\W\[$(tput setaf 0)\]]\[$(tput setaf 0)\]\\$ \[$(tput sgr0)\]"

# Common commandfs
alias ls='ls --color=auto'
alias ll='ls --color=auto -l'
alias l='ll'
alias gethost='getent hosts'
alias setproxy='export https_proxy="http://localhost:3128/" ; export https_proxy="http://localhost:3128/"'
alias viprofile='vim ~/.bashrc'

# Docker
alias cdfunctions='cd /opt/ffx/scripts/functions'
alias cddocker='cd /opt/ffx/docker'
alias cdscripts='cd /opt/ffx/scripts'
alias cdsystem='cd /opt/ffx/systems'
alias cdfunction='cd /opt/ffx/scripts/functions'
alias cddata='cd /data/docker/'
alias dp="docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}'"
alias dri='docker rmi'
alias di='docker images'
alias dvl='docker volume ls'
alias dvr='docker volume rm'

# Get container IP
alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
#TMUX2.3#
alias attachmux='tmux -2 attach -t '
alias lsmux='tmux list-sessions'
alias newmux='tmux -2 -f /etc/tmux.conf.d/tmux.conf new -s '
alias reloadmux='tmux source-file /etc/tmux.conf.d/tmux.conf'
alias vimux='vim /etc/tmux.conf.d/tmux.conf'

#Git
alias git='git'
alias gp='git push'
alias gpull='git pull'
alias gc="git commit -a "
alias gs='git status -s'
alias gdiff='git diff --color=always'
alias ga='git add'


function ds () {
    docker start $1
}

function dk () {
    docker stop $1
}

function drun () {
    if [ $# -lt 2 ] ; then
        echo "Usage : drun \$image \$hostname"
        return 1
    fi
    vip=$(getent hosts $2)
    if [ ! -z $vip ]; then
       extra_options="$extra_options --publish-all=true"
    fi
    docker run -d -it $extra_options --name $2 $1 bash
    cp /opt/ffx/systems/ubuntu/etc/systemd/system/docker.template /etc/systemd/system/docker-$2.service
    sed -i "s/container/$2/" /etc/systemd/system/docker-$2.service
}

function dr () {
    docker rm -f -v $1 && {
	if [ -e "/etc/systemd/system/docker-$1.service" ]; then
		rm /etc/systemd/system/docker-$1.service
		systemctl daemon-reload
		systemctl reset-failed
	fi
    }
}

db() { docker build --build-arg https_proxy=$https_proxy --build-arg http_proxy=$http_proxy -t=$1 .; }
dalias() { alias | grep 'docker' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort; }


export PS1="\[$(tput bold)\]\[$(tput setaf 0)\]\t \[$(tput setaf 0)\][\[$(tput setaf 1)\]\u\[$(tput setaf 1)\]@\[$(tput setaf 1)\]\h \[$(tput setaf 1)\]\W\[$(tput setaf 0)\]]\[$(tput setaf 0)\]\\$ \[$(tput sgr0)\]"


# Global alias
alias cdscript='cd /opt/ffx/scripts'
alias cdplugins='cd /usr/lib/nagios/plugins/'
alias cddownloads='cd /data/docker/samba/samba-basic/shares/downloads/'
#### Alias Sesction ####
alias ll='ls -l'
alias la='ls -ltra'
alias less='less -r'

alias h='history'
alias j='jobs -l'

## Editor ###
alias vi=vim
alias vis='vim "+set si"'
alias edit='vim'


alias fastping='ping -c 100 -s.2'
 
# get web server headers #
alias header='curl -I'
 
# find out if remote server supports gzip / mod_deflate or not #
alias headerc='curl -I --compress'



alias tcpdump='tcpdump -i'

case `uname -s` in
	Linux)

	# display all rules #
	## Colorize the grep command output for ease of use (good for log files)##
	alias grep='grep --color=auto'
	alias egrep='egrep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias iptlist='sudo /sbin/iptables -L -n -v --line-numbers'
	alias iptlistin='sudo /sbin/iptables -L INPUT -n -v --line-numbers'
	alias iptlistout='sudo /sbin/iptables -L OUTPUT -n -v --line-numbers'
	alias iptlistfw='sudo /sbin/iptables -L FORWARD -n -v --line-numbers'
	alias firewall=iptlist
	alias ports='netstat -tulanp'
	alias ipt='sudo /sbin/iptables'
	alias mkdir='mkdir -pv'
	
	#Service management
	alias reload='systemctl reload'
	alias restart='systemctl restart'
	alias sysreload='systemctl daemon-reload; systemctl reset-failed'
	alias start='systemctl start'
	alias stop='systemctl stop'

	alias mnt='mount |column -t'
	alias zr='zypper ref -s'
	alias zi='zypper in'
	alias zs='zypper se'
	## pass options to free ## 
	alias meminfo='free -m -l -t'
	 
	## get top process eating memory
	alias psmem='ps auxf | sort -nr -k 4 | head -20'

	## get top process eating cpu ##
	alias pscpu='ps auxf | sort -nr -k 3 | head -20'
	alias ping='ping -c 5'
	# Docker
	alias di='docker images'
	alias dki="docker run -t -i -P"
	function docker-clean() {
		docker rmi -f $(docker images -q -a -f dangling=true)
	}
	function dsh () {
		docker exec -i -t $1 /bin/bash
	}
	function dbash () {
		docker run --rm -i -t -e TERM=xterm --entrypoint /bin/bash $1
	}
	;;
	SunOS*) 
	alias psmem="echo ::memstat | mdb -k"
	alias ifconfig="ifconfig -a | egrep -v 'IPv6|inet6'"
	alias pgrep='ps -ef | grep -i'
	alias tailf='tail -f'
	alias mkdir='mkdir -p'
	alias netstatx='netstat -an -f inet'
	alias strace='truss  -a  -e  -f  -rall  -wall'
	
	alive () {
	ping -s $1 2 4
	}
	;;
esac

