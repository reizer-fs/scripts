#!/data/data/com.termux/files/usr/bin/bash

termux-wake-lock
PROJECT_DIR="$HOME/projects"
PROJECT_NAME="termux-api-exporter"

[[ ! -d "${PROJECT_DIR}" ]] && mkdir ${PROJECT_DIR}
[[ ! -d "${PROJECT_DIR}/${PROJECT_NAME}" ]] && mkdir ${PROJECT_DIR}/${PROJECT_NAME}
[[ ! -d "${PREFIX}/var/service/${PROJECT_NAME}/log" ]] && mkdir -p $PREFIX/var/service/${PROJECT_NAME}/log

## Phase Installation ##
pkg install -y termux-services termux-api wget
wget -P ${PROJECT_DIR}/${PROJECT_NAME}/ https://github.com/anshulpatel25/termux-api-exporter/releases/download/v0.2.0/termux-api-exporter-arm64-linux.tar.gz
cd ${PROJECT_DIR}/${PROJECT_NAME}/ && tar -xf termux-api-exporter-arm64-linux.tar.gz
rm *.tar.gz

# Make it executable
chmod +x termux-api-exporter

# Create the run script
cat > $PREFIX/var/service/$PROJECT_NAME/run << EOF
#!/data/data/com.termux/files/usr/bin/sh
exec ${PROJECT_DIR}/${PROJECT_NAME}/termux-api-exporter 2>&1
EOF

chmod +x $PREFIX/var/service/$PROJECT_NAME/run
cd $PREFIX/var/service/${PROJECT_NAME}/log && ln -sf $PREFIX/share/termux-services/svlogger run


. "${PREFIX}/etc/profile.d/start-services.sh"
sv-enable ${PROJECT_NAME}
sv up ${PROJECT_NAME}
sv status ${PROJECT_NAME}
