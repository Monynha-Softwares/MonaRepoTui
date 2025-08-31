#!/usr/bin/env bash
set -euo pipefail

run_base() {
  # timezone + basic packages
  if command -v timedatectl >/dev/null 2>&1; then
    timedatectl set-timezone Europe/Lisbon || true
  fi

  # basic security and ssh hardening
  if [[ -f /etc/ssh/sshd_config ]]; then
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config || true
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config || true
    systemctl reload ssh || systemctl reload sshd || true
  fi

  # firewall
  if command -v ufw >/dev/null 2>&1; then
    ufw allow OpenSSH || true
    ufw --force enable || true
  fi
}
