#!/bin/sh

WORKING_DIR="$( cd "$( dirname $0)" && pwd )"
HOSTNAME=$(hostname | tr '[:lower:]' '[:upper:]')

cp $WORKING_DIR/hosts /etc/
sed -i '${/^127.0.0.1/d;}' /etc/hosts
echo "127.0.0.1       $HOSTNAME" >> /etc/hosts
