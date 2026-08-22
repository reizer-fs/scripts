#!/data/data/com.termux/files/usr/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/source.env"

cd "$(dirname "${BASH_SOURCE[0]}")"

IMAGE_NAME="prom/prometheus"
CONTAINER_NAME="server-prometheus"
DATA_DIR="$(pwd)/data-$CONTAINER_NAME"
CONFIG_FILE="$DATA_DIR/config/prometheus.yml"

case $PORT in
    ''|*[!0-9]*) PORT=9090;;
    *) [ $PORT -gt 1023 ] && [ $PORT -lt 65536 ] || PORT=9090;;
esac

udocker_check

udocker_prune

udocker_create "$CONTAINER_NAME" "$IMAGE_NAME"

mkdir -p "$DATA_DIR"/{config,data}
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


if [ -n "$1" ]; then
  unset cmd
  cmd="$*"
  udocker_run -p "$PORT:9090" -e TZ="$(get_tz)" -v "$CONFIG_FILE:/etc/prometheus/prometheus.yml" "$CONTAINER_NAME" "$cmd"
else
  udocker_run -p "$PORT:9090" -e TZ="$(get_tz)" -v "$CONFIG_FILE:/etc/prometheus/prometheus.yml" "$CONTAINER_NAME"
fi

exit $?
