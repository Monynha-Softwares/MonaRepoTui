#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
# shellcheck source=../../lib/common.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

run_base() {
  if command -v timedatectl >/dev/null 2>&1; then
    timedatectl set-timezone Europe/Lisbon || true
  fi

  local sshd_config="${SSHD_CONFIG:-/etc/ssh/sshd_config}"

  if [[ -f "$sshd_config" ]]; then
    backup_file "$sshd_config"
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' "$sshd_config" || true
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' "$sshd_config" || true
    systemctl reload ssh || systemctl reload sshd || true
  fi

  if command -v ufw >/dev/null 2>&1; then
    ufw allow OpenSSH || true
    ufw --force enable || true
  fi
}
