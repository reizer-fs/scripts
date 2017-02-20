#!/bin/sh

WORKING_DIR="$( cd "$( dirname $0)" && pwd )"
HOSTNAME=$(hostname)
IPADDR=`ifconfig | grep 'inet '|grep -v '127.0.0.1'|awk '{print $2}'|cut -c6-`

case `hostname` in
	OSX|MacBook*)
	echo $HOSTNAME
	;;
	sfx*|SFX*|nsa)
	echo $HOSTNAME
	;;
	centreon|CENTREON|UbuntuX)
	echo $HOSTNAME
	;;
esac


#apt-get install snmp snmpd
cat << EOF > /etc/snmp/snmpd.conf
agentAddress  161
rocommunity public
syslocation "FFX Unix server Inc."
syscontact horus@gmail.com
includeAllDisks 10%
EOF
for i in $IPADDR ; do echo "agentAddress  udp:$i:161" >> /etc/snmp/snmpd.conf ; done
service snmpd restart

#NTP
cat << EOF > /etc/ntp.conf
restrict default kod nomodify notrap nopeer noquery
restrict -6 default kod nomodify notrap nopeer noquery
restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap
restrict 127.0.0.1
driftfile /var/lib/ntp/ntp.drift
logfile /var/log/ntp.log
EOF
