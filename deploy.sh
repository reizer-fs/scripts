#!/bin/sh

HOSTNAME=$(hostname | tr '[:lower:]' '[:upper:]')
WORKING_DIR="$( cd "$( dirname $0)" && pwd )"
HOSTS="X64 UBUNTUFFX X XVM"
DIR_TO_SYNC="/opt/ffx/ /etc/cron.d"

if [ ! -z $1 ] ; then
	HOSTS=$1
fi

for hosts in $HOSTS ; do 
	if ping -c 1 $hosts >/dev/null 2>&1 ; then
		for i in $DIR_TO_SYNC ; do
			ssh $hosts "if [ ! -d $i ]; then mkdir -p $i ; fi"
			rsync -az $i/ $hosts:$i/ 
			[ $? = 0 ] && echo "Copy successfully terminated on $hosts for $i."
		done
	else
		echo "[ $hosts ] is unreachable."
	fi
done
