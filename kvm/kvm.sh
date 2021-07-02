#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
#set -e

# Set program name variable - basename without subshell
prog=${0##*/}

function set_defaults () {
    # Setting default settings
    DIR_BASE="$HOME/VMs"
    KICKSTART_CFG="$HOME/Git/kickstart/ks_rhl8_minimal.cfg"
    KICKSTART_URL_CFG="http://10.11.12.1/ks_rhl8_minimal.cfg"
    EXTRA_KERNEL_ARGS="$EXTRA_ARGS -x 'ipv6.disable=1' -x 'ip=dhcp'"
    OSVARIANT="Linux"
    NCPU="1"
    NRAM="2048"
    NBRIDGE="br-nodes"
    DISKSIZE="20G"
}

usage () {
    cat << EOF
NAME
    $prog - Install virtual guests using cloud-init or legacy (with DVD) on a local KVM
    hypervisor.

SYNOPSIS
    $prog COMMAND [OPTIONS]

DESCRIPTION
    A bash wrapper around virt-install to build virtual machines on a local KVM
    hypervisor. You can run it as a normal user which will use qemu:///session
    to connect locally to your KVM domains.

COMMANDS
    help        - show this help or help for a subcommand
    attach-disk - create and attach a disk device to guest domain
    detach-disk - detach a disk device from a guest domain
    list        - list all domains, running and stopped

-h|--help           Print help and exit.
-c|--create         Create a new guest domain
-r|--remove         Remove a guest domain
-v|--verbose        Enable debugging kernel options.
-n|--name           Define the hostname foe the guest system."
-d|--dry-run        Print only throughput, do not apply command.
-l|--legacy         Use local ISO or IMG.
-o|--os             Select the operating system to install. (default=centos8)
-b|--bridge         Define the bridge to use (default=virbr0)
-t|--text           Start the guest in text mode
-k|--kickstart      Enable kickstart installation mode

Example:
# Create default VM
./$prog --create --legacy --name MP000GTW0000

# Create VM with 4 cpus, 4g ram, bridge (dry-run)
./$prog --create --legacy --name WP000GTW0000 --os windows10 --dry-run

EOF
exit 0
}

delete_domain () {
    [[ -z $1 ]] && echo "Argument required" && return 1
    HOST=$1
    # Stop and undefine the VM
    sudo virsh destroy $HOST &>/dev/null
    sudo virsh undefine $HOST --remove-all-storage &>/dev/null
    sudo virsh pool-destroy $HOST &>/dev/null
}

OPTS=`getopt -o vhn:o:b:dltkrc --long verbose,help,name:,os:,dry-run,bridge,legacy,text,kickstart,create,remove -n 'parse-options' -- "$@"`

set_defaults
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPTS"

while true; do
  case ${1} in
      -c|--create)      CREATE="true" ;     shift ;;
      -r|--remove)      DELETE="true" ;     shift ;;
      -v|--verbose)     VERBOSE="true" ;    shift ;;
      -h|--help)        HELP="true" ;       shift ;;
      -d|--dry-run)     DRY_RUN="true" ;    shift ;;
      -l|--legacy)      LEGACY="true" ;     shift ;;
      -t|--text )       TEXT="true" ;       shift ;;
      -k|--kickstart )  KS="true" ;         shift ;;
      -n|--name)        HOST=$2 ;           shift ; shift ;;
      -o|--os )         TEMPLATE=$2 ;       shift ; shift ;;
      -b|--bridge )     BRIDGE=$2 ;         shift ; shift ;;
      --) shift ; break ;;
      *) break ;;
  esac
done

