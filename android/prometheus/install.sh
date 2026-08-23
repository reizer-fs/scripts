#!/data/data/com.termux/files/usr/bin/sh

termux-wake-lock
PROJECT_DIR="$HOME/projects/prometheus"
CONFIG_FILE="$PROJECT_DIR/config/prometheus.yml"

mkdir -p $PROJECT_DIR/{bin,config,data} 
cd $PROJECT_DIR

[[ ! -f "$PROJECT_DIR/prometheus-3.14.0.linux-arm64.tar.gz" ]] && wget https://github.com/prometheus/prometheus/releases/download/v3.14.0/prometheus-3.14.0.linux-arm64.tar.gz
[[ ! -f "$PROJECT_DIR/prometheus-3.14.0.linux-arm64" ]] && tar -xzf prometheus-3.14.0.linux-arm64.tar.gz 
[[ -f "$PROJECT_DIR/prometheus-3.14.0.linux-arm64.tar.gz" ]] && rm $PROJECT_DIR/prometheus-3.14.0.linux-arm64.tar.gz

mv prometheus-3.14.0.linux-arm64/prometheus bin/prometheus
rm -rf prometheus-3.14.0.linux-arm64


[[ ! -f $CONFIG_FILE ]] && echo "global:
  scrape_interval:      1m
  evaluation_interval:  1s

scrape_configs:
- job_name: 'prometheus'
  scrape_interval: 5s
  static_configs:
  - targets: ['127.0.0.1:9090']

- job_name: collectd
  scrape_interval: 10s
  honor_timestamps: true
  static_configs:
  - targets: ['127.0.0.1:9103']

- job_name: 'libvirt'
  scrape_interval: 5s
  static_configs:
  - targets: ['127.0.0.1:9177']" > $CONFIG_FILE

mkdir -p $PREFIX/var/service/prometheus
mkdir -p $PREFIX/var/service/prometheus/log

cat > $PREFIX/var/service/prometheus/run << EOF
#!/data/data/com.termux/files/usr/bin/sh

exec $PROJECT_DIR/bin/prometheus --config.file=$CONFIG_FILE --storage.tsdb.path $PROJECT_DIR/data --storage.tsdb.retention.time 14d 2>&1
EOF

cd $PREFIX/var/service/prometheus/log
ln -sf $PREFIX/share/termux-services/svlogger run
chmod +x $PREFIX/var/service/prometheus/run

sv-enable prometheus
sv up prometheus
sv status prometheus
