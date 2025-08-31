# Common helpers for MonaRepo
set -euo pipefail

log()   { printf "[mona] %s\n" "$*"; }
warn()  { printf "[mona:warn] %s\n" "$*"; } >&2
err()   { printf "[mona:err] %s\n" "$*"; } >&2
needs_root(){ [[ $EUID -eq 0 ]] || { err "Execute como root (sudo)."; exit 1; }; }
color(){ local c="$1"; shift; printf "\e[%sm%s\e[0m" "$c" "$*"; }

pm_detect(){
  if command -v apt-get >/dev/null 2>&1; then echo apt; return; fi
  if command -v dnf >/dev/null 2>&1; then echo dnf; return; fi
  if command -v yum >/dev/null 2>&1; then echo yum; return; fi
  if command -v pacman >/dev/null 2>&1; then echo pacman; return; fi
  if command -v zypper >/dev/null 2>&1; then echo zypper; return; fi
  echo unknown
}

pkg_install(){
  local pkgs=("$@") pm
  pm=$(pm_detect)
  log "Instalando pacotes via $pm: ${pkgs[*]}"
  [[ "${MONA_DRY_RUN:-false}" == "true" ]] && return 0
  case "$pm" in
    apt)    apt-get update -y && DEBIAN_FRONTEND=noninteractive apt-get install -y "${pkgs[@]}";;
    dnf)    dnf install -y "${pkgs[@]}";;
    yum)    yum install -y "${pkgs[@]}";;
    pacman) pacman -Sy --noconfirm "${pkgs[@]}";;
    zypper) zypper --non-interactive install --no-recommends "${pkgs[@]}";;
    *)      err "Gerenciador de pacotes não suportado"; return 1;;
  esac
}

apply(){ 
  if [[ "${MONA_DRY_RUN:-false}" == "true" ]]; then 
    log "(dry-run) $*"
  else 
    eval "$*"
  fi 
}

pause_any(){ read -r -p $'Pressione Enter para voltar ao menu…\n' _ || true; }
