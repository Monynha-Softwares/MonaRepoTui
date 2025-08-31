#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
# shellcheck source=../../lib/common.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

run_docker_install() {
  if command -v docker >/dev/null 2>&1; then
    log_info "Docker já instalado."
    return 0
  fi

  if command -v apt-get >/dev/null 2>&1; then
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(
      . /etc/os-release
      echo \"$VERSION_CODENAME\"
    ) stable" >/etc/apt/sources.list.d/docker.list
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    usermod -aG docker "${SUDO_USER:-$USER}" || true
    systemctl enable --now docker || true
    log_success "Docker instalado (apt)."
    return 0
  fi

  log_warn "Implementar instalação Docker para esta distro."
  return 1
}
