#!/bin/sh

WORKING_DIR="$( cd "$( dirname $0)" && pwd )"
HOSTNAME=$(hostname | tr '[:lower:]' '[:upper:]')

case `uname -s` in
        Linux)
		SED="sed" ;;
	SunOS)
		SED="gsed" ;;
	*)
		echo "This script is only suitable for Linux or Solaris"
	;;
esac


cp $WORKING_DIR/hosts /etc/
$SED -i '${/^127.0.0.1/d;}' /etc/hosts
echo "127.0.0.1       $HOSTNAME" >> /etc/hosts
