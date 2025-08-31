#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../../lib/common.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"
# shellcheck source=github.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/github.sh"
# shellcheck source=docker.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/docker.sh"

PROJECTS_BASE="${PROJECTS_BASE:-/opt/mona-projects}"

ensure_projects_dir() {
  needs_root
  apply "mkdir -p '$PROJECTS_BASE'"
}

# Try to source simple_curses if TUI reader enabled
maybe_source_curses() {
  local sc="${MONA_DIR:-}/ui/bashsimplecurses/simple_curses.sh"
  if [[ "${MONA_USE_TUI_READER:-0}" == "1" && -f "$sc" ]]; then
    # shellcheck disable=SC1090
    source "$sc"
    return 0
  fi
  return 1
}

tui_view_file() {
  local file="$1"
  [[ -f "$file" ]] || {
    warn "Arquivo não encontrado: $file"
    return 1
  }
  if ! maybe_source_curses; then
    if command -v less >/dev/null 2>&1; then less -R "$file"; else cat "$file"; fi
    pause_any
    return 0
  fi
  local -a lines
  mapfile -t lines <"$file"
  local top=0
  local max=${#lines[@]}
  local page=20

  _draw() {
    window "README (TUI) — ↑/↓ rola, Q sai" "blue" "100%"
    local i
    local end=$((top + page))
    ((end > max)) && end=$max
    for ((i = top; i < end; i++)); do
      append "${lines[$i]}"
    done
    addsep
    append "Linhas: $((top + 1))–$end de $max"
    endwin
  }

  main() { _draw; }
  readKey() {
    local k
    IFS= read -rsn1 -t 0.2 k || true
    if [[ "$k" == $'\e' ]]; then
      local k2 k3
      IFS= read -rsn1 -t 0.001 k2 || true
      IFS= read -rsn1 -t 0.001 k3 || true
      k+="$k2$k3"
    fi
    printf '%s' "$k"
  }
  update() {
    local key
    key=$(readKey)
    case "$key" in
    $'\e[A') ((top > 0)) && ((top--)) ;;
    $'\e[B') ((top + page < max)) && ((top++)) ;;
    q | Q) return 1 ;;
    esac
  }
  main_loop -t 1 || true
}

compose_cmd_for() {
  local dir="$1"
  if command -v docker >/dev/null 2>&1; then
    if docker compose version >/dev/null 2>&1; then
      echo "docker compose"
      return 0
    fi
    if command -v docker-compose >/dev/null 2>&1; then
      echo "docker-compose"
      return 0
    fi
  fi
  echo ""
  return 1
}

env_interactive_from_example() {
  local dir="$1"
  local src="$dir/.env.example"
  local dst="$dir/.env"
  [[ -f "$src" ]] || {
    err ".env.example não encontrado"
    return 1
  }
  echo "Gerando $dst a partir de $src (interativo). ENTER mantém o default, espaço em branco mantém vazio."
  [[ -f "$dst" ]] && cp "$dst" "$dst.bak.mona.$(date +%s)"
  : >"$dst"
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^\s*# ]] || [[ -z "$line" ]]; then
      echo "$line" >>"$dst"
      continue
    fi
    # parse KEY=VALUE (tira aspas simples/duplas do default)
    key="${line%%=*}"
    def="${line#*=}"
    def="${def%$'\r'}"
    def="${def%\"}"
    def="${def#\"}"
    def="${def%\'}"
    def="${def#\'}"
    read -r -p "$key [${def}]: " val
    if [[ -z "${val}" ]]; then
      val="${def}"
    fi
    printf "%s=%s\n" "$key" "$val" >>"$dst"
  done <"$src"
  log ".env gerado: $dst"
}

# discover actions in a project checkout
discover_actions() {
  local dir="$1"
  ACTIONS=()
  ACTION_CMDS=()

  if [[ -f "$dir/.env.example" ]]; then
    ACTIONS+=("Copiar .env.example → .env")
    ACTION_CMDS+=("cp -n '$dir/.env.example' '$dir/.env'")
    ACTIONS+=("Criar .env interativo (de .env.example)")
    ACTION_CMDS+=("env_interactive_from_example '$dir'")
  fi

  local ccmd
  ccmd=$(compose_cmd_for "$dir") || true
  if [[ -n "$ccmd" ]] && [[ -f "$dir/docker-compose.yml" || -f "$dir/docker-compose.yaml" ]]; then
    ACTIONS+=("$ccmd pull")
    ACTION_CMDS+=("cd '$dir' && $ccmd pull")
    ACTIONS+=("$ccmd up -d --remove-orphans")
    ACTION_CMDS+=("cd '$dir' && $ccmd up -d --remove-orphans")
    ACTIONS+=("$ccmd ps")
    ACTION_CMDS+=("cd '$dir' && $ccmd ps")
    ACTIONS+=("$ccmd logs -f (Ctrl+C para sair)")
    ACTION_CMDS+=("cd '$dir' && $ccmd logs -f")
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

run_actions_menu() {
  local dir="$1"
  discover_actions "$dir"

  if [[ "${MONA_USE_TUI_READER:-0}" == "1" ]]; then tui_view_file "$dir/README.md" || true; else show_readme "$dir" || true; fi
  show_readme "$dir" || true

  if ((${#ACTIONS[@]} == 0)); then
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
  if [[ "$idx" =~ ^[0-9]+$ ]] && ((idx >= 1 && idx <= ${#ACTIONS[@]})); then
    local cmd="${ACTION_CMDS[idx - 1]}"
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

wizard_start() {
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

wizard_github() {
  ensure_projects_dir
  read -r -p "Org/Usuário (ENTER p/ Monynha-Softwares): " org
  org="${org:-Monynha-Softwares}"
  echo "Listando repositórios públicos de $org (se possível)…"
  gh_list_org_repos "$org" || true

  read -r -p "Informe URL do repositório (ou apenas nome para usar https://github.com/$org/NOME): " input
  [[ -n "$input" ]] || {
    err "Entrada inválida"
    return 1
  }
  local repo_url="$input"
  if [[ "$input" != http* ]]; then
    repo_url="https://github.com/$org/$input"
  fi
  read -r -p "Branch (ENTER para padrão): " branch
  local name="${repo_url##*/}"
  name="${name%.git}"
  local dest="${PROJECTS_BASE}/${name}"
  echo "Destino: $dest"
  gh_clone "$repo_url" "$dest" "$branch"
  run_actions_menu "$dest"
}

wizard_docker() {
  read -r -p "Imagem (ex.: nginx:latest): " image
  [[ -n "${image:-}" ]] || {
    err "Imagem inválida"
    return 1
  }
  read -r -p "Nome do container (ENTER p/ mona-app): " name
  name="${name:-mona-app}"
  read -r -p "Mapear porta (ex.: 8080:80) [ENTER para pular]: " port
  docker_pull_image "$image"
  docker_run_quick "$image" "$name" "$port"
  log "Use: docker logs -f '$name'"
  pause_any
}
