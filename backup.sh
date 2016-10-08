#!/bin/sh

WORKING_DIR="$( cd "$( dirname $0)" && pwd )"
RETENTION=10
DATE=$(date +"%m-%d-%Y")
TIME=$(date +"%c")
TARGET_DIR="/shares/bbox"
LOG_DIRECTORY="/var/log/backup"
LOG_FILE="$LOG_DIRECTORY/backup-error.log"
HOSTNAME=`hostname | tr '[:lower:]' '[:upper:]'`


# Create log directory if missing
if [ ! -d $LOG_DIRECTORY ] ; then
	mkdir -p $LOG_DIRECTORY
fi

# Create mount/backup directory if missing
case $HOSTNAME in
	OSX|MACBOOK*)
		TARGET_DIR="/Volumes/OSX_DATA/Backup"
		if [ ! -d $TARGET_DIR/Backup/$HOSTNAME ] ; then
		mkdir -p $i/Backup/$HOSTNAME
		fi
	;;

	*)
		for i in $TARGET_DIR ; do
			if [ ! -d $i ] ; then
				mkdir $i
			fi
			if mountpoint -q $i ; then
				if [ ! -d $i/Backup/$HOSTNAME ] ; then
					mkdir -p $i/Backup/$HOSTNAME
				fi
			fi
		done
	;;
esac

start_docker_sql_backup() {
MYSQL_DOCKER=$(docker ps | grep mysql |awk '{print $NF}')
for e in $MYSQL_DOCKER ; do docker exec $e sh -c "exec mysqldump --all-databases" | bzip2 > $i/Backup/$HOSTNAME/$DATE-$e.sql.bz2 ; done
}

start_backup() {
echo "#### Starting Backup $TIME ####" >> $LOG_FILE
start_docker_sql_backup
tar cjf $i/Backup/$HOSTNAME/$DATE.SCRIPTS.tbz /opt/ffx/docker/ /opt/ffx/systems /opt/ffx/scripts /opt/ffx/centreon >/dev/null 2>&1
tar cjf $i/Backup/$HOSTNAME/$DATE.ETC.tbz /etc/fstab /etc/network/interfaces /etc/systemd/system/ /etc/default/docker >/dev/null 2>&1
echo "#### End Backup $TIME ####" >> $LOG_FILE && echo "" >> $LOG_FILE
echo "----------------------" >> $LOG_FILE && echo "" >> $LOG_FILE
}

purge_backup() {
echo "#### Starting Purge $TIME ####" >> $LOG_FILE
find $i/Backup/$HOSTNAME -type f -mtime +$RETENTION -delete && echo "#### Purge was successful in $i at $TIME ####" >> $LOG_FILE
echo "#### End Purge $TIME ####" >> $LOG_FILE && echo "" >> $LOG_FILE
echo "----------------------" >> $LOG_FILE && echo "" >> $LOG_FILE
}

check_mountpoint() {
mountpoint -q $1 && return 0 || return 1
}


for i in $TARGET_DIR ; do
	check_mountpoint $i && start_backup || echo "#### Problem on folder $i at $TIME ####" >> $LOG_FILE
	purge_backup
done

