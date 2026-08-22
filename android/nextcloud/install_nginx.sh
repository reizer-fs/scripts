#!/bin/bash

DOCUMENTROOT="$HOME/projects/nextcloud"
mkdir -p $DOCUMENTROOT $HOME/.termux/boot
pkg install -y openssl openssl-tool php-gd unzip sqlite php-fpm nginx
[[ ! -f "$DOCUMENTROOT/latest-33.zip" ]] && curl -k -o $DOCUMENTROOT/latest-33.zip https://download.nextcloud.com/server/releases/latest-33.zip
[[ ! -d "$DOCUMENTROOT/nextcloud" ]] && unzip latest-33.zip &>/dev/null
[[ -f "$DOCUMENTROOT/latest-33.zip" ]] && rm $DOCUMENTROOT/latest-33.zip

ln -s $PREFIX/etc/nginx/mime.types $DOCUMENTROOT/mime.types
ln -s $PREFIX/etc/nginx/fastcgi_params $DOCUMENTROOT/fastcgi_params
sed -i 's/localhost:8080/*/g' $DOCUMENTROOT/nextcloud/config/config.sample.php
openssl req -x509 -newkey rsa:4096 -keyout $DOCUMENTROOT/key.pem -out $DOCUMENTROOT/cert.pem -sha256 -days 36500 -nodes -subj "/C=XX/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=CommonNameOrHostname" &>/dev/null

echo "#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
pkill nginx &>/dev/null
php-fpm &>/dev/null
nginx -c $DOCUMENTROOT/nginx-nextcloud.conf
" > $HOME/.termux/boot/start-nextcloud-nginx.sh
