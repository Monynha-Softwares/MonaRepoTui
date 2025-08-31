#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

_color() {
  local code="$1" msg="$2"
  if [[ -n "${NO_COLOR:-}" || "${MONA_NONINTERACTIVE:-0}" == "1" ]]; then
    printf '%s' "$msg"
    return
  fi
  printf '\e[%sm%s\e[0m' "$code" "$msg"
}

_log() {
  local level="$1" color_code="$2"; shift 2
  local prefix="[mona:${level}]"
  local text="$*"
  local colored_prefix
  colored_prefix=$(_color "$color_code" "$prefix")
  printf '%s %s\n' "$colored_prefix" "$text"
}

log_info() { _log info 34 "$*"; }
log_warn() { _log warn 33 "$*" >&2; }
log_error() { _log error 31 "$*" >&2; }
log_success() { _log success 32 "$*"; }

# Backwards compatibility
log() { log_info "$@"; }
warn() { log_warn "$@"; }
err() { log_error "$@"; }
