#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
#set -e

# Set program name variable - basename without subshell
prog=${0##*/}

usage () {
    cat << EOF
NAME
    kvm-install-vm - Install virtual guests using cloud-init on a local KVM
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
-l|--legacy         Use files from repository (require Internet connection).
-o|--os             Select the operating system to install.
-t|--text           Start the guest in text mode
-k|--kickstart      Enable kickstart installation mode

EOF
exit 0
}

delete_domain () {
    [[ -z $1 ]] && echo "Argument required" && return 1
    HOST=$1
    # Stop and undefine the VM
    #virsh list --name | grep -q $HOST && sudo virsh destroy $HOST &>/dev/null
    #virsh list --all --name | grep -q $HOST && sudo virsh undefine $HOST --remove-all-storage &>/dev/null
    sudo virsh destroy $HOST &>/dev/null
    sudo virsh undefine $HOST --remove-all-storage &>/dev/null
    sudo virsh pool-destroy $HOST &>/dev/null
}

OPTS=`getopt -o vhn:o:dltkrc --long verbose,help,name:,os:,dry-run,legacy,text,kickstart,create,remove -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

#echo "$OPTS"
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
      --) shift ; break ;;
      *) break ;;
  esac
done

DIR_BASE="$HOME/VMs"
DIR_HOST="${DIR_BASE}/${HOST}"
KICKSTART_CFG="$HOME/Git/kickstart/ks_rhl8_minimal.cfg"
KICKSTART_URL_CFG="http://10.11.12.1/ks_rhl8_minimal.cfg"
EXTRA_ARGS="$EXTRA_ARGS -x 'ipv6.disable=1' -x 'ip=dhcp'"
OSVARIANT="Linux"

[[ "$HELP" == "true" ]] &&  usage && exit 0
[[ -z "$HOST" ]] && echo "[ error ] : Invalid name or no name specified." && usage && exit 1
[[ -z "$TEMPLATE" && $CREATE == "true" ]] && echo "[ error ] :  Operating system not specified." && usage && exit 1
[[ ! -d "$DIR_BASE" ]] && mkdir $DIR_BASE
[[ ! -d "$DIR_HOST" ]] && mkdir $DIR_HOST

[[ "$LEGACY" == "true"  && $CREATE != '' ]] &&
{
    case $TEMPLATE in
        debian8)     LOCATION='http://ftp.nl.debian.org/debian/dists/jessie/main/installer-amd64/' ;;    
        kali)     LOCATION='http://http.kali.org/kali/dists/kali-rolling/main/installer-amd64/' ;;    
        #centos8)     LOCATION='http://centos.mirrors.proxad.net/8/BaseOS/x86_64/os/' ;;    
        centos8)     LOCATION='http://mirror.centos.org/centos/8/BaseOS/x86_64/kickstart/' ;;    
        centos7)     LOCATION='http://mirror.i3d.net/pub/centos/7/os/x86_64/' ;;    
        opensuse13)     LOCATION='http://download.opensuse.org/distribution/13.2/repo/oss/' ;;    
        opensuse12)     LOCATION='http://download.opensuse.org/distribution/12.3/repo/oss/' ;;    
        *)  echo "[ error ] : operating system not found. => $TEMPLATE" && exit 1 ;;
    esac
    EXTRA_ARGS="$EXTRA_ARGS --location ${LOCATION}" ; }

[[ "$LEGACY" == ''  && $CREATE == "true" ]] && 
{
    case $TEMPLATE in
        win7)   	OSVARIANT="win7";		CDROM="$HOME/ISO/Windows7LITEX64.iso,device=cdrom,bus=ide --disk $HOME/ISO/virtio-win-drivers-20120712-1.iso,device=cdrom,bus=ide";;
        centos8)	OSVARIANT="centos7.0";		CDROM="$HOME/OS/CentOS8/CentOS-8.1.1911-x86_64-boot.iso";;
        solaris)
                LOCATION="$HOME/ISO/sol-11_3-text-x86.iso,device=cdrom --graphics none "
                DISK="  --disk path=${DIR_HOST}/${HOST}.qcow2,size=100,bus=ide"
                OSVARIANT="solaris11 --noapic"
                ;;
        *)  echo "[ error ] : operating system not found. => $TEMPLATE" && exit 1 ;;
    esac
    EXTRA_ARGS="$EXTRA_ARGS --location $CDROM" ; }

OSVARIANT="--os-variant $OSVARIANT"
[[ $KS == "true" ]] && EXTRA_ARGS="$EXTRA_ARGS -x inst.ks=$KICKSTART_URL_CFG"
#[[ "$KS" == "true" ]] && EXTRA_ARGS="$EXTRA_ARGS --initrd-inject $KICKSTART_CFG -x 'ks=file:/ks.cfg'"
[[ $VERBOSE == "true" ]] && EXTRA_ARGS="$EXTRA_ARGS --debug -x 'rd.shell' -x 'rd.debug'"
[[ $TEXT == "true" ]] && EXTRA_ARGS="$EXTRA_ARGS -x console=ttyS0,115200n8 --nographics -x 'inst.text'"
[[ -z $DISK ]] && DISK=" --disk path=${DIR_HOST}/${HOST}.qcow2,size=100,bus=virtio"
[[ -z $OSVARIANT ]] && OSVARIANT="centos7.0"
[[ $DELETE == "true" ]] && delete_domain $HOST

KVM="virt-install --name ${HOST} --accelerate --ram 4096 --vcpus 1 --os-type linux --network bridge=br-kvm-docker ${OSVARIANT} ${DISK} ${EXTRA_ARGS}"
[[ $DRY_RUN = 'true' ]] && echo "sudo $KVM" && exit 0
[[ $CREATE = "true" ]] && { 
delete_domain $HOST
sudo qemu-img create -f qcow2 ${DIR_HOST}/${HOST}.qcow2 100G
sudo ${KVM} ; }
