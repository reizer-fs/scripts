
git config --global http.proxy http://proxy:8080/
git config --global https.proxy http://proxy:8080/
git config --global credential.helper store
git config --global user.name "$HOSTNAME"
git config --global user.mail "horus@gmail.com"

if [ ! -d "/opt/ffx" ] ; then
	mkdir /opt/ffx
fi
cd /opt/ffx
for i in scripts docker systems windows-client centreon misc splunk ; do
	git clone https://github.com/reizer-fs/$i.git
done
#git push https://reizer-fs:<token>@github.com/reizer-fs/scripts.git
