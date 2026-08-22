#!/data/data/com.termux/files/usr/bin/bash

export PRODUCT=terraform
export VERSION=1.15.2
export OS=android
export OS_ARCH=arm64


[[ ! -f "${PRODUCT}"_"${VERSION}"_"${OS}"_"${OS_ARCH}".zip ]] && curl --remote-name https://releases.hashicorp.com/"${PRODUCT}"/"${VERSION}"/"${PRODUCT}"_"${VERSION}"_"${OS}"_"${OS_ARCH}".zip
[[ ! -f "${PRODUCT}" ]] && unzip "${PRODUCT}"_"${VERSION}"_"${OS}"_"${OS_ARCH}".zip
mv terraform $PREFIX/bin/
rm LICENSE.txt
