#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=../../lib/common.sh
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/common.sh"

GITHUB_API="https://api.github.com"

gh_list_org_repos() {
  local org="${1:-Monynha-Softwares}"
  local per_page="${2:-100}"
  if ! command -v curl >/dev/null 2>&1; then
    err "curl não encontrado para consultar GitHub API."
    return 1
  fi
  # Nota: sem jq; parse simples de nomes.
  local hdr=()
  [[ -n "${GITHUB_TOKEN:-}" ]] && hdr+=(-H "Authorization: Bearer $GITHUB_TOKEN")
  curl -fsSL "${hdr[@]}" "$GITHUB_API/orgs/$org/repos?per_page=$per_page" 2>/dev/null |
    grep -o '"full_name"[^,]*' | cut -d '"' -f4
}

gh_clone() {
  local repo_url="$1" dest_dir="$2" branch="${3:-}"
  [[ -n "$repo_url" && -n "$dest_dir" ]] || {
    err "Uso: gh_clone <repo_url> <dest_dir> [branch]"
    return 1
  }
  if [[ -d "$dest_dir/.git" ]]; then
    log "Repo já existe: $dest_dir ; fazendo pull --ff-only"
    $MONA_DRY_RUN || git -C "$dest_dir" pull --ff-only
  else
    if [[ -n "$branch" ]]; then
      apply "git clone --branch '$branch' --depth 1 '$repo_url' '$dest_dir'"
    else
      apply "git clone --depth 1 '$repo_url' '$dest_dir'"
    fi
  fi
}

show_readme() {
  local dir="$1"
  [[ -n "$dir" ]] || return 0
  local f=""
  for f in README.md README.txt README; do
    if [[ -f "$dir/$f" ]]; then
      if command -v less >/dev/null 2>&1; then
        less -R "$dir/$f"
      else
        cat "$dir/$f"
        pause_any
      fi
      return 0
    fi
  done
  warn "README não encontrado em $dir"
  return 0
}
