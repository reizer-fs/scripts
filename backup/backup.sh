#!/bin/bash

TOSAVE="/opt/ffx/"
RETENTION=10
DATE=$(date +"%m-%d-%Y")
TIME=$(date +"%c")
TARGET_DIR="/media/fx/3AD8C970D8C92AC9"
TARGET_ALTERNATIVES="/media/fx/DISK2"
LOG_DIRECTORY="/var/log/backup"
LOG_FILE="$LOG_DIRECTORY/backup-error.log"
HOSTNAME=`hostname | tr '[:lower:]' '[:upper:]'`

export TOSAVE HOSTNAME RETENTION DATE TIME  LOG_DIRECTORY LOG_FILE TARGET_DIR 

# Create log directory if missing
[[ ! -d "$LOG_DIRECTORY" ]] && mkdir -p $LOG_DIRECTORY

# Different directory on OSX
[[ "$HOSTNAME" == "OSX" ]] && TARGET_DIR="/Volumes/OSX_DATA/Backup"

# Create mount/backup directory if missing
for i in $TARGET_ALTERNATIVES ; do
		mount $i 2>&1 >/dev/null
		[[ ! -d "$i" ]] && mkdir $i
		if mountpoint -q $i ; then
			[[ ! -d "$i/Backup/$HOSTNAME" ]] && mkdir -p $i/Backup/$HOSTNAME
		else
		    mount $i
		fi
done

start_docker_sql_backup() {
MYSQL_DOCKER=$(docker ps | grep mysql |awk '{print $NF}')
for e in $MYSQL_DOCKER ; do docker exec $e sh -c "exec mysqldump --all-databases" | bzip2 > $i/Backup/$HOSTNAME/$DATE-$e.sql.bz2 ; done
}

start_backup() {
echo "#### Starting Backup $TIME ####" >> $LOG_FILE
start_docker_sql_backup
for f in `readlink -f $TOSAVE/*` ; do LIST="$LIST $f" ; done
tar cjf $1/Backup/$HOSTNAME/$DATE.tbz $LIST >/dev/null 2>&1
echo "#### End Backup $TIME ####" >> $LOG_FILE && echo "" >> $LOG_FILE
echo "----------------------" >> $LOG_FILE && echo "" >> $LOG_FILE
}

purge_backup() {
echo "#### Starting Purge $TIME ####" >> $LOG_FILE
find $1/Backup/$HOSTNAME -type f -mtime +$RETENTION -delete && echo "#### Purge was successful in $i at $TIME ####" >> $LOG_FILE
echo "#### End Purge $TIME ####" >> $LOG_FILE && echo "" >> $LOG_FILE
echo "----------------------" >> $LOG_FILE && echo "" >> $LOG_FILE
}

check_mountpoint() {
mountpoint -q $1 && return 0 || return 1
}


check_mountpoint $TARGET_DIR && start_backup $TARGET_DIR 2>&1 >> $LOG_FILE || echo "#### Problem on folder $TARGET_DIR at $TIME ####" 2>&1 >> $LOG_FILE
purge_backup $TARGET_DIR

for i in $TARGET_ALTERNATIVES ; do
	check_mountpoint $i && rsync -a --progress $TARGET_DIR/Backup/ $i/Backup/ 2>&1 >> $LOG_FILE
done
