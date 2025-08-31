#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../../lib/common.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

configure_nmcli(){
  needs_root
  if ! command -v nmcli >/dev/null 2>&1; then
    err "nmcli não encontrado. Instale NetworkManager ou use Netplan."
    return 1
  fi

  read -r -p "Interface (ex.: eth0): " ifc || true
  [[ -n "${ifc:-}" ]] || { err "Interface inválida"; return 1; }

  read -r -p "Usar DHCP? [Y/n]: " use_dhcp; use_dhcp=${use_dhcp:-Y}
  if [[ "${use_dhcp^^}" == Y* ]]; then
    apply "nmcli con mod \"$ifc\" ipv4.method auto || nmcli con add type ethernet ifname \"$ifc\" con-name \"$ifc\" ipv4.method auto"
  else
    read -r -p "Endereço CIDR (ex.: 192.168.1.10/24): " addr || true
    read -r -p "Gateway (ex.: 192.168.1.1): " gw || true
    read -r -p "DNS (ex.: 1.1.1.1,8.8.8.8): " dns || true
    apply "nmcli con mod \"$ifc\" ipv4.method manual ipv4.addresses \"$addr\" ipv4.gateway \"$gw\" ipv4.dns \"$dns\" || nmcli con add type ethernet ifname \"$ifc\" con-name \"$ifc\" ipv4.method manual ipv4.addresses \"$addr\" ipv4.gateway \"$gw\" ipv4.dns \"$dns\""
  fi
  apply "nmcli con up \"$ifc\""
  log "Configuração NMCLI aplicada para $ifc."
}
