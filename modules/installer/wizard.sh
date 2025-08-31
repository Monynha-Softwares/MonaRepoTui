#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../../lib/common.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"
# shellcheck source=github.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/github.sh"
# shellcheck source=docker.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/docker.sh"

PROJECTS_BASE="${PROJECTS_BASE:-/opt/mona-projects}"

ensure_projects_dir(){
  needs_root
  apply "mkdir -p '$PROJECTS_BASE'"
}

# discover actions in a project checkout
discover_actions(){
  local dir="$1"
  ACTIONS=()
  ACTION_CMDS=()

  if [[ -f "$dir/.env.example" ]]; then
    ACTIONS+=("Copiar .env.example → .env")
    ACTION_CMDS+=("cp -n '$dir/.env.example' '$dir/.env'")
  fi

  if [[ -f "$dir/docker-compose.yml" || -f "$dir/docker-compose.yaml" ]]; then
    ACTIONS+=("docker compose up -d")
    ACTION_CMDS+=("cd '$dir' && docker compose up -d")
  fi

  if [[ -f "$dir/package.json" ]]; then
    if command -v pnpm >/dev/null 2>&1; then
      ACTIONS+=("pnpm install")
      ACTION_CMDS+=("cd '$dir' && pnpm install")
    elif command -v yarn >/dev/null 2>&1; then
      ACTIONS+=("yarn install")
      ACTION_CMDS+=("cd '$dir' && yarn install")
    else
      ACTIONS+=("npm install")
      ACTION_CMDS+=("cd '$dir' && npm install")
    fi

    # common scripts
    if grep -q '"build"' "$dir/package.json"; then
      ACTIONS+=("npm run build")
      ACTION_CMDS+=("cd '$dir' && npm run build")
    fi
    if grep -q '"dev"' "$dir/package.json"; then
      ACTIONS+=("npm run dev")
      ACTION_CMDS+=("cd '$dir' && npm run dev")
    fi
    if grep -q '"start"' "$dir/package.json"; then
      ACTIONS+=("npm start")
      ACTION_CMDS+=("cd '$dir' && npm start")
    fi
  fi

  if [[ -x "$dir/scripts/setup.sh" ]]; then
    ACTIONS+=("scripts/setup.sh")
    ACTION_CMDS+=("cd '$dir' && ./scripts/setup.sh")
  fi

  if [[ -f "$dir/Makefile" ]]; then
    if grep -qE '(^|\s)up:' "$dir/Makefile"; then
      ACTIONS+=("make up")
      ACTION_CMDS+=("cd '$dir' && make up")
    fi
    if grep -qE '(^|\s)setup:' "$dir/Makefile"; then
      ACTIONS+=("make setup")
      ACTION_CMDS+=("cd '$dir' && make setup")
    fi
  fi

  if [[ -f "$dir/supabase/config.toml" ]] && command -v supabase >/dev/null 2>&1; then
    ACTIONS+=("supabase start")
    ACTION_CMDS+=("cd '$dir' && supabase start")
  fi
}

run_actions_menu(){
  local dir="$1"
  discover_actions "$dir"

  show_readme "$dir" || true

  if ((${#ACTIONS[@]}==0)); then
    warn "Nenhuma ação automática detectada. Consulte o README e docs do projeto."
    pause_any
    return 0
  fi

  echo "Ações sugeridas para $dir:"
  local i=1
  for a in "${ACTIONS[@]}"; do
    printf "  %2d) %s\n" "$i" "$a"
    ((i++))
  done
  echo "  0) Voltar"
  read -r -p "Escolha uma ação para executar: " idx || true
  if [[ "$idx" =~ ^[0-9]+$ ]] && (( idx>=1 && idx<=${#ACTIONS[@]} )); then
    local cmd="${ACTION_CMDS[idx-1]}"
    local logfile="${MONA_LOG_DIR:-$HOME/.mona/logs}"
    mkdir -p "$logfile"
    logfile="$logfile/$(basename "$dir")-$(date +%Y%m%d-%H%M%S).log"
    log "Executando: $cmd"
    if [[ "${MONA_DRY_RUN:-false}" == "true" ]]; then
      log "(dry-run) $cmd"
    else
      bash -lc "$cmd" 2>&1 | tee "$logfile"
      log "Logs: $logfile"
    fi
    pause_any
  fi
}

wizard_start(){
  echo "Tipo de instalação"
  echo "  1) GitHub (clonar repositório)"
  echo "  2) Docker (pull/run)"
  echo "  0) Voltar"
  read -r -p "Escolha: " choice || true
  case "$choice" in
    1) wizard_github ;;
    2) wizard_docker ;;
    *) return 0 ;;
  esac
}

wizard_github(){
  ensure_projects_dir
  read -r -p "Org/Usuário (ENTER p/ Monynha-Softwares): " org
  org="${org:-Monynha-Softwares}"
  echo "Listando repositórios públicos de $org (se possível)…"
  gh_list_org_repos "$org" || true

  read -r -p "Informe URL do repositório (ou apenas nome para usar https://github.com/$org/NOME): " input
  [[ -n "$input" ]] || { err "Entrada inválida"; return 1; }
  local repo_url="$input"
  if [[ "$input" != http* ]]; then
    repo_url="https://github.com/$org/$input"
  fi
  read -r -p "Branch (ENTER para padrão): " branch
  local name="${repo_url##*/}"; name="${name%.git}"
  local dest="${PROJECTS_BASE}/${name}"
  echo "Destino: $dest"
  gh_clone "$repo_url" "$dest" "$branch"
  run_actions_menu "$dest"
}

wizard_docker(){
  read -r -p "Imagem (ex.: nginx:latest): " image
  [[ -n "${image:-}" ]] || { err "Imagem inválida"; return 1; }
  read -r -p "Nome do container (ENTER p/ mona-app): " name
  name="${name:-mona-app}"
  read -r -p "Mapear porta (ex.: 8080:80) [ENTER para pular]: " port
  docker_pull_image "$image"
  docker_run_quick "$image" "$name" "$port"
  log "Use: docker logs -f '$name'"
  pause_any
}
