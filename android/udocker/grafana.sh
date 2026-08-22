#!/data/data/com.termux/files/usr/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/source.env"

cd "$(dirname "${BASH_SOURCE[0]}")"

IMAGE_NAME="grafana/grafana"

CONTAINER_NAME="server-grafana"

case $PORT in
    ''|*[!0-9]*) PORT=3000;;
    *) [ $PORT -gt 1023 ] && [ $PORT -lt 65536 ] || PORT=3000;;
esac

udocker_check

udocker_prune

udocker_create "$CONTAINER_NAME" "$IMAGE_NAME"

DATA_DIR="$(pwd)/data-$CONTAINER_NAME"

mkdir -p "$DATA_DIR"/{config,data}

if [ -n "$1" ]; then
  unset cmd
  cmd="$*"
  udocker_run -p "$PORT:3000" -e TZ="$(get_tz)" -v "$DATA_DIR/config:/config" -v "$DATA_DIR/data:/var/lib/grafana" -e GF_LOG_LEVEL="info" "$CONTAINER_NAME" "$cmd"
else
  udocker_run -p "$PORT:3000" -e TZ="$(get_tz)" -v "$DATA_DIR/config:/config" -v "$DATA_DIR/data:/var/lib/grafana" -e GF_LOG_LEVEL="info" "$CONTAINER_NAME"
fi

exit $?
