#!/bin/sh

WORKING_DIR="$( cd "$( dirname $0)" && pwd )"
HOSTS="X64 FFXUBSWSX UBUNTUFFX"

if [ ! -f ~/.ssh/id_rsa.pub ] ; then
	ssh-keygen -t rsa
fi

if [ ! -z $1 ]; then
	HOSTS=$1
fi

if type ssh-copy-id >/dev/null 2>&1; then 
	for hosts in $HOSTS ; do
		echo "Processing $hosts ..."
		if ping -c 1 $hosts >/dev/null 2>&1; then
			ssh-copy-id -i ~/.ssh/id_rsa.pub root@$hosts >/dev/null 2>&1
		else
			echo "No route to $hosts."
		fi
	done
else
	for hosts in $HOSTS ; do
		echo "Processing $hosts ..."
		if ping -c 1 $hosts >/dev/null 2>&1; then
			cat ~/.ssh/id_rsa.pub | ssh $hosts "cat - >> ~/.ssh/authorized_keys" >/dev/null 2>&1
		else
			echo "No route to $hosts."
		fi
	done
fi
