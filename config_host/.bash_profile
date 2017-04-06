
export HOSTALIASES='/etc/hosts.aliases'
export http_proxy="http://proxywebsrv.tech.sits.credit-agricole.fr:8080/"
export https_proxy="http://proxywebsrv.tech.sits.credit-agricole.fr:8080/"

#export PS1="[ \t ] \[$(tput sgr0)\]\[\033[38;5;196m\]\u@\h\[$(tput sgr0)\]\[\033[38;5;15m\]:\[$(tput sgr0)\]\[\033[38;5;196m\]\w:\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"
export PS1="\[$(tput bold)\]\[$(tput setaf 0)\]\t \[$(tput setaf 0)\][\[$(tput setaf 1)\]\u\[$(tput setaf 1)\]@\[$(tput setaf 1)\]\h \[$(tput setaf 1)\]\W\[$(tput setaf 0)\]]\[$(tput setaf 0)\]\\$ \[$(tput sgr0)\]"
# Common commandfs
alias ls='ls --color=auto'
alias ll='ls --color=auto -l'
alias l='ll'
alias setproxy='export https_proxy="http://proxy:8080/" ; export https_proxy="http://proxy:8080/"'

# Docker
alias cddocker='cd /opt/ffx/docker'
alias cdscripts='cd /opt/ffx/scripts'
alias cddata='cd /data/docker/'
alias dp="docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}'"
alias dr='docker rm -v'
alias dri='docker rmi'
alias di='docker images'
alias dvl='docker volume ls'
alias dvr='docker volume rm'

# Get container IP
alias dip="docker inspect --format '{{ .NetworkSettings.IPAddress }}'"
#TMUX2.3#
alias attachmux='tmux -2 attach -t '
alias lsmux='tmux list-sessions'
alias newmux='tmux -2 -f /etc/tmux.conf.d/francis.conf new -s '
alias reloadmux='tmux source-file /etc/tmux.conf.d/francis.conf'
alias vimux='vim /etc/tmux.conf.d/francis.conf'
export TERM=dtterm

#Git
alias gp='git push'
alias gpull='git pull'
alias gc='git commit -a'
alias gs='git status -s'
alias gdiff='git diff'
alias ga='git add'


function ds () {
    docker start $1
}

function dk () {
    docker stop $1
}

function drun () {
    docker run -d -it --name $2 $1 bash
}

db() { docker build --build-arg http_proxy=$http_proxy -t=$1 .; }
dalias() { alias | grep 'docker' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort; }


export PS1="\[$(tput bold)\]\[$(tput setaf 0)\]\t \[$(tput setaf 0)\][\[$(tput setaf 1)\]\u\[$(tput setaf 1)\]@\[$(tput setaf 1)\]\h \[$(tput setaf 1)\]\W\[$(tput setaf 0)\]]\[$(tput setaf 0)\]\\$ \[$(tput sgr0)\]"


# Global alias
alias cdscript='cd /opt/ffx/scripts'
alias cdplugins='cd /usr/lib/nagios/plugins/'
alias cddownloads='cd /data/docker/samba/samba-basic/shares/downloads/'
#### Alias Sesction ####
alias ll='ls -l'
alias la='ls -ltra'

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
	alias restart='systemctl restart'
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
	alias dri='docker rmi'
	alias dr='docker rm'
	alias dki="docker run -t -i -P"
	function docker-clean() {
		docker rmi -f $(docker images -q -a -f dangling=true)
	}
	function db (){ 
		docker build -t="$1" .; 
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
	alias netstats='netstat -un -P tcp'
	alias netstatx='netstat -an -f inet'
	alias 'netstats -plantu'='netstat -aun'
	
	alive () {
	ping -s $1 2 4
	}
	;;
esac