[[ "$HELP" == "true" ]] &&  usage && exit 0
[[ -z "$HOST" ]] && echo "[ error ] : Invalid name or no name specified." && usage && exit 1
[[ -z "$TEMPLATE" && $CREATE == "true" ]] && echo "[ error ] :  Operating system not specified." && usage && exit 1
[[ -z "$DIR_HOST" ]] && DIR_HOST="${DIR_BASE}/${HOST}"
[[ ! -z "$BRIDGE" ]] && NBRIDGE=$BRIDGE
[[ ! -d "$DIR_BASE" ]] && mkdir $DIR_BASE
[[ ! -d "$DIR_HOST" ]] && mkdir $DIR_HOST

[[ "$LEGACY" == ""  && $CREATE != '' ]] &&
{
    case $TEMPLATE in
        debian8)    LOCATION='http://ftp.nl.debian.org/debian/dists/jessie/main/installer-amd64/' ;;    
        kali)       OSVARIANT="debian10" ; LOCATION='http://http.kali.org/kali/dists/kali-rolling/main/installer-amd64/' ;;    
        centos8)    LOCATION='http://mirror.centos.org/centos/8/BaseOS/x86_64/kickstart/' ;;    
        centos7)    LOCATION='http://mirror.i3d.net/pub/centos/7/os/x86_64/' ;;    
        opensuse13) LOCATION='http://download.opensuse.org/distribution/13.2/repo/oss/' ;;    
        opensuse12) LOCATION='http://download.opensuse.org/distribution/12.3/repo/oss/' ;;    
        *)  echo "[ error ] : operating system not found. => $TEMPLATE" && exit 1 ;;
    esac
    EXTRA_ARGS="$EXTRA_ARGS --location ${LOCATION} $EXTRA_KERNEL_ARGS" ; }

[[ "$LEGACY" == 'true'  && $CREATE == "true" ]] && 
{
    case $TEMPLATE in
        windows10)   OSVARIANT="win10";       LOCATION=" -c $HOME/OS/ISO/Windows/WIN.10.Lite.Edition.v9.2019.x64.iso" ; DISK="--disk path=$HOME/OS/ISO/Windows/virtio-win-0.1.189.iso,device=cdrom,bus=sata";;
        macos)       OSVARIANT="macosx10.7";  LOCATION=" -c $HOME/OS/ISO/MacOSX/MacOSX-Catalina.img" ;;
        solaris)
                CDROM="$HOME/ISO/sol-11_3-text-x86.iso,device=cdrom"
                DISK="  --disk path=${DIR_HOST}/${HOST}.qcow2,size=100,bus=ide"
                OSVARIANT="solaris11"
                EXTRA_ARGS="--noapic"
                ;;
        *)  echo "[ error ] : operating system not found. => $TEMPLATE" && exit 1 ;;
    esac
    EXTRA_ARGS="$EXTRA_ARGS $LOCATION" ; }

[[ $KS == "true" ]] && EXTRA_ARGS="$EXTRA_ARGS -x inst.ks=$KICKSTART_URL_CFG"
[[ $VERBOSE == "true" ]] && EXTRA_ARGS="$EXTRA_ARGS --debug -x 'rd.shell' -x 'rd.debug'"
[[ $TEXT == "true" ]] && EXTRA_ARGS="$EXTRA_ARGS -x console=ttyS0,115200n8 --nographics -x 'inst.text'"
[[ -z $OSVARIANT ]] && OSVARIANT="centos7.0"
[[ $DELETE == "true" ]] && delete_domain $HOST

DISK="$DISK --disk path=${DIR_HOST}/${HOST}.qcow2,size=100,bus=virtio"
KVM="virt-install --name ${HOST} --accelerate --ram ${NRAM} --vcpus ${NCPU} --os-variant ${OSVARIANT} --network bridge=${NBRIDGE} ${DISK} ${EXTRA_ARGS}"
[[ $DRY_RUN = 'true' ]] && echo "sudo $KVM" && exit 0
[[ $CREATE = "true" ]] && { 
delete_domain $HOST
sudo qemu-img create -f qcow2 ${DIR_HOST}/${HOST}.qcow2 ${DISKSIZE}
sudo ${KVM} ; }
