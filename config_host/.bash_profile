
export HOSTALIASES='/etc/hosts.aliases'
export http_proxy="http://proxywebsrv.tech.sits.credit-agricole.fr:8080/"
export https_proxy="http://proxywebsrv.tech.sits.credit-agricole.fr:8080/"

#export PS1="[ \t ] \[$(tput sgr0)\]\[\033[38;5;196m\]\u@\h\[$(tput sgr0)\]\[\033[38;5;15m\]:\[$(tput sgr0)\]\[\033[38;5;196m\]\w:\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"
export PS1="\[$(tput bold)\]\[$(tput setaf 0)\]\t \[$(tput setaf 0)\][\[$(tput setaf 1)\]\u\[$(tput setaf 1)\]@\[$(tput setaf 1)\]\h \[$(tput setaf 1)\]\W\[$(tput setaf 0)\]]\[$(tput setaf 0)\]\\$ \[$(tput sgr0)\]"

# Common commandfs
alias ls='ls --color=auto'
alias ll='ls --color=auto -l'
alias l='ll'
alias gethost='getent hosts'
alias setproxy='export https_proxy="http://proxy:8080/" ; export https_proxy="http://proxy:8080/"'
alias viprofile='~/.bash_profile'

# Docker
alias cddocker='cd /opt/ffx/docker'
alias cdscripts='cd /opt/ffx/scripts'
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
export TERM=dtterm

#Git
alias git='git'
alias gp='git push'
alias gpull='git pull'
alias gc='git commit -a'
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
alias viprofile='vi ~/.bash_profile'
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
	
	alive () {
	ping -s $1 2 4
	}
	;;
esac
