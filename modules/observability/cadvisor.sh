#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
# shellcheck source=../../lib/common.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

run_cadvisor() {
  needs_root
  if ! command -v docker >/dev/null 2>&1; then
    err "Docker não instalado. Rode modules/docker/install.sh"
    return 1
  fi
  local name="cadvisor"
  if ! docker ps -a --format '{{.Names}}' | grep -qx "$name"; then
    apply "docker run -d --restart unless-stopped \
      --name $name \
      --privileged \
      -p 8088:8080 \
      -v /:/rootfs:ro \
      -v /var/run:/var/run:ro \
      -v /sys:/sys:ro \
      -v /var/lib/docker/:/var/lib/docker:ro \
      gcr.io/cadvisor/cadvisor:latest"
    log "Container $name criado."
  else
    apply "docker start $name || true"
    log "Container $name iniciado."
  fi
}
