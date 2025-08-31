#!/usr/bin/env bash
set -euo pipefail

run_docker_install() {
  if command -v docker >/dev/null 2>&1; then
    echo "[mona] Docker já instalado."
    return 0
  fi

  if command -v apt-get >/dev/null 2>&1; then
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(
      . /etc/os-release
      echo $VERSION_CODENAME
    ) stable" \
      >/etc/apt/sources.list.d/docker.list
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    usermod -aG docker "${SUDO_USER:-$USER}" || true
    systemctl enable --now docker || true
    echo "[mona] Docker instalado (apt)."
    return 0
  fi

  echo "[mona:warn] Implementar instalação Docker para esta distro."
  return 1
}
