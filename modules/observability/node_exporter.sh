#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
# shellcheck source=../../lib/common.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

run_node_exporter() {
  needs_root
  if ! command -v docker >/dev/null 2>&1; then
    log_error "Docker não instalado. Rode modules/docker/install.sh"
    return 1
  fi
  local name="node-exporter"
  if ! docker ps -a --format '{{.Names}}' | grep -qx "$name"; then
    apply "docker run -d --restart unless-stopped --name \"$name\" --net host --pid host -v /:/host:ro,rslave prom/node-exporter:latest --path.rootfs=/host"
    log_success "Container $name criado."
  else
    apply "docker start \"$name\" || true"
    log_info "Container $name iniciado."
  fi
}
