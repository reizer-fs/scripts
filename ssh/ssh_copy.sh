#!/bin/sh

WORKING_DIR="$( cd "$( dirname $0)" && pwd )"

if [ ! -f ~/.ssh/id_rsa.pub ] ; then
	ssh-keygen -t rsa
fi

if [ ! -z $1 ]; then
	HOSTS=$1
fi

for hosts in $HOSTS ; do
	if ping -c 1 $hosts >/dev/null 2>&1 ; then
		echo "Processing $hosts ..."
		if [ `type -p ssh-copy-id` ]; then
			ssh-copy-id -i $HOME/.ssh/id_rsa.pub root@$hosts >/dev/null 2>&1 && echo "Key copied"
		else
			cat $HOME/.ssh/id_rsa.pub | ssh $hosts 'cat >> .ssh/authorized_keys && echo "Key copied"'
		fi
	else
		echo "No route to $hosts."
	fi
done
