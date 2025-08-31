#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../../lib/common.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

run_coolify_bootstrap(){
  needs_root
  # Pasta padrão para Coolify deployments/volumes
  local base="/data/coolify"
  apply "mkdir -p \"$base/source\" \"$base/volumes\" \"$base/backups\""

  # Docker network "coolify" (idempotente)
  if command -v docker >/dev/null 2>&1; then
    if ! docker network ls --format '{{.Name}}' | grep -qx "coolify"; then
      apply "docker network create coolify"
      log "Docker network 'coolify' criada."
    else
      log "Docker network 'coolify' já existe."
    fi
  else
    warn "Docker não encontrado. Execute módulo docker/install antes."
  fi

  # sysctl tuning opcional (descomentado caso precise)
  # apply "sysctl -w net.ipv4.ip_forward=1"
  log "Coolify bootstrap concluído (pastas + network)."
}
