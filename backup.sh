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

case $hostname in
	SFX*)
	tar cjf $i/Backup/$hostname/$DATE.OPENSVC.tbz /opt/opensvc/etc/* >/dev/null 2>&1
	tar cjf $i/Backup/$hostname/$DATE.IFCFG.tbz /etc/sysconfig/network/* >/dev/null 2>&1
	tar cjf $i/Backup/$hostname/$DATE.SCRIPTS.tbz /opt/ffx/scripts/* >/dev/null 2>&1
	;;

	OSX|MAC*)
	tar cjf $i/Backup/$hostname/$DATE.CONF.tbz  /etc/nrpe.cfg /etc/snmp/snmpd.conf ~/.bashrc /etc/hosts >/dev/null 2>&1
	tar cjf $i/Backup/$hostname/$DATE.PLUGINS.tbz  /usr/lib/nagios/plugins/ >/dev/null 2>&1
	tar cjf $i/Backup/$hostname/$DATE.SCRIPTS.tbz /opt/ffx/scripts/* >/dev/null 2>&1
	;;

	*)
	tar cjf $i/Backup/$hostname/$DATE.SCRIPTS.tbz /opt/ffx/docker/ >/dev/null 2>&1
	tar cjf $i/Backup/$hostname/$DATE.ETC.tbz /etc/fstab /etc/network/interfaces /etc/systemd/system/ >/dev/null 2>&1
	;;

	*)
	echo "Unknown host, add a New entry in $0."
	return 1
	;;
esac
}

case $hostname in
	OSX|MAC*)
		start_backup
		if [ $? -eq 0 ] ; then
			find $i/Backup/ -type f -iname *.tbz -mtime +$RETENTION -delete && echo "Purge was successful in $i" >> $LOG_FILE
		fi
	;;

	*)
		for i in $TARGET_DIR ; do
			if mountpoint -q $i ; then
				echo "Mount Point $i found, starting backup ..." >> $LOG_FILE
				echo "#### Starting Backup $TIME ####" >> $LOG_FILE
				start_backup
				if [ $? -eq 0 ] ; then
					echo "Starting Purge in $i" >> $LOG_FILE
					find $i/Backup/ -type f -iname *.tbz -mtime +$RETENTION -delete && echo "Purge was successful in $i" >> $LOG_FILE
				fi
				echo "#### End $TIME ####" >> $LOG_FILE
				echo "" >> $LOG_FILE
				echo "----------------------" >> $LOG_FILE
				echo "" >> $LOG_FILE
			else
				echo "!!!!!!! Mountpoint $i not found, trying to fix ... !!!!!!!" >> $LOG_FILE
				umount $i && echo ">>> Moutpoint $i successfully unmounted. <<<" >> $LOG_FILE
				mount $i && echo ">>> Moutpoint $i successfully remounted.<<<" >> $LOG_FILE || echo ">>> Moutpoint $i failed to remount after attempt. <<<" >> $LOG_FILE 

				if mountpoint -q $i ; then
					echo ">>> Mountpoint $i found, after a retry attempt, starting backup ... <<<" >> $LOG_FILE
					start_backup

					if [ $? -eq 0 ] ; then
						echo "Starting Purge in $i" >> $LOG_FILE
						find $i/Backup/ -type f -iname *.tbz -mtime +$RETENTION -delete && echo "Purge in $i done." >> $LOG_FILE
					fi

				else
					echo "Problem on $i backup, please check mount options." >> $LOG_FILE
				fi
				echo "#### End $TIME ####" >> $LOG_FILE
				echo "" >> $LOG_FILE
				echo "----------------------" >> $LOG_FILE
				echo "" >> $LOG_FILE
			fi
		done
	;;
esac
