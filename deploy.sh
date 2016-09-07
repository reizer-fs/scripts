#!/bin/sh

HOSTNAME=$(hostname | tr '[:lower:]' '[:upper:]')
WORKING_DIR="$( cd "$( dirname $0)" && pwd )"
HOSTS="UBUNTUFFX OSX CENTREON SOLARISX2 FFXUBSWSX SFX1 SFX2 SFX3"
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
		case $hosts in
			192.168.0.101|OSX|osx|MacBook*)
			DIR_TO_SYNC="/opt/ffx/"
			for i in $DIR_TO_SYNC ; do
				rsync -az $i/ $hosts:/etc/ffx/ &> /dev/null || scp -r $i/* $hosts:/etc/ &> /dev/null && echo "Copy successfully terminated on $hosts"
			done
			;;

			*)
			for i in $DIR_TO_SYNC ; do
				ssh $hosts "if [ ! -d $i ]; then mkdir -p $i ; fi"
				cp $WORKING_DIR/.bash_profile ~/
				scp -q /root/.bash_profile $hosts:/root/ &> /dev/null
				rsync -az $i/ $hosts:$i/ &> /dev/null || scp -r $i/* $hosts:$i/ &> /dev/null
				[ $? = 0 ] && echo "Copy successfully terminated on $hosts"
			done
			;;
		esac
		else
			echo "[ $hosts ] is unreachable."
		fi
	done
	;;
esac
}
deploy
