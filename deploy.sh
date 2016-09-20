#!/bin/sh

HOSTNAME=$(hostname | tr '[:lower:]' '[:upper:]')
WORKING_DIR="$( cd "$( dirname $0)" && pwd )"
HOSTS="X64 UBUNTUFFX FFXUBSWSX"
DIR_TO_SYNC="/opt/ffx/ /etc/cron.d"

deploy () {
case $HOSTNAME in
        OSX|MACBOOK*)
	echo "Cannot sync from this host"
	exit 1
	;;

	*)
	for hosts in $HOSTS ; do 
		if ping -c 1 $hosts >/dev/null 2>&1 ; then
			for i in $DIR_TO_SYNC ; do
				ssh $hosts "if [ ! -d $i ]; then mkdir -p $i ; fi"
				cp $WORKING_DIR/.bash_profile ~/
				scp -q /root/.bash_profile $hosts:/root/ &> /dev/null
				rsync -az $i/ $hosts:$i/ &> /dev/null || scp -r $i/* $hosts:$i/ &> /dev/null
				[ $? = 0 ] && echo "Copy successfully terminated on $hosts for $i."
			done
		else
			echo "[ $hosts ] is unreachable."
		fi
	done
	;;
esac
}
deploy
