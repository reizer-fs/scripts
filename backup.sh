#!/bin/sh

WORKING_DIR="$( cd "$( dirname $0)" && pwd )"
RETENTION=10
DATE=$(date +"%m-%d-%Y")
TIME=$(date +"%c")
TARGET_DIR="/shares/bbox"
LOG_DIRECTORY="/var/log/backup"
LOG_FILE="$LOG_DIRECTORY/backup-error.log"


# Create log directory if missing
if [ ! -d $LOG_DIRECTORY ] ; then
	mkdir -p $LOG_DIRECTORY
fi
hostname=`hostname | tr '[:lower:]' '[:upper:]'`

# Create mount/backup directory if missing
case $hostname in
	OSX|MACBOOK*)
		TARGET_DIR="/Volumes/OSX_DATA/Backup"
		if [ ! -d $TARGET_DIR/Backup/$hostname ] ; then
		mkdir -p $i/Backup/$hostname
		fi
	;;

	*)
		for i in $TARGET_DIR ; do
			if [ ! -d $i ] ; then
				mkdir -p $i
			fi
			if mountpoint -q $i ; then
				if [ ! -d $i/Backup/$hostname ] ; then
					mkdir -p $i/Backup/$hostname
				fi
			fi
		done
	;;
esac

#Define function to backup Needed files
start_backup() {

echo "#### Starting Backup $TIME ####" >> $LOG_FILE
tar cjf $i/Backup/$hostname/$DATE.SCRIPTS.tbz /opt/ffx/docker/ /opt/ffx/systems /opt/ffx/scripts /opt/ffx/centreon >/dev/null 2>&1
tar cjf $i/Backup/$hostname/$DATE.ETC.tbz /etc/fstab /etc/network/interfaces /etc/systemd/system/ /etc/default/docker >/dev/null 2>&1
echo "#### End Backup $TIME ####" >> $LOG_FILE && echo "" >> $LOG_FILE
echo "----------------------" >> $LOG_FILE && echo "" >> $LOG_FILE

}

purge_backup() {
echo "#### Starting Purge $TIME ####" >> $LOG_FILE
find $i/Backup/ -type f -iname *.tbz -mtime +$RETENTION -delete && echo "Purge was successful in $i" >> $LOG_FILE
echo "#### End Purge $TIME ####" >> $LOG_FILE && echo "" >> $LOG_FILE
echo "----------------------" >> $LOG_FILE && echo "" >> $LOG_FILE
}

check_mountpoint() {
[[ `mountpoint -q $i` ]] && return 0 || return 1
}

case $hostname in
	OSX|MAC*)
		start_backup
		if [ $? -eq 0 ] ; then
			purge_backup
		fi
	;;

	*)
		for i in $TARGET_DIR ; do
			check_mountpoint && start_backup && purge_backup || echo "#### Problem on folder $i during at $TIME ####" >> $LOG_FILE
			umount $i ; mount $i
			check_mountpoint && start_backup || echo "Problem on $i mountpoint, please check mount options." >> $LOG_FILE
		done
	;;
esac
