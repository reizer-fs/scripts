pkg install grafana -y

mkdir -p $PREFIX/var/service/grafana
mkdir -p $PREFIX/var/service/grafana/log

cat > $PREFIX/var/service/grafana/run << 'EOF'
#!/data/data/com.termux/files/usr/bin/sh
exec grafana server --homepath $PREFIX/share/grafana/ 2>&1
EOF

cd $PREFIX/var/service/grafana/log
ln -sf $PREFIX/share/termux-services/svlogger run

chmod +x $PREFIX/var/service/grafana/run

sv-enable grafana
sv up grafana
sv status grafana
