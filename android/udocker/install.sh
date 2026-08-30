#!/data/data/com.termux/files/usr/bin/bash

termux-wake-lock
PROJECT_DIR="$HOME/projects"
PROJECT_NAME="udocker"
APP_NAME="home-assistant"

[[ ! -d "${PROJECT_DIR}" ]] && mkdir ${PROJECT_DIR}
[[ ! -d "${PROJECT_DIR}/${PROJECT_NAME}" ]] && mkdir ${PROJECT_DIR}/${PROJECT_NAME}
[[ ! -d "${PREFIX}/var/service/${APP_NAME}/log" ]] && mkdir -p $PREFIX/var/service/${APP_NAME}/log

pkg update && pkg install -y python3
## Phase Installation ##
cd ${PROJECT_DIR}/${PROJECT_NAME} && git clone -n --depth=1 --filter=tree:0 https://github.com/reizer-fs/scripts.git
cd scripts

# Define the exact subdirectory you want
git sparse-checkout set "android/udocker"

# Pull only those specific files
git checkout
cd ${PROJECT_DIR}/${PROJECT_NAME} && mv scripts/android/udocker/* .
rm -rf scripts

# Make it executable
chmod +x install_udocker.sh
chmod +x ${APP_NAME}.sh
./install_udocker.sh

# Create the run script
cat > ${PREFIX}/var/service/${APP_NAME}/run << EOF
#!/data/data/com.termux/files/usr/bin/bash
exec ${PROJECT_DIR}/${PROJECT_NAME}/${APP_NAME}.sh 2>&1
EOF

chmod +x $PREFIX/var/service/${APP_NAME}/run
cd $PREFIX/var/service/${APP_NAME}/log && ln -sf $PREFIX/share/termux-services/svlogger run


. "${PREFIX}/etc/profile.d/start-services.sh"
sv-enable ${APP_NAME}
sv up ${APP_NAME}
sv status ${APP_NAME}
