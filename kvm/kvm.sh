#!/bin/bash
set -e

# Set program name variable - basename without subshell
prog=${0##*/}

function usage ()
{
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
    create      - create a new guest domain
    detach-disk - detach a disk device from a guest domain
    list        - list all domains, running and stopped
    remove      - delete a guest domain

-h|--help           Print help and exit.
-d|--dry-run        Print only throughput, do not apply command.
-l|--legacy         Use files from repository (require Internet connection).
-o|--os             Select the operating system to install.
-n|--name           Define the hostname foe the guest system."

EOF
exit 0
}

OPTS=`getopt -o vhn:o:dl --long verbose,help,name:,os:,dry-run,legacy -n 'parse-options' -- "$@"`

if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

#echo "$OPTS"
eval set -- "$OPTS"

while true; do
  case ${1} in
      -v|--verbose)     VERBOSE=true; shift;;
      -h|--help)        HELP=true ; shift ;;
      -d|--dry-run)     DRY_RUN=true; shift ;;
      -l|--legacy)      LEGACY=true; shift ;;
      -n|--name)        HOST=$2 ; shift ; shift ;;
      -o|--os )         TEMPLATE=$2 ; shift ; shift ;;
      --) shift ; break ;;
      *) break ;;
  esac
done

DIR_BASE="$HOME/VMs"
DIR_HOST="${DIR_BASE}/${HOST}"
[[ "$HELP" == "true" ]] &&  usage && exit 0
[[ -z "$HOST" ]] && echo "[ error ] : Invalid name or no name specified." && exit 1
[[ -z "$HOST" ]] && echo "[ error ] : Invalid name or no name specified." && usage && exit 1
[[ -z "$TEMPLATE" ]] && echo "[ error ] :  Operating system not specified." && usage && exit 1
[[ ! -d "$DIR_BASE" ]] && echo "[ error ] : ${DIR_BASE} not found." && exit 1

if [ "$LEGACY" == "true" ]; then
    case $TEMPLATE in
        debian8)     LOCATION='http://ftp.nl.debian.org/debian/dists/jessie/main/installer-amd64/' ;;    
        debian7)     LOCATION='http://ftp.nl.debian.org/debian/dists/wheezy/main/installer-amd64/' ;;    
        kali)     LOCATION='http://http.kali.org/kali/dists/kali-rolling/main/installer-amd64/' ;;    
        centos8)     LOCATION='http://centos.mirrors.proxad.net/8/BaseOS/x86_64/os/' ;;    
        centos8)     LOCATION='http://mirror.centos.org/centos/8/BaseOS/x86_64/kickstart/' ;;    
        centos7)     LOCATION='http://mirror.i3d.net/pub/centos/7/os/x86_64/' ;;    
        centos6)     LOCATION='http://mirror.i3d.net/pub/centos/6/os/x86_64/' ;;    
        opensuse13)     LOCATION='http://download.opensuse.org/distribution/13.2/repo/oss/' ;;    
        opensuse12)     LOCATION='http://download.opensuse.org/distribution/12.3/repo/oss/' ;;    
        *)  echo "[ error ] : operating system not found. => $TEMPLATE" && exit 1 ;;
    esac
    EXTRA_ARGS="--extra-args console=ttyS0,115200n8 --graphics none --location ${LOCATION} -x 'inst.ks=http://192.168.0.15:8000/ks_centos8.cfg'"
fi

[[ -z "$DISK" ]] && DISK=" --disk path=${DIR_HOST}/${HOST}.qcow2,size=100,bus=virtio"
[[ -z "$OSVARIANT" ]] && OSVARIANT="centos7.0"
OSVARIANT="--os-variant $OSVARIANT"
# Stop and undefine the VM
sudo virsh list --name | grep -q $HOST && sudo virsh destroy $HOST &>/dev/null
sudo virsh list --all --name | grep -q $HOST && sudo virsh undefine $HOST --storage ${DIR_HOST}/${HOST}.qcow2 &>/dev/null
sudo rm -rf ${DIR_HOST} &>/dev/null ; mkdir ${DIR_HOST} &>/dev/null
KVM="virt-install --name ${HOST} --ram 4096 --vcpus 2 --os-type linux --network bridge=br-docker ${OSVARIANT} ${DISK} ${EXTRA_ARGS}"
if [ "$DRY_RUN" == 'true' ] ; then echo "sudo $KVM" ; exit ;fi
sudo qemu-img create -f qcow2 ${DIR_HOST}/${HOST}.qcow2 100G
sudo ${KVM} && echo "Done."
