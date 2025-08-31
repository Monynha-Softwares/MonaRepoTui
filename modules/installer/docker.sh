#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
# shellcheck source=../../lib/common.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

docker_pull_image() {
  needs_root
  local image="$1"
  [[ -n "$image" ]] || {
    err "Informe a imagem (ex.: nginx:latest)"
    return 1
  }
  if ! command -v docker >/dev/null 2>&1; then
    err "Docker não instalado. Rode modules/docker/install.sh"
    return 1
  fi
  apply "docker pull '$image'"
}

docker_run_quick() {
  needs_root
  local image="$1" name="${2:-mona-app}" port="${3:-}"
  [[ -n "$image" ]] || {
    err "Informe a imagem (ex.: nginx:latest)"
    return 1
  }
  local port_flag=""
  [[ -n "$port" ]] && port_flag="-p $port"
  if docker ps -a --format '{{.Names}}' | grep -qx "$name"; then
    log "Container '$name' já existe. Iniciando…"
    apply "docker start '$name' || true"
  else
    apply "docker run -d --restart unless-stopped --name '$name' $port_flag '$image'"
  fi
  log "Use: docker logs -f '$name'"
}
