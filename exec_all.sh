#!/bin/sh

WORKING_DIR="$( cd "$( dirname $0)" && pwd )"
HOSTS="sfx2 sfx3 sfx4 sfx5 sfx6 sfx7"

for hosts in $HOSTS ; do 
echo Processing $hosts ...
### Add default route ###
#ssh root@$hosts 'echo "default 192.168.0.254 - eth0" > /etc/sysconfig/network/ifroute-eth0'

### Reboot ###
#ssh root@$hosts 'init 6'

### Remove firewall ###
#ssh root@$hosts "zypper --non-interactive rm SuSEfirewall2"

### Install Net-SNMP###
#ssh root@$hosts "zypper ref -s"
#ssh root@$hosts "zypper --non-interactive in net-snmp && insserv snmpd"
#ssh root@$hosts "echo '/etc/init.d/snmpd start' >> /etc/init.d/after.local"
#ssh root@$hosts 'init 0'
#scp /root/macchanger-1.7.0-1.1.x86_64.rpm root@$hosts:/tmp/
#ssh root@$hosts "rpm -Uvh /tmp/macchanger-1.7.0-1.1.x86_64.rpm"
#ssh root@$hosts "rm -rf /tmp/macchanger-1.7.0-1.1.x86_64.rpm"
#ssh root@$hosts 'for i in 0 1 2 ; do macchanger -A eth$i ; done'

##ssh root@$hosts 'echo "PRE_UP_SCRIPT=\"compat:suse:macchanger\"" >> /etc/sysconfig/network/ifcfg-eth0'
#ssh root@$hosts '/opt/ffx/scripts/sync_hostname.sh'
#ssh root@$hosts 'export http_proxy=http://sfx2:3128 && zypper --non-interactive in cifs-utils'
#ssh root@$hosts 'mkdir /shares/levis'
#ssh root@$hosts "echo //192.168.0.254/LEVI\'S/ /shares/levis   cifs _netdev,rw,users,iocharset=utf8,uid=1000,sec=none,file_mode=0777,dir_mode=0777 0 0 >> /etc/fstab"
#ssh root@$hosts 'mount /shares/levis'
#ssh root@$hosts 'mkdir -p /shares/usb && mount -a'
#ssh root@$hosts 'echo "PRE_UP_SCRIPT=\"compat:suse:macchanger\"" >> /etc/sysconfig/network/ifcfg-eth2'
#scp /etc/sysconfig/network/scripts/macchanger root@$hosts:/etc/sysconfig/network/scripts/macchanger
ssh root@$hosts '/opt/ffx/scripts/backup.sh'

echo ""
done
